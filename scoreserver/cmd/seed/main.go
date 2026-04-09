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
	marginX := flag.Int("margin-x", 0, "margin rect left edge (default: 0)")
	marginY := flag.Int("margin-y", 0, "margin rect top edge (default: 0)")
	marginW := flag.Int("margin-w", 80, "margin rect width (default: 80)")
	marginH := flag.Int("margin-h", 64, "margin rect height (default: 64)")
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
	}
	if err := storage.InsertPuzzle(db, p); err != nil {
		log.Fatalf("insert puzzle: %v", err)
	}
	log.Printf("inserted puzzle %d / %q (%s) into %s", p.PuzzleID, p.PuzzleVersion, p.Title, cfg.DB.Path)
}
