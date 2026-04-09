// seed initializes the database and inserts a puzzle row.
// Usage: go run ./cmd/seed --config config.local.yaml --puzzle-id 1 --puzzle-version v1 --title "Test Puzzle"
package main

import (
	"flag"
	"log"
	"time"

	"scoreserver/internal/config"
	"scoreserver/internal/storage"
)

func main() {
	cfgPath := flag.String("config", "config.local.yaml", "path to config YAML file")
	puzzleID := flag.Int("puzzle-id", 1, "puzzle ID")
	puzzleVersion := flag.String("puzzle-version", "v1", "puzzle version string")
	scoringVersion := flag.String("scoring-version", "v1", "scoring version string")
	title := flag.String("title", "", "puzzle title")
	marginX := flag.Int("margin-x", 0, "margin rect left edge (MiniScript coords)")
	marginY := flag.Int("margin-y", 0, "margin rect bottom edge (MiniScript coords)")
	marginW := flag.Int("margin-w", 80, "margin rect width")
	marginH := flag.Int("margin-h", 64, "margin rect height")
	// Histogram display bin config.  Use -1 to leave a field unset (NULL).
	gatesBinStart := flag.Int("gates-bin-start", -1, "gates histogram bin start (-1 = unset)")
	gatesBinSize := flag.Int("gates-bin-size", -1, "gates histogram bin size  (-1 = unset)")
	inkBinStart := flag.Int("ink-bin-start", -1, "total_ink histogram bin start (-1 = unset)")
	inkBinSize := flag.Int("ink-bin-size", -1, "total_ink histogram bin size  (-1 = unset)")
	areaBinStart := flag.Int("area-bin-start", -1, "core_area histogram bin start (-1 = unset)")
	areaBinSize := flag.Int("area-bin-size", -1, "core_area histogram bin size  (-1 = unset)")
	flag.Parse()

	cfg, err := config.Load(*cfgPath)
	if err != nil {
		log.Fatalf("config: %v", err)
	}

	db, err := storage.Open(cfg.DB.Path)
	if err != nil {
		log.Fatalf("db: %v", err)
	}
	defer db.Close()

	p := storage.Puzzle{
		PuzzleID:       *puzzleID,
		PuzzleVersion:  *puzzleVersion,
		ScoringVersion: *scoringVersion,
		Title:          *title,
		IsActive:       true,
		CreatedAt:      time.Now(),
		MarginX:        *marginX,
		MarginY:        *marginY,
		MarginW:        *marginW,
		MarginH:        *marginH,
		GatesBinStart:  intOrNil(*gatesBinStart),
		GatesBinSize:   intOrNil(*gatesBinSize),
		InkBinStart:    intOrNil(*inkBinStart),
		InkBinSize:     intOrNil(*inkBinSize),
		AreaBinStart:   intOrNil(*areaBinStart),
		AreaBinSize:    intOrNil(*areaBinSize),
	}
	if err := storage.InsertPuzzle(db, p); err != nil {
		log.Fatalf("insert puzzle: %v", err)
	}
	log.Printf("inserted puzzle %d / %q (%s) into %s", p.PuzzleID, p.PuzzleVersion, p.Title, cfg.DB.Path)
}

func intOrNil(v int) *int {
	if v < 0 {
		return nil
	}
	return &v
}
