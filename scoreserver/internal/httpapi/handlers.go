package httpapi

import (
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	"scoreserver/internal/config"
	"scoreserver/internal/scoring"
	"scoreserver/internal/storage"
)

// Server holds shared dependencies for all HTTP handlers.
type Server struct {
	DB      *sql.DB
	Cfg     *config.Config
	Limiter *RateLimiters
}

// RegisterRoutes wires all API routes onto mux.
func (s *Server) RegisterRoutes(mux *http.ServeMux) {
	mux.Handle("POST /api/v1/submit-solution",
		LimitBody(http.HandlerFunc(s.handleSubmit)))
	mux.HandleFunc("GET /api/v1/puzzles", s.handleListPuzzles)
	mux.HandleFunc("GET /api/v1/puzzles/{puzzle_id}/histograms", s.handleHistograms)
}

// writeJSON encodes v as JSON and writes it with the given status code.
func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(v); err != nil {
		log.Printf("writeJSON: %v", err)
	}
}

func errorResponse(w http.ResponseWriter, status int, errCode string) {
	writeJSON(w, status, SubmitResponse{Accepted: false, Error: errCode})
}

// handleSubmit processes POST /api/v1/submit-solution.
func (s *Server) handleSubmit(w http.ResponseWriter, r *http.Request) {
	ip := RemoteIP(r)

	if !s.Limiter.ByIP.Allow(ip) {
		errorResponse(w, http.StatusTooManyRequests, "rate_limited")
		return
	}

	var req SubmitRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		errorResponse(w, http.StatusBadRequest, "bad_request")
		return
	}

	if req.InstallID != "" && !s.Limiter.ByInstall.Allow(req.InstallID) {
		errorResponse(w, http.StatusTooManyRequests, "rate_limited")
		return
	}

	if req.PuzzleID == 0 || req.PuzzleVersion == "" || req.InstallID == "" || req.SolutionPNGBase64 == "" {
		errorResponse(w, http.StatusBadRequest, "missing_fields")
		return
	}

	puzzle, err := storage.GetActivePuzzle(s.DB, req.PuzzleID, req.PuzzleVersion)
	if err == sql.ErrNoRows {
		errorResponse(w, http.StatusUnprocessableEntity, "unknown_puzzle_version")
		return
	}
	if err != nil {
		log.Printf("get puzzle: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	pngBytes, err := base64.StdEncoding.DecodeString(req.SolutionPNGBase64)
	if err != nil {
		errorResponse(w, http.StatusBadRequest, "invalid_base64")
		return
	}

	rawImg, err := scoring.DecodePNG(pngBytes)
	if err != nil {
		code := "invalid_png"
		if err.Error()[:16] == "wrong dimensions" {
			code = "wrong_dimensions"
		}
		errorResponse(w, http.StatusUnprocessableEntity, code)
		return
	}

	img := scoring.Normalize(rawImg)
	metrics := scoring.ComputeMetrics(img, puzzle.MarginRect(scoring.CanonicalHeight))
	solutionHash := scoring.ContentHash(img)

	canonicalPNG, err := scoring.EncodePNG(img)
	if err != nil {
		log.Printf("encode canonical png: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	now := time.Now().UTC()
	ipHash := HashIP(r.RemoteAddr)

	tx, err := s.DB.Begin()
	if err != nil {
		log.Printf("begin tx: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}
	defer tx.Rollback()

	sub := storage.Submission{
		PuzzleID:          req.PuzzleID,
		PuzzleVersion:     req.PuzzleVersion,
		ScoringVersion:    puzzle.ScoringVersion,
		InstallID:         req.InstallID,
		SolutionHash:      solutionHash,
		CanonicalPNG:      canonicalPNG,
		Gates:             metrics.Gates,
		TotalInk:          metrics.TotalInk,
		CoreArea:          metrics.CoreArea,
		SubmittedAt:       now,
		ClientGameVersion: req.ClientGameVersion,
		ClientPlatform:    req.ClientPlatform,
		ClientIPHash:      ipHash,
	}
	subID, err := storage.InsertSubmission(tx, sub)
	if err != nil {
		log.Printf("insert submission: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	state, err := storage.GetPlayerState(tx, req.PuzzleID, req.PuzzleVersion, req.InstallID)
	if err != nil {
		log.Printf("get player state: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	if state == nil {
		// First submission — add histogram counts for all three metrics.
		state = &storage.PlayerPuzzleState{
			PuzzleID:       req.PuzzleID,
			PuzzleVersion:  req.PuzzleVersion,
			ScoringVersion: puzzle.ScoringVersion,
			InstallID:      req.InstallID,

			LatestSubmissionID: subID,
			LatestSolutionHash: solutionHash,
			LatestGates:        metrics.Gates,
			LatestTotalInk:     metrics.TotalInk,
			LatestCoreArea:     metrics.CoreArea,
			LatestSubmittedAt:  now,

			BestGatesSubmissionID: subID,
			BestGatesSolutionHash: solutionHash,
			BestGates:             metrics.Gates,
			BestGatesAt:           now,

			BestInkSubmissionID: subID,
			BestInkSolutionHash: solutionHash,
			BestTotalInk:        metrics.TotalInk,
			BestInkAt:           now,

			BestAreaSubmissionID: subID,
			BestAreaSolutionHash: solutionHash,
			BestCoreArea:         metrics.CoreArea,
			BestAreaAt:           now,

			SubmissionCount: 1,
		}

		for _, mc := range []struct {
			name  string
			value int
		}{
			{"gates", metrics.Gates},
			{"total_ink", metrics.TotalInk},
			{"core_area", metrics.CoreArea},
		} {
			if err := adjustHistogram(tx, puzzle, mc.name, mc.value, +1); err != nil {
				log.Printf("histogram %s: %v", mc.name, err)
				errorResponse(w, http.StatusInternalServerError, "internal_error")
				return
			}
		}
	} else {
		state.LatestSubmissionID = subID
		state.LatestSolutionHash = solutionHash
		state.LatestGates = metrics.Gates
		state.LatestTotalInk = metrics.TotalInk
		state.LatestCoreArea = metrics.CoreArea
		state.LatestSubmittedAt = now
		state.SubmissionCount++

		type improvement struct {
			metric   string
			oldValue int
			newValue int
			better   bool
		}
		improvements := []improvement{
			{"gates", state.BestGates, metrics.Gates, metrics.Gates < state.BestGates},
			{"total_ink", state.BestTotalInk, metrics.TotalInk, metrics.TotalInk < state.BestTotalInk},
			{"core_area", state.BestCoreArea, metrics.CoreArea, metrics.CoreArea < state.BestCoreArea},
		}
		for _, imp := range improvements {
			if !imp.better {
				continue
			}
			if err := adjustHistogram(tx, puzzle, imp.metric, imp.oldValue, -1); err != nil {
				log.Printf("shift histogram %s (decrement): %v", imp.metric, err)
				errorResponse(w, http.StatusInternalServerError, "internal_error")
				return
			}
			if err := adjustHistogram(tx, puzzle, imp.metric, imp.newValue, +1); err != nil {
				log.Printf("shift histogram %s (increment): %v", imp.metric, err)
				errorResponse(w, http.StatusInternalServerError, "internal_error")
				return
			}
		}

		if improvements[0].better {
			state.BestGates = metrics.Gates
			state.BestGatesSubmissionID = subID
			state.BestGatesSolutionHash = solutionHash
			state.BestGatesAt = now
		}
		if improvements[1].better {
			state.BestTotalInk = metrics.TotalInk
			state.BestInkSubmissionID = subID
			state.BestInkSolutionHash = solutionHash
			state.BestInkAt = now
		}
		if improvements[2].better {
			state.BestCoreArea = metrics.CoreArea
			state.BestAreaSubmissionID = subID
			state.BestAreaSolutionHash = solutionHash
			state.BestAreaAt = now
		}
	}

	if err := storage.UpsertPlayerState(tx, state); err != nil {
		log.Printf("upsert player state: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	if err := tx.Commit(); err != nil {
		log.Printf("commit: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	resp, err := s.buildHistogramResponse(puzzle)
	if err != nil {
		log.Printf("build histogram response: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, SubmitResponse{
		Accepted:       true,
		PuzzleID:       req.PuzzleID,
		PuzzleVersion:  req.PuzzleVersion,
		ScoringVersion: puzzle.ScoringVersion,
		CanonicalMetrics: &MetricValues{
			Gates:    metrics.Gates,
			TotalInk: metrics.TotalInk,
			CoreArea: metrics.CoreArea,
		},
		BestMetrics: &MetricValues{
			Gates:    state.BestGates,
			TotalInk: state.BestTotalInk,
			CoreArea: state.BestCoreArea,
		},
		SampleCount: resp.SampleCount,
		Percentiles: resp.Percentiles,
		BinConfig:   resp.BinConfig,
		Histograms:  resp.Histograms,
	})
}

// handleListPuzzles handles GET /api/v1/puzzles.
func (s *Server) handleListPuzzles(w http.ResponseWriter, r *http.Request) {
	puzzles, err := storage.ListActivePuzzles(s.DB)
	if err != nil {
		log.Printf("list puzzles: %v", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}
	entries := make([]PuzzleEntry, len(puzzles))
	for i, p := range puzzles {
		entries[i] = PuzzleEntry{
			PuzzleID:       p.PuzzleID,
			PuzzleVersion:  p.PuzzleVersion,
			ScoringVersion: p.ScoringVersion,
			Title:          p.Title,
			IsActive:       p.IsActive,
		}
	}
	writeJSON(w, http.StatusOK, PuzzlesResponse{Puzzles: entries})
}

// handleHistograms handles GET /api/v1/puzzles/{puzzle_id}/histograms.
func (s *Server) handleHistograms(w http.ResponseWriter, r *http.Request) {
	puzzleIDStr := r.PathValue("puzzle_id")
	puzzleID, err := strconv.Atoi(puzzleIDStr)
	if err != nil {
		http.Error(w, "invalid puzzle_id", http.StatusBadRequest)
		return
	}
	puzzleVersion := r.URL.Query().Get("puzzle_version")
	if puzzleVersion == "" {
		http.Error(w, "puzzle_version required", http.StatusBadRequest)
		return
	}
	installID := r.URL.Query().Get("install_id")

	puzzle, err := storage.GetActivePuzzle(s.DB, puzzleID, puzzleVersion)
	if err == sql.ErrNoRows {
		http.Error(w, "unknown puzzle version", http.StatusNotFound)
		return
	}
	if err != nil {
		log.Printf("get puzzle: %v", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}

	resp, err := s.buildHistogramResponse(puzzle)
	if err != nil {
		log.Printf("build histogram response: %v", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}

	if installID != "" {
		tx, err := s.DB.Begin()
		if err == nil {
			state, err := storage.GetPlayerState(tx, puzzleID, puzzleVersion, installID)
			tx.Rollback()
			if err == nil && state != nil {
				resp.PlayerBestMetrics = &MetricValues{
					Gates:    state.BestGates,
					TotalInk: state.BestTotalInk,
					CoreArea: state.BestCoreArea,
				}
			}
		}
	}

	writeJSON(w, http.StatusOK, resp)
}

// adjustHistogram adds delta (+1 or -1) to the exact-value bin for a metric.
func adjustHistogram(tx *sql.Tx, puzzle *storage.Puzzle, metric string, value, delta int) error {
	maxVal := value + 1
	return storage.AdjustHistogramCount(tx,
		puzzle.PuzzleID, puzzle.PuzzleVersion, puzzle.ScoringVersion,
		metric, value, &maxVal, delta)
}

// aggregateBins collapses exact histogram rows into the 9 display bins defined
// by binStart and binSize.
//
// Bin layout:
//
//	[0]       catch-all low  — all values < binStart         (min_value = 0)
//	[1]..[7]  regular bins   — [binStart+i*binSize, binStart+(i+1)*binSize)
//	[8]       catch-all high — all values >= binStart+7*binSize
func aggregateBins(exact []storage.HistogramBucket, binStart, binSize int) []BucketEntry {
	counts := make([]int, 9)
	for _, b := range exact {
		v := b.MinValue
		var idx int
		switch {
		case v < binStart:
			idx = 0
		case v >= binStart+7*binSize:
			idx = 8
		default:
			idx = (v-binStart)/binSize + 1
		}
		counts[idx] += b.Count
	}

	entries := make([]BucketEntry, 9)
	for i := range entries {
		minVal := 0
		if i > 0 {
			minVal = binStart + (i-1)*binSize
		}
		entries[i] = BucketEntry{MinValue: minVal, Count: counts[i]}
	}
	return entries
}

// deriveDefaultBins computes a fallback (binStart, binSize) from exact
// histogram data so a histogram can be shown even before the admin has
// configured explicit bin values.  binSize is always at least 1.
func deriveDefaultBins(exact []storage.HistogramBucket) (binStart, binSize int) {
	if len(exact) == 0 {
		return 0, 1
	}
	minVal := exact[0].MinValue
	maxVal := exact[len(exact)-1].MinValue
	span := maxVal - minVal
	binSize = (span + 6) / 7 // ceil(span / 7)
	if binSize < 1 {
		binSize = 1
	}
	return minVal, binSize
}

// buildHistogramResponse fetches exact histogram rows and aggregates them into
// 9 display bins.  If a metric has no configured bin spec, one is derived
// automatically from the observed data range.
func (s *Server) buildHistogramResponse(puzzle *storage.Puzzle) (*HistogramsResponse, error) {
	type metricCfg struct {
		name  string
		start *int
		size  *int
	}
	metrics := []metricCfg{
		{"gates", puzzle.GatesBinStart, puzzle.GatesBinSize},
		{"total_ink", puzzle.InkBinStart, puzzle.InkBinSize},
		{"core_area", puzzle.AreaBinStart, puzzle.AreaBinSize},
	}

	histograms := make(map[string][]BucketEntry)
	binConfig := make(map[string]BinSpec)

	for _, mc := range metrics {
		exact, err := storage.GetHistogram(s.DB,
			puzzle.PuzzleID, puzzle.PuzzleVersion, puzzle.ScoringVersion, mc.name)
		if err != nil {
			return nil, err
		}
		if len(exact) == 0 {
			continue
		}
		var start, size int
		if mc.start != nil && mc.size != nil {
			start, size = *mc.start, *mc.size
		} else {
			start, size = deriveDefaultBins(exact)
		}
		histograms[mc.name] = aggregateBins(exact, start, size)
		binConfig[mc.name] = BinSpec{BinStart: start, BinSize: size}
	}

	sampleCount, err := storage.SampleCount(s.DB,
		puzzle.PuzzleID, puzzle.PuzzleVersion, puzzle.ScoringVersion)
	if err != nil {
		return nil, err
	}

	var binConfigOut map[string]BinSpec
	if len(binConfig) > 0 {
		binConfigOut = binConfig
	}

	return &HistogramsResponse{
		PuzzleID:       puzzle.PuzzleID,
		PuzzleVersion:  puzzle.PuzzleVersion,
		ScoringVersion: puzzle.ScoringVersion,
		SampleCount:    sampleCount,
		BinConfig:      binConfigOut,
		Histograms:     histograms,
	}, nil
}
