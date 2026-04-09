#!/usr/bin/env bash
# seed_puzzles.sh — Insert all puzzle rows into the database.
# Run from the scoreserver/ directory:
#   bash scripts/seed_puzzles.sh [--config config.local.yaml]
#
# Chapter 1 (Introduction) has no circuit puzzle and is omitted.
# Margin values are taken from each chapter's context.ms (MiniScript coords).
# Bin config values are initial estimates; tune with scripts/configure_bins.sh.

set -euo pipefail

CONFIG="${1:---config}"; CONFIG_VAL="${2:-config.local.yaml}"
if [[ "$CONFIG" != "--config" ]]; then
  CONFIG_VAL="$CONFIG"
  CONFIG="--config"
fi

seed() {
  # Args: id title mx my mw mh  gates_start gates_size  ink_start ink_size  area_start area_size
  go run ./cmd/seed "$CONFIG" "$CONFIG_VAL" \
    --puzzle-id "$1" --puzzle-version v1 --scoring-version v1 \
    --title "$2" \
    --margin-x "$3" --margin-y "$4" --margin-w "$5" --margin-h "$6" \
    --gates-bin-start "$7"  --gates-bin-size "$8" \
    --ink-bin-start   "$9"  --ink-bin-size   "${10}" \
    --area-bin-start  "${11}" --area-bin-size "${12}"
}

#       id  title                          mx  my  mw  mh   gs gz  is  iz  as   az
seed  2  "Recess is Over"               11   0  34  64    1  1  50  25  25   50
seed  3  "Mrs. Oarsley's Children"      17   0  31  64    1  1  50  25  25   50
seed  4  "0/1 Display"                  19   0  40  64    1  1  50  25  25   50
seed  5  "Andi's Gate"                  14   0  51  64    2  1  75  25  50   50
seed  6  "Majority Rule"                14   0  51  64    3  1 100  25  75   75
seed  7  "Latch Set & Reset"            18   0  44  64    5  1 150  25 100  100
seed  8  "Quiz Game"                    14   0  52  64    8  1 200  25 150  100
seed  9  "Ex-Oarsley's Discord Alert"   18   0  46  64    5  1 150  25 100  100
seed 10  "2-Bit Counter"                12   0  56  64    8  1 200  25 150  100
seed 11  "Color Mixer"                  12   0  56  64   10  1 250  25 200  100
seed 12  "3-Bit Counter (Full Adder)"   12   0  56  64   10  1 250  25 200  100
seed 13  "3-Bit Decoder"                 7   9  73  55   15  1 300  50 300  100
seed 14  "7-Segment Display"             7   0  50  64   15  1 300  50 300  100
seed 15  "Edge Pulse Generator"         21   0  39  64   10  1 200  25 150  100

echo "Done — all 14 puzzle rows inserted."
