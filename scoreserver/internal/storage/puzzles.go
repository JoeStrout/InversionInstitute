package storage

import (
	"database/sql"
	"fmt"
	"image"
	"time"
)

// Puzzle mirrors a row in the puzzles table.
type Puzzle struct {
	PuzzleID       int
	PuzzleVersion  string
	ScoringVersion string
	Title          string
	IsActive       bool
	CreatedAt      time.Time
	// Margin is the player-editable area; gates outside it are excluded from
	// coreArea.  Defaults to the full 80×64 image when not specified.
	MarginX int
	MarginY int
	MarginW int
	MarginH int
}

// GetActivePuzzle returns the puzzle row for (puzzleID, puzzleVersion) only if
// is_active = 1.  Returns sql.ErrNoRows if not found or inactive.
func GetActivePuzzle(db *sql.DB, puzzleID int, puzzleVersion string) (*Puzzle, error) {
	row := db.QueryRow(`
		SELECT puzzle_id, puzzle_version, scoring_version, COALESCE(title,''), is_active, created_at,
		       margin_x, margin_y, margin_w, margin_h
		FROM puzzles
		WHERE puzzle_id = ? AND puzzle_version = ? AND is_active = 1`,
		puzzleID, puzzleVersion)

	var p Puzzle
	var createdAt string
	err := row.Scan(&p.PuzzleID, &p.PuzzleVersion, &p.ScoringVersion,
		&p.Title, &p.IsActive, &createdAt,
		&p.MarginX, &p.MarginY, &p.MarginW, &p.MarginH)
	if err != nil {
		return nil, err
	}
	p.CreatedAt, _ = time.Parse(time.RFC3339, createdAt)
	return &p, nil
}

// ListActivePuzzles returns all active puzzles.
func ListActivePuzzles(db *sql.DB) ([]Puzzle, error) {
	rows, err := db.Query(`
		SELECT puzzle_id, puzzle_version, scoring_version, COALESCE(title,''), is_active, created_at,
		       margin_x, margin_y, margin_w, margin_h
		FROM puzzles
		WHERE is_active = 1
		ORDER BY puzzle_id, puzzle_version`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var puzzles []Puzzle
	for rows.Next() {
		var p Puzzle
		var createdAt string
		if err := rows.Scan(&p.PuzzleID, &p.PuzzleVersion, &p.ScoringVersion,
			&p.Title, &p.IsActive, &createdAt,
			&p.MarginX, &p.MarginY, &p.MarginW, &p.MarginH); err != nil {
			return nil, err
		}
		p.CreatedAt, _ = time.Parse(time.RFC3339, createdAt)
		puzzles = append(puzzles, p)
	}
	return puzzles, rows.Err()
}

// InsertPuzzle inserts a new puzzle row (used for seeding / admin scripts).
func InsertPuzzle(db *sql.DB, p Puzzle) error {
	_, err := db.Exec(`
		INSERT INTO puzzles (puzzle_id, puzzle_version, scoring_version, title, is_active, created_at,
		                     margin_x, margin_y, margin_w, margin_h)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		p.PuzzleID, p.PuzzleVersion, p.ScoringVersion, p.Title,
		boolToInt(p.IsActive), p.CreatedAt.UTC().Format(time.RFC3339),
		p.MarginX, p.MarginY, p.MarginW, p.MarginH)
	if err != nil {
		return fmt.Errorf("insert puzzle: %w", err)
	}
	return nil
}

// MarginRect converts the puzzle's margin (stored in MiniScript display
// coordinates, where y=0 is the bottom-left) to a Go image.Rectangle
// (where y=0 is the top-left, matching PNG row ordering).
//
// Conversion: pngMinY = imgHeight − (msY + msH)
//
// For a full-height margin (msY=0, msH=imgHeight) the result is the same
// regardless of the flip.
func (p *Puzzle) MarginRect(imgHeight int) image.Rectangle {
	pngMinY := imgHeight - (p.MarginY + p.MarginH)
	pngMaxY := imgHeight - p.MarginY
	return image.Rect(p.MarginX, pngMinY, p.MarginX+p.MarginW, pngMaxY)
}

func boolToInt(b bool) int {
	if b {
		return 1
	}
	return 0
}
