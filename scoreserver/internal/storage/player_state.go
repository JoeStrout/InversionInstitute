package storage

import (
	"database/sql"
	"fmt"
	"time"
)

// PlayerPuzzleState mirrors a row in the player_puzzle_state table.
type PlayerPuzzleState struct {
	PuzzleID       int
	PuzzleVersion  string
	ScoringVersion string
	InstallID      string

	LatestSubmissionID  int64
	LatestSolutionHash  string
	LatestGates         int
	LatestTotalInk      int
	LatestCoreArea      int
	LatestSubmittedAt   time.Time

	BestGatesSubmissionID int64
	BestGatesSolutionHash string
	BestGates             int
	BestGatesAt           time.Time

	BestInkSubmissionID int64
	BestInkSolutionHash string
	BestTotalInk        int
	BestInkAt           time.Time

	BestAreaSubmissionID int64
	BestAreaSolutionHash string
	BestCoreArea         int
	BestAreaAt           time.Time

	SubmissionCount int
}

// GetPlayerState reads the current state for (puzzleID, puzzleVersion, installID).
// Returns nil, nil if no row exists yet.
func GetPlayerState(tx *sql.Tx, puzzleID int, puzzleVersion, installID string) (*PlayerPuzzleState, error) {
	row := tx.QueryRow(`
		SELECT
			puzzle_id, puzzle_version, scoring_version, install_id,
			latest_submission_id, latest_solution_hash,
			latest_gates, latest_total_ink, latest_core_area, latest_submitted_at,
			best_gates_submission_id, best_gates_solution_hash, best_gates, best_gates_at,
			best_ink_submission_id,  best_ink_solution_hash,  best_total_ink, best_ink_at,
			best_area_submission_id, best_area_solution_hash, best_core_area, best_area_at,
			submission_count
		FROM player_puzzle_state
		WHERE puzzle_id = ? AND puzzle_version = ? AND install_id = ?`,
		puzzleID, puzzleVersion, installID)

	var s PlayerPuzzleState
	var latestAt, bestGatesAt, bestInkAt, bestAreaAt string
	err := row.Scan(
		&s.PuzzleID, &s.PuzzleVersion, &s.ScoringVersion, &s.InstallID,
		&s.LatestSubmissionID, &s.LatestSolutionHash,
		&s.LatestGates, &s.LatestTotalInk, &s.LatestCoreArea, &latestAt,
		&s.BestGatesSubmissionID, &s.BestGatesSolutionHash, &s.BestGates, &bestGatesAt,
		&s.BestInkSubmissionID, &s.BestInkSolutionHash, &s.BestTotalInk, &bestInkAt,
		&s.BestAreaSubmissionID, &s.BestAreaSolutionHash, &s.BestCoreArea, &bestAreaAt,
		&s.SubmissionCount,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get player state: %w", err)
	}
	s.LatestSubmittedAt, _ = time.Parse(time.RFC3339, latestAt)
	s.BestGatesAt, _ = time.Parse(time.RFC3339, bestGatesAt)
	s.BestInkAt, _ = time.Parse(time.RFC3339, bestInkAt)
	s.BestAreaAt, _ = time.Parse(time.RFC3339, bestAreaAt)
	return &s, nil
}

// UpsertPlayerState inserts or replaces the player state row inside a transaction.
func UpsertPlayerState(tx *sql.Tx, s *PlayerPuzzleState) error {
	_, err := tx.Exec(`
		INSERT INTO player_puzzle_state (
			puzzle_id, puzzle_version, scoring_version, install_id,
			latest_submission_id, latest_solution_hash,
			latest_gates, latest_total_ink, latest_core_area, latest_submitted_at,
			best_gates_submission_id, best_gates_solution_hash, best_gates, best_gates_at,
			best_ink_submission_id,  best_ink_solution_hash,  best_total_ink, best_ink_at,
			best_area_submission_id, best_area_solution_hash, best_core_area, best_area_at,
			submission_count
		) VALUES (
			?, ?, ?, ?,
			?, ?, ?, ?, ?, ?,
			?, ?, ?, ?,
			?, ?, ?, ?,
			?, ?, ?, ?,
			?
		)
		ON CONFLICT(puzzle_id, puzzle_version, install_id) DO UPDATE SET
			scoring_version          = excluded.scoring_version,
			latest_submission_id     = excluded.latest_submission_id,
			latest_solution_hash     = excluded.latest_solution_hash,
			latest_gates             = excluded.latest_gates,
			latest_total_ink         = excluded.latest_total_ink,
			latest_core_area         = excluded.latest_core_area,
			latest_submitted_at      = excluded.latest_submitted_at,
			best_gates_submission_id = excluded.best_gates_submission_id,
			best_gates_solution_hash = excluded.best_gates_solution_hash,
			best_gates               = excluded.best_gates,
			best_gates_at            = excluded.best_gates_at,
			best_ink_submission_id   = excluded.best_ink_submission_id,
			best_ink_solution_hash   = excluded.best_ink_solution_hash,
			best_total_ink           = excluded.best_total_ink,
			best_ink_at              = excluded.best_ink_at,
			best_area_submission_id  = excluded.best_area_submission_id,
			best_area_solution_hash  = excluded.best_area_solution_hash,
			best_core_area           = excluded.best_core_area,
			best_area_at             = excluded.best_area_at,
			submission_count         = excluded.submission_count`,
		s.PuzzleID, s.PuzzleVersion, s.ScoringVersion, s.InstallID,
		s.LatestSubmissionID, s.LatestSolutionHash,
		s.LatestGates, s.LatestTotalInk, s.LatestCoreArea,
		s.LatestSubmittedAt.UTC().Format(time.RFC3339),
		s.BestGatesSubmissionID, s.BestGatesSolutionHash, s.BestGates,
		s.BestGatesAt.UTC().Format(time.RFC3339),
		s.BestInkSubmissionID, s.BestInkSolutionHash, s.BestTotalInk,
		s.BestInkAt.UTC().Format(time.RFC3339),
		s.BestAreaSubmissionID, s.BestAreaSolutionHash, s.BestCoreArea,
		s.BestAreaAt.UTC().Format(time.RFC3339),
		s.SubmissionCount,
	)
	if err != nil {
		return fmt.Errorf("upsert player state: %w", err)
	}
	return nil
}
