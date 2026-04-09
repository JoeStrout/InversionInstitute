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
	// Histogram display bin config.  BinStart is the minimum value of the
	// second bin (bin 0 is a catch-all for anything below it).  BinSize is the
	// width of each regular bin.  nil means not yet configured.
	GatesBinStart *int
	GatesBinSize  *int
	InkBinStart   *int
	InkBinSize    *int
	AreaBinStart  *int
	AreaBinSize   *int
}

const puzzleSelectCols = `
	puzzle_id, puzzle_version, scoring_version, COALESCE(title,''), is_active, created_at,
	margin_x, margin_y, margin_w, margin_h,
	gates_bin_start, gates_bin_size, ink_bin_start, ink_bin_size, area_bin_start, area_bin_size`

func scanPuzzle(scan func(...any) error) (Puzzle, error) {
	var p Puzzle
	var createdAt string
	var gbs, gbz, ibs, ibz, abs_, abz sql.NullInt64
	err := scan(
		&p.PuzzleID, &p.PuzzleVersion, &p.ScoringVersion,
		&p.Title, &p.IsActive, &createdAt,
		&p.MarginX, &p.MarginY, &p.MarginW, &p.MarginH,
		&gbs, &gbz, &ibs, &ibz, &abs_, &abz,
	)
	if err != nil {
		return Puzzle{}, err
	}
	p.CreatedAt, _ = time.Parse(time.RFC3339, createdAt)
	p.GatesBinStart = nullIntPtr(gbs)
	p.GatesBinSize = nullIntPtr(gbz)
	p.InkBinStart = nullIntPtr(ibs)
	p.InkBinSize = nullIntPtr(ibz)
	p.AreaBinStart = nullIntPtr(abs_)
	p.AreaBinSize = nullIntPtr(abz)
	return p, nil
}

// GetActivePuzzle returns the puzzle row for (puzzleID, puzzleVersion) only if
// is_active = 1.  Returns sql.ErrNoRows if not found or inactive.
func GetActivePuzzle(db *sql.DB, puzzleID int, puzzleVersion string) (*Puzzle, error) {
	row := db.QueryRow(`SELECT`+puzzleSelectCols+`
		FROM puzzles
		WHERE puzzle_id = ? AND puzzle_version = ? AND is_active = 1`,
		puzzleID, puzzleVersion)

	p, err := scanPuzzle(row.Scan)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

// ListActivePuzzles returns all active puzzles.
func ListActivePuzzles(db *sql.DB) ([]Puzzle, error) {
	rows, err := db.Query(`SELECT` + puzzleSelectCols + `
		FROM puzzles WHERE is_active = 1 ORDER BY puzzle_id, puzzle_version`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var puzzles []Puzzle
	for rows.Next() {
		p, err := scanPuzzle(rows.Scan)
		if err != nil {
			return nil, err
		}
		puzzles = append(puzzles, p)
	}
	return puzzles, rows.Err()
}

// InsertPuzzle inserts a new puzzle row (used for seeding / admin scripts).
func InsertPuzzle(db *sql.DB, p Puzzle) error {
	_, err := db.Exec(`
		INSERT INTO puzzles (
			puzzle_id, puzzle_version, scoring_version, title, is_active, created_at,
			margin_x, margin_y, margin_w, margin_h,
			gates_bin_start, gates_bin_size, ink_bin_start, ink_bin_size, area_bin_start, area_bin_size
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		p.PuzzleID, p.PuzzleVersion, p.ScoringVersion, p.Title,
		boolToInt(p.IsActive), p.CreatedAt.UTC().Format(time.RFC3339),
		p.MarginX, p.MarginY, p.MarginW, p.MarginH,
		nullableInt(p.GatesBinStart), nullableInt(p.GatesBinSize),
		nullableInt(p.InkBinStart), nullableInt(p.InkBinSize),
		nullableInt(p.AreaBinStart), nullableInt(p.AreaBinSize),
	)
	if err != nil {
		return fmt.Errorf("insert puzzle: %w", err)
	}
	return nil
}

// MarginRect converts the puzzle's margin (stored in MiniScript display
// coordinates, where y=0 is the bottom-left) to a Go image.Rectangle
// (where y=0 is the top-left, matching PNG row ordering).
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

func nullableInt(p *int) interface{} {
	if p == nil {
		return nil
	}
	return *p
}

func nullIntPtr(n sql.NullInt64) *int {
	if !n.Valid {
		return nil
	}
	v := int(n.Int64)
	return &v
}
