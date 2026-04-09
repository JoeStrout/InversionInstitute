package storage

import (
	"database/sql"
	"fmt"

	_ "modernc.org/sqlite"
)

// Open opens (or creates) the SQLite database at the given path and
// ensures all tables exist.
func Open(path string) (*sql.DB, error) {
	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, fmt.Errorf("open db %q: %w", path, err)
	}
	// SQLite performs best with a single writer; keep connections serialized.
	db.SetMaxOpenConns(1)

	if err := applySchema(db); err != nil {
		db.Close()
		return nil, fmt.Errorf("apply schema: %w", err)
	}
	return db, nil
}

func applySchema(db *sql.DB) error {
	_, err := db.Exec(schema)
	return err
}

const schema = `
PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS puzzles (
    puzzle_id            INTEGER NOT NULL,
    puzzle_version       TEXT    NOT NULL,
    scoring_version      TEXT    NOT NULL,
    title                TEXT,
    is_active            INTEGER NOT NULL DEFAULT 1,
    created_at           TEXT    NOT NULL,
    -- margin defines the player-editable rect; gates outside it are excluded
    -- from coreArea.  Defaults to the full 80x64 image.
    margin_x             INTEGER NOT NULL DEFAULT 0,
    margin_y             INTEGER NOT NULL DEFAULT 0,
    margin_w             INTEGER NOT NULL DEFAULT 80,
    margin_h             INTEGER NOT NULL DEFAULT 64,
    -- histogram display bin config: bin_start = min value of 2nd bin,
    -- bin_size = width of each regular bin.  NULL = not yet configured.
    gates_bin_start      INTEGER,
    gates_bin_size       INTEGER,
    ink_bin_start        INTEGER,
    ink_bin_size         INTEGER,
    area_bin_start       INTEGER,
    area_bin_size        INTEGER,
    PRIMARY KEY (puzzle_id, puzzle_version)
);

CREATE TABLE IF NOT EXISTS submissions (
    submission_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    puzzle_id            INTEGER NOT NULL,
    puzzle_version       TEXT    NOT NULL,
    scoring_version      TEXT    NOT NULL,
    install_id           TEXT    NOT NULL,
    solution_hash        TEXT    NOT NULL,
    canonical_png        BLOB    NOT NULL,
    gates                INTEGER NOT NULL,
    total_ink            INTEGER NOT NULL,
    core_area            INTEGER NOT NULL,
    submitted_at         TEXT    NOT NULL,
    client_game_version  TEXT,
    client_platform      TEXT,
    client_ip_hash       TEXT,
    accepted             INTEGER NOT NULL DEFAULT 1,
    reject_reason        TEXT,
    FOREIGN KEY (puzzle_id, puzzle_version)
        REFERENCES puzzles (puzzle_id, puzzle_version)
);

CREATE INDEX IF NOT EXISTS idx_submissions_puzzle_version
    ON submissions (puzzle_id, puzzle_version);

CREATE INDEX IF NOT EXISTS idx_submissions_install_puzzle_version
    ON submissions (install_id, puzzle_id, puzzle_version);

CREATE INDEX IF NOT EXISTS idx_submissions_solution_hash
    ON submissions (solution_hash);

CREATE TABLE IF NOT EXISTS player_puzzle_state (
    puzzle_id                 INTEGER NOT NULL,
    puzzle_version            TEXT    NOT NULL,
    scoring_version           TEXT    NOT NULL,
    install_id                TEXT    NOT NULL,

    latest_submission_id      INTEGER NOT NULL,
    latest_solution_hash      TEXT    NOT NULL,
    latest_gates              INTEGER NOT NULL,
    latest_total_ink          INTEGER NOT NULL,
    latest_core_area          INTEGER NOT NULL,
    latest_submitted_at       TEXT    NOT NULL,

    best_gates_submission_id  INTEGER NOT NULL,
    best_gates_solution_hash  TEXT    NOT NULL,
    best_gates                INTEGER NOT NULL,
    best_gates_at             TEXT    NOT NULL,

    best_ink_submission_id    INTEGER NOT NULL,
    best_ink_solution_hash    TEXT    NOT NULL,
    best_total_ink            INTEGER NOT NULL,
    best_ink_at               TEXT    NOT NULL,

    best_area_submission_id   INTEGER NOT NULL,
    best_area_solution_hash   TEXT    NOT NULL,
    best_core_area            INTEGER NOT NULL,
    best_area_at              TEXT    NOT NULL,

    submission_count          INTEGER NOT NULL DEFAULT 1,

    PRIMARY KEY (puzzle_id, puzzle_version, install_id)
);

CREATE TABLE IF NOT EXISTS histogram_counts (
    puzzle_id             INTEGER NOT NULL,
    puzzle_version        TEXT    NOT NULL,
    scoring_version       TEXT    NOT NULL,
    metric_name           TEXT    NOT NULL,
    -- Each row stores the count for one exact integer value.
    -- min_value = exact metric value; max_value = min_value + 1 (always).
    min_value             INTEGER NOT NULL,
    max_value             INTEGER,
    count                 INTEGER NOT NULL DEFAULT 0,
    updated_at            TEXT    NOT NULL,
    PRIMARY KEY (puzzle_id, puzzle_version, scoring_version, metric_name, min_value)
);
`
