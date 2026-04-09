package httpapi_test

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"image"
	"image/color"
	"image/png"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"scoreserver/internal/config"
	"scoreserver/internal/httpapi"
	"scoreserver/internal/storage"
)

// ---------- helpers ----------

func makeTestServer(t *testing.T) (*httpapi.Server, func()) {
	t.Helper()

	// Use a temp file for the DB so tests are isolated.
	f, err := os.CreateTemp("", "scoreserver-test-*.db")
	if err != nil {
		t.Fatalf("temp db file: %v", err)
	}
	f.Close()

	db, err := storage.Open(f.Name())
	if err != nil {
		t.Fatalf("open db: %v", err)
	}

	// Seed a test puzzle.
	if err := storage.InsertPuzzle(db, storage.Puzzle{
		PuzzleID:       1,
		PuzzleVersion:  "v1",
		ScoringVersion: "v1",
		Title:          "Test Puzzle",
		IsActive:       true,
		CreatedAt:      time.Now(),
	}); err != nil {
		t.Fatalf("seed puzzle: %v", err)
	}

	cfg := &config.Config{
		Buckets: config.BucketConfig{
			Version: "v1",
			TotalInk: []config.Bucket{
				{MinInclusive: 0, MaxExclusive: 100, Label: "0-99"},
				{MinInclusive: 100, MaxExclusive: 0, Label: "100+"},
			},
			CoreArea: []config.Bucket{
				{MinInclusive: 0, MaxExclusive: 100, Label: "0-99"},
				{MinInclusive: 100, MaxExclusive: 0, Label: "100+"},
			},
		},
	}

	srv := &httpapi.Server{
		DB:      db,
		Cfg:     cfg,
		Limiter: httpapi.NewRateLimiters(1000, 1000),
	}

	cleanup := func() {
		db.Close()
		os.Remove(f.Name())
	}
	return srv, cleanup
}

// makePNG creates a minimal valid 80×64 PNG with a specific number of white pixels.
func makePNG(whiteCount int) []byte {
	img := image.NewNRGBA(image.Rect(0, 0, 80, 64))
	n := 0
	for y := 0; y < 64 && n < whiteCount; y++ {
		for x := 0; x < 80 && n < whiteCount; x++ {
			img.SetNRGBA(x, y, color.NRGBA{R: 255, G: 255, B: 255, A: 255})
			n++
		}
	}
	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		panic(err)
	}
	return buf.Bytes()
}

func encodePNG(pngBytes []byte) string {
	return base64.StdEncoding.EncodeToString(pngBytes)
}

func doSubmit(t *testing.T, mux *http.ServeMux, body SubmitBody) *httptest.ResponseRecorder {
	t.Helper()
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/submit-solution", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	req.RemoteAddr = "127.0.0.1:1234"
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)
	return w
}

type SubmitBody struct {
	PuzzleID          int    `json:"puzzle_id"`
	PuzzleVersion     string `json:"puzzle_version"`
	InstallID         string `json:"install_id"`
	SolutionPNGBase64 string `json:"solution_png_base64"`
}

func parseSubmitResp(t *testing.T, w *httptest.ResponseRecorder) httpapi.SubmitResponse {
	t.Helper()
	var resp httpapi.SubmitResponse
	if err := json.NewDecoder(w.Body).Decode(&resp); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	return resp
}

// ---------- tests ----------

func TestSubmit_firstSubmission(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()

	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	pngB64 := encodePNG(makePNG(50))
	w := doSubmit(t, mux, SubmitBody{
		PuzzleID:          1,
		PuzzleVersion:     "v1",
		InstallID:         "install-a",
		SolutionPNGBase64: pngB64,
	})

	if w.Code != http.StatusOK {
		t.Fatalf("status: got %d, want 200; body: %s", w.Code, w.Body)
	}
	resp := parseSubmitResp(t, w)
	if !resp.Accepted {
		t.Fatalf("expected accepted=true, got error=%q", resp.Error)
	}
	if resp.CanonicalMetrics == nil {
		t.Fatal("canonical_metrics is nil")
	}
	if resp.CanonicalMetrics.TotalInk != 50 {
		t.Errorf("total_ink: got %d, want 50", resp.CanonicalMetrics.TotalInk)
	}
	if resp.SampleCount != 1 {
		t.Errorf("sample_count: got %d, want 1", resp.SampleCount)
	}
}

func TestSubmit_unknownPuzzle(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	w := doSubmit(t, mux, SubmitBody{
		PuzzleID:          999,
		PuzzleVersion:     "unknown",
		InstallID:         "install-a",
		SolutionPNGBase64: encodePNG(makePNG(1)),
	})

	resp := parseSubmitResp(t, w)
	if resp.Accepted {
		t.Fatal("expected accepted=false for unknown puzzle")
	}
	if resp.Error != "unknown_puzzle_version" {
		t.Errorf("error: got %q, want %q", resp.Error, "unknown_puzzle_version")
	}
}

func TestSubmit_invalidPNG(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	w := doSubmit(t, mux, SubmitBody{
		PuzzleID:          1,
		PuzzleVersion:     "v1",
		InstallID:         "install-a",
		SolutionPNGBase64: base64.StdEncoding.EncodeToString([]byte("not a png")),
	})

	resp := parseSubmitResp(t, w)
	if resp.Accepted {
		t.Fatal("expected accepted=false for invalid PNG")
	}
	if resp.Error != "invalid_png" {
		t.Errorf("error: got %q, want %q", resp.Error, "invalid_png")
	}
}

func TestSubmit_resubmit_improvement(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	installID := "install-improve"

	// First submission: 100 ink pixels.
	doSubmit(t, mux, SubmitBody{1, "v1", installID, encodePNG(makePNG(100))})

	// Second submission: 50 ink pixels — improvement.
	w := doSubmit(t, mux, SubmitBody{1, "v1", installID, encodePNG(makePNG(50))})
	resp := parseSubmitResp(t, w)

	if !resp.Accepted {
		t.Fatalf("expected accepted=true, got error=%q", resp.Error)
	}
	// best_metrics should reflect the improvement.
	if resp.BestMetrics.TotalInk != 50 {
		t.Errorf("best total_ink after improvement: got %d, want 50", resp.BestMetrics.TotalInk)
	}
	// sample_count stays at 1 (same install, only one canonical best counted).
	if resp.SampleCount != 1 {
		t.Errorf("sample_count: got %d, want 1", resp.SampleCount)
	}
}

func TestSubmit_resubmit_noImprovement(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	installID := "install-noimprove"
	doSubmit(t, mux, SubmitBody{1, "v1", installID, encodePNG(makePNG(50))})

	// Re-submit the same (no improvement).
	w := doSubmit(t, mux, SubmitBody{1, "v1", installID, encodePNG(makePNG(50))})
	resp := parseSubmitResp(t, w)

	if !resp.Accepted {
		t.Fatalf("expected accepted=true on re-submit")
	}
	// Best should remain 50.
	if resp.BestMetrics.TotalInk != 50 {
		t.Errorf("best total_ink: got %d, want 50", resp.BestMetrics.TotalInk)
	}
}

func TestSubmit_twoInstalls_sampleCount(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	doSubmit(t, mux, SubmitBody{1, "v1", "install-x", encodePNG(makePNG(10))})
	w := doSubmit(t, mux, SubmitBody{1, "v1", "install-y", encodePNG(makePNG(20))})
	resp := parseSubmitResp(t, w)

	if resp.SampleCount != 2 {
		t.Errorf("sample_count: got %d, want 2", resp.SampleCount)
	}
}

func TestListPuzzles(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/puzzles", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status: got %d, want 200", w.Code)
	}
	var resp httpapi.PuzzlesResponse
	if err := json.NewDecoder(w.Body).Decode(&resp); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if len(resp.Puzzles) != 1 {
		t.Errorf("puzzles count: got %d, want 1", len(resp.Puzzles))
	}
}

func TestHistogramsEndpoint(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	// Seed a submission so histogram has data.
	doSubmit(t, mux, SubmitBody{1, "v1", "install-h", encodePNG(makePNG(30))})

	req := httptest.NewRequest(http.MethodGet,
		"/api/v1/puzzles/1/histograms?puzzle_version=v1&install_id=install-h", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status: got %d, want 200; body: %s", w.Code, w.Body)
	}
	var resp httpapi.HistogramsResponse
	if err := json.NewDecoder(w.Body).Decode(&resp); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if resp.SampleCount != 1 {
		t.Errorf("sample_count: got %d, want 1", resp.SampleCount)
	}
	if resp.PlayerBestMetrics == nil {
		t.Fatal("player_best_metrics is nil")
	}
	if resp.PlayerBestMetrics.TotalInk != 30 {
		t.Errorf("player best total_ink: got %d, want 30", resp.PlayerBestMetrics.TotalInk)
	}
	if _, ok := resp.Histograms["gates"]; !ok {
		t.Error("histograms missing 'gates' key")
	}
}

func TestSubmit_missingFields(t *testing.T) {
	srv, cleanup := makeTestServer(t)
	defer cleanup()
	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	// Missing install_id.
	body := `{"puzzle_id":1,"puzzle_version":"v1","solution_png_base64":"abc"}`
	req := httptest.NewRequest(http.MethodPost, "/api/v1/submit-solution", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req.RemoteAddr = "127.0.0.1:1234"
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	resp := parseSubmitResp(t, w)
	if resp.Accepted {
		t.Fatal("expected accepted=false for missing install_id")
	}
}
