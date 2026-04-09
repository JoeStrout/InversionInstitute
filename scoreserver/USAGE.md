# scoreserver — Usage Guide

## 1. Running the unit tests

```bash
cd scoreserver
go test ./...
```

The scoring package tests include synthetic PNG tests and a real circuit fixture
(`internal/scoring/testdata/circuit-7.png`).  To run only the scoring tests:

```bash
go test ./internal/scoring/...
```

To run with verbose output:

```bash
go test -v ./...
```

---

## 2. Manual end-to-end testing with curl

### 2a. Start the server

```bash
cd scoreserver
go run ./cmd/server --config config.local.yaml
```

The server listens on `:8080` by default.  `config.local.yaml` points to
`./dev.db` and uses relaxed rate limits (300 req/min) suitable for local testing.

### 2b. Seed a puzzle row

The database is created automatically on first start, but it has no puzzle rows.
Insert one with the `seed` tool:

```bash
go run ./cmd/seed \
  --config config.local.yaml \
  --puzzle-id 7 \
  --puzzle-version v1 \
  --scoring-version v1 \
  --title "7. Latch" \
  --margin-x 18 --margin-y 0 --margin-w 44 --margin-h 64
```

`margin-x/y/w/h` are in MiniScript display coordinates (y=0 at the
bottom-left of the circuit picture).  The server converts them to PNG
coordinates automatically.  For puzzles with no restricted margin (the
player can edit the whole canvas), use the defaults: `0 0 80 64`.

Or use `bash scripts/seed_puzzles.sh` to insert all the puzzles at once.

### 2c. Submit a solution PNG

```bash
bash scripts/submit_test.sh internal/scoring/testdata/circuit-7.png 7 v1 my-install-id
```

The script base64-encodes the PNG, posts it as JSON to
`POST /api/v1/submit-solution`, and pretty-prints the response.

You can also use curl directly:

```bash
PNG_B64=$(base64 < internal/scoring/testdata/circuit-7.png | tr -d '\n')

curl -s -X POST http://localhost:8080/api/v1/submit-solution \
  -H "Content-Type: application/json" \
  -d "{
    \"puzzle_id\": 7,
    \"puzzle_version\": \"v1\",
    \"install_id\": \"my-install-id\",
    \"client_platform\": \"dev\",
    \"solution_png_base64\": \"$PNG_B64\"
  }" | python3 -m json.tool
```

A successful response looks like:

```json
{
  "accepted": true,
  "puzzle_id": 7,
  "puzzle_version": "v1",
  "scoring_version": "v1",
  "bucket_set_version": "v1",
  "canonical_metrics": { "gates": 10, "total_ink": 433, "core_area": 228 },
  "best_metrics":      { "gates": 10, "total_ink": 433, "core_area": 228 },
  "sample_count": 1,
  "percentiles": { "gates": 0, "total_ink": 0, "core_area": 0 },
  "histograms": { ... }
}
```

### 2d. Fetch the histogram without submitting

```bash
curl -s "http://localhost:8080/api/v1/puzzles/7/histograms?puzzle_version=v1" \
  | python3 -m json.tool
```

To include a player's best metrics in the response, add `&install_id=<id>`:

```bash
curl -s "http://localhost:8080/api/v1/puzzles/7/histograms?puzzle_version=v1&install_id=my-install-id" \
  | python3 -m json.tool
```

### 2e. List active puzzles

```bash
curl -s http://localhost:8080/api/v1/puzzles | python3 -m json.tool
```

---

## 3. Administrative operations

All admin operations run locally (directly against the SQLite file) — there
are no admin HTTP endpoints.

### 3a. Inspect the database with sqlite3

```bash
sqlite3 dev.db
```

Useful queries:

```sql
-- How many submissions per puzzle?
SELECT puzzle_id, puzzle_version, COUNT(*) FROM submissions GROUP BY 1, 2;

-- Current histogram counts for puzzle 7:
SELECT metric_name, min_value, max_value, count
FROM histogram_counts
WHERE puzzle_id = 7 AND puzzle_version = 'v1'
ORDER BY metric_name, min_value;

-- Best scores per player for puzzle 7:
SELECT install_id, best_gates, best_total_ink, best_core_area
FROM player_puzzle_state
WHERE puzzle_id = 7 AND puzzle_version = 'v1'
ORDER BY best_gates, best_total_ink;
```

### 3b. Deactivate or update a puzzle

The `puzzles` table uses `(puzzle_id, puzzle_version)` as its primary key.
To retire a puzzle version and add a new one:

```sql
-- Deactivate the old version:
UPDATE puzzles SET is_active = 0
WHERE puzzle_id = 7 AND puzzle_version = 'v1';
```

Then seed the new version:

```bash
go run ./cmd/seed \
  --config config.local.yaml \
  --puzzle-id 7 \
  --puzzle-version v2 \
  --scoring-version v1 \
  --title "7. Latch (revised)" \
  --margin-x 18 --margin-y 0 --margin-w 44 --margin-h 64
```

### 3c. Rebuild histograms after changing the bucket config

If you change the `buckets` section of the config (e.g. to split or merge
`total_ink` or `core_area` bins), the existing `histogram_counts` rows will be
stale.  The recommended recovery procedure is:

1. Stop the server.
2. Delete the stale histogram rows for the affected puzzle/version:

   ```sql
   DELETE FROM histogram_counts
   WHERE puzzle_id = 7 AND puzzle_version = 'v1'
     AND bucket_set_version = 'v1';
   ```

3. Bump the `buckets.version` value in the config file (e.g. `v1` → `v2`).
   The server uses this version as a key for all histogram rows, so old rows
   are simply ignored and new ones are created fresh as players resubmit.

4. Restart the server with the new config.

If you need to pre-populate the new buckets from existing player data without
waiting for resubmits, run a one-off Go program that:
- reads every row from `player_puzzle_state`,
- maps each player's best values to the new buckets, and
- inserts/increments `histogram_counts` rows directly.

(No such tool exists in the repo yet; see the plan for a future `cmd/rebuild`
tool.)

### 3d. Start fresh (wipe dev database)

```bash
rm dev.db
go run ./cmd/server --config config.local.yaml   # schema is recreated automatically
go run ./cmd/seed --config config.local.yaml --puzzle-id 7 ...
```

Or use `bash scripts/seed_puzzles.sh` to insert all the puzzles at once.

