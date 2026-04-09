package httpapi

// SubmitRequest is the JSON body for POST /api/v1/submit-solution.
type SubmitRequest struct {
	PuzzleID          int    `json:"puzzle_id"`
	PuzzleVersion     string `json:"puzzle_version"`
	InstallID         string `json:"install_id"`
	ClientGameVersion string `json:"client_game_version"`
	ClientPlatform    string `json:"client_platform"`
	SolutionPNGBase64 string `json:"solution_png_base64"`
}

// SubmitResponse is returned by POST /api/v1/submit-solution.
type SubmitResponse struct {
	Accepted         bool              `json:"accepted"`
	Error            string            `json:"error,omitempty"`
	PuzzleID         int               `json:"puzzle_id,omitempty"`
	PuzzleVersion    string            `json:"puzzle_version,omitempty"`
	ScoringVersion   string            `json:"scoring_version,omitempty"`
	BucketSetVersion string            `json:"bucket_set_version,omitempty"`
	CanonicalMetrics *MetricValues     `json:"canonical_metrics,omitempty"`
	BestMetrics      *MetricValues     `json:"best_metrics,omitempty"`
	SampleCount      int               `json:"sample_count,omitempty"`
	Percentiles      *MetricPercentiles `json:"percentiles,omitempty"`
	Histograms       map[string][]BucketEntry `json:"histograms,omitempty"`
}

// HistogramsResponse is returned by GET /api/v1/puzzles/{id}/histograms.
type HistogramsResponse struct {
	PuzzleID         int               `json:"puzzle_id"`
	PuzzleVersion    string            `json:"puzzle_version"`
	ScoringVersion   string            `json:"scoring_version"`
	BucketSetVersion string            `json:"bucket_set_version"`
	SampleCount      int               `json:"sample_count"`
	Histograms       map[string][]BucketEntry `json:"histograms"`
	PlayerBestMetrics *MetricValues    `json:"player_best_metrics,omitempty"`
	Percentiles      *MetricPercentiles `json:"percentiles,omitempty"`
}

// PuzzlesResponse is returned by GET /api/v1/puzzles.
type PuzzlesResponse struct {
	Puzzles []PuzzleEntry `json:"puzzles"`
}

type PuzzleEntry struct {
	PuzzleID       int    `json:"puzzle_id"`
	PuzzleVersion  string `json:"puzzle_version"`
	ScoringVersion string `json:"scoring_version"`
	Title          string `json:"title"`
	IsActive       bool   `json:"is_active"`
}

type MetricValues struct {
	Gates    int `json:"gates"`
	TotalInk int `json:"total_ink"`
	CoreArea int `json:"core_area"`
}

type MetricPercentiles struct {
	Gates    float64 `json:"gates"`
	TotalInk float64 `json:"total_ink"`
	CoreArea float64 `json:"core_area"`
}

type BucketEntry struct {
	MinValue int `json:"min_value"`
	Count    int `json:"count"`
}
