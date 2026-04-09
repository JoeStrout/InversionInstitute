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
	"scoreserver/internal/histogram"
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

	// Rate limit by IP.
	if !s.Limiter.ByIP.Allow(ip) {
		errorResponse(w, http.StatusTooManyRequests, "rate_limited")
		return
	}

	var req SubmitRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		errorResponse(w, http.StatusBadRequest, "bad_request")
		return
	}

	// Rate limit by install ID.
	if req.InstallID != "" && !s.Limiter.ByInstall.Allow(req.InstallID) {
		errorResponse(w, http.StatusTooManyRequests, "rate_limited")
		return
	}

	// Validate required fields.
	if req.PuzzleID == 0 || req.PuzzleVersion == "" || req.InstallID == "" || req.SolutionPNGBase64 == "" {
		errorResponse(w, http.StatusBadRequest, "missing_fields")
		return
	}

	// Verify puzzle exists and is active.
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

	// Decode base64 PNG.
	pngBytes, err := base64.StdEncoding.DecodeString(req.SolutionPNGBase64)
	if err != nil {
		errorResponse(w, http.StatusBadRequest, "invalid_base64")
		return
	}

	// Decode and validate PNG dimensions.
	rawImg, err := scoring.DecodePNG(pngBytes)
	if err != nil {
		code := "invalid_png"
		if err.Error()[:16] == "wrong dimensions" {
			code = "wrong_dimensions"
		}
		errorResponse(w, http.StatusUnprocessableEntity, code)
		return
	}

	// Normalize and compute metrics using the puzzle's margin.
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

	// Run the full submit pipeline inside a transaction.
	tx, err := s.DB.Begin()
	if err != nil {
		log.Printf("begin tx: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}
	defer tx.Rollback()

	// Insert submission row.
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

	// Read existing player state.
	state, err := storage.GetPlayerState(tx, req.PuzzleID, req.PuzzleVersion, req.InstallID)
	if err != nil {
		log.Printf("get player state: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	bsv := s.Cfg.Buckets.Version

	if state == nil {
		// First submission: create state, add histogram counts for all three metrics.
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

		if err := s.incrementHistogram(tx, puzzle, bsv, "gates", metrics.Gates, nil); err != nil {
			log.Printf("histogram gates: %v", err)
			errorResponse(w, http.StatusInternalServerError, "internal_error")
			return
		}
		if err := s.incrementHistogram(tx, puzzle, bsv, "total_ink", metrics.TotalInk, s.Cfg.Buckets.TotalInk); err != nil {
			log.Printf("histogram total_ink: %v", err)
			errorResponse(w, http.StatusInternalServerError, "internal_error")
			return
		}
		if err := s.incrementHistogram(tx, puzzle, bsv, "core_area", metrics.CoreArea, s.Cfg.Buckets.CoreArea); err != nil {
			log.Printf("histogram core_area: %v", err)
			errorResponse(w, http.StatusInternalServerError, "internal_error")
			return
		}
	} else {
		// Update latest.
		state.LatestSubmissionID = subID
		state.LatestSolutionHash = solutionHash
		state.LatestGates = metrics.Gates
		state.LatestTotalInk = metrics.TotalInk
		state.LatestCoreArea = metrics.CoreArea
		state.LatestSubmittedAt = now
		state.SubmissionCount++

		// Check each metric for improvement and adjust histograms accordingly.
		if metrics.Gates < state.BestGates {
			if err := s.shiftHistogram(tx, puzzle, bsv, "gates",
				state.BestGates, nil, metrics.Gates, nil); err != nil {
				log.Printf("shift histogram gates: %v", err)
				errorResponse(w, http.StatusInternalServerError, "internal_error")
				return
			}
			state.BestGates = metrics.Gates
			state.BestGatesSubmissionID = subID
			state.BestGatesSolutionHash = solutionHash
			state.BestGatesAt = now
		}
		if metrics.TotalInk < state.BestTotalInk {
			if err := s.shiftHistogram(tx, puzzle, bsv, "total_ink",
				state.BestTotalInk, s.Cfg.Buckets.TotalInk,
				metrics.TotalInk, s.Cfg.Buckets.TotalInk); err != nil {
				log.Printf("shift histogram total_ink: %v", err)
				errorResponse(w, http.StatusInternalServerError, "internal_error")
				return
			}
			state.BestTotalInk = metrics.TotalInk
			state.BestInkSubmissionID = subID
			state.BestInkSolutionHash = solutionHash
			state.BestInkAt = now
		}
		if metrics.CoreArea < state.BestCoreArea {
			if err := s.shiftHistogram(tx, puzzle, bsv, "core_area",
				state.BestCoreArea, s.Cfg.Buckets.CoreArea,
				metrics.CoreArea, s.Cfg.Buckets.CoreArea); err != nil {
				log.Printf("shift histogram core_area: %v", err)
				errorResponse(w, http.StatusInternalServerError, "internal_error")
				return
			}
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

	// Build response.
	resp, err := s.buildHistogramResponse(puzzle, bsv)
	if err != nil {
		log.Printf("build histogram response: %v", err)
		errorResponse(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, SubmitResponse{
		Accepted:         true,
		PuzzleID:         req.PuzzleID,
		PuzzleVersion:    req.PuzzleVersion,
		ScoringVersion:   puzzle.ScoringVersion,
		BucketSetVersion: bsv,
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

	bsv := s.Cfg.Buckets.Version
	resp, err := s.buildHistogramResponse(puzzle, bsv)
	if err != nil {
		log.Printf("build histogram response: %v", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}

	// Attach player best if install_id was provided.
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

// incrementHistogram adds +1 to the bucket for the given metric value.
// cfgBuckets is nil for gates (exact bins).
func (s *Server) incrementHistogram(tx *sql.Tx, puzzle *storage.Puzzle, bsv, metric string, value int, cfgBuckets []config.Bucket) error {
	minVal, maxVal, err := resolveBucket(metric, value, cfgBuckets)
	if err != nil {
		return err
	}
	return storage.AdjustHistogramCount(tx,
		puzzle.PuzzleID, puzzle.PuzzleVersion, puzzle.ScoringVersion, bsv,
		metric, minVal, maxVal, +1)
}

// shiftHistogram decrements the old bucket and increments the new bucket.
func (s *Server) shiftHistogram(tx *sql.Tx, puzzle *storage.Puzzle, bsv, metric string,
	oldValue int, oldCfg []config.Bucket,
	newValue int, newCfg []config.Bucket) error {

	oldMin, oldMax, err := resolveBucket(metric, oldValue, oldCfg)
	if err != nil {
		return err
	}
	newMin, newMax, err := resolveBucket(metric, newValue, newCfg)
	if err != nil {
		return err
	}
	// Only move if the bucket actually changed.
	if oldMin == newMin {
		return nil
	}
	if err := storage.AdjustHistogramCount(tx,
		puzzle.PuzzleID, puzzle.PuzzleVersion, puzzle.ScoringVersion, bsv,
		metric, oldMin, oldMax, -1); err != nil {
		return err
	}
	return storage.AdjustHistogramCount(tx,
		puzzle.PuzzleID, puzzle.PuzzleVersion, puzzle.ScoringVersion, bsv,
		metric, newMin, newMax, +1)
}

// resolveBucket returns the (minVal, maxVal) for a metric value.
func resolveBucket(metric string, value int, cfgBuckets []config.Bucket) (int, *int, error) {
	if metric == "gates" {
		min, max := histogram.BucketForGates(value)
		return min, max, nil
	}
	min, max, err := histogram.BucketForConfigured(value, cfgBuckets)
	return min, max, err
}

// buildHistogramResponse fetches all three histograms and computes totals/percentiles.
func (s *Server) buildHistogramResponse(puzzle *storage.Puzzle, bsv string) (*HistogramsResponse, error) {
	metrics := []string{"gates", "total_ink", "core_area"}
	histograms := make(map[string][]BucketEntry)
	rawBuckets := make(map[string][]storage.HistogramBucket)

	for _, m := range metrics {
		buckets, err := storage.GetHistogram(s.DB,
			puzzle.PuzzleID, puzzle.PuzzleVersion,
			puzzle.ScoringVersion, bsv, m)
		if err != nil {
			return nil, err
		}
		rawBuckets[m] = buckets
		entries := make([]BucketEntry, len(buckets))
		for i, b := range buckets {
			entries[i] = BucketEntry{MinValue: b.MinValue, Count: b.Count}
		}
		histograms[m] = entries
	}

	sampleCount, err := storage.SampleCount(s.DB,
		puzzle.PuzzleID, puzzle.PuzzleVersion, puzzle.ScoringVersion, bsv)
	if err != nil {
		return nil, err
	}

	return &HistogramsResponse{
		PuzzleID:         puzzle.PuzzleID,
		PuzzleVersion:    puzzle.PuzzleVersion,
		ScoringVersion:   puzzle.ScoringVersion,
		BucketSetVersion: bsv,
		SampleCount:      sampleCount,
		Histograms:       histograms,
	}, nil
}
