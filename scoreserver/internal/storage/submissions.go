package storage

import (
	"database/sql"
	"fmt"
	"time"
)

// Submission mirrors a row in the submissions table.
type Submission struct {
	SubmissionID      int64
	PuzzleID          int
	PuzzleVersion     string
	ScoringVersion    string
	InstallID         string
	SolutionHash      string
	CanonicalPNG      []byte
	Gates             int
	TotalInk          int
	CoreArea          int
	SubmittedAt       time.Time
	ClientGameVersion string
	ClientPlatform    string
	ClientIPHash      string
}

// InsertSubmission inserts a new submission row inside an existing transaction
// and returns the auto-assigned submission_id.
func InsertSubmission(tx *sql.Tx, s Submission) (int64, error) {
	res, err := tx.Exec(`
		INSERT INTO submissions (
			puzzle_id, puzzle_version, scoring_version,
			install_id, solution_hash, canonical_png,
			gates, total_ink, core_area,
			submitted_at, client_game_version, client_platform, client_ip_hash,
			accepted
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
		s.PuzzleID, s.PuzzleVersion, s.ScoringVersion,
		s.InstallID, s.SolutionHash, s.CanonicalPNG,
		s.Gates, s.TotalInk, s.CoreArea,
		s.SubmittedAt.UTC().Format(time.RFC3339),
		nullString(s.ClientGameVersion), nullString(s.ClientPlatform), nullString(s.ClientIPHash))
	if err != nil {
		return 0, fmt.Errorf("insert submission: %w", err)
	}
	id, err := res.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("last insert id: %w", err)
	}
	return id, nil
}

func nullString(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}
