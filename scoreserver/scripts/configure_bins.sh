#!/usr/bin/env bash
# scripts/configure_bins.sh
# Interactively update histogram display bin config for a puzzle metric,
# and preview the resulting 9-bin breakdown before committing.
#
# Requires: sqlite3, python3
# Run from scoreserver/: bash scripts/configure_bins.sh [config.local.yaml]

set -euo pipefail

CONFIG="${1:-config.local.yaml}"

DB=$(python3 -c "
import re, sys
txt = open('$CONFIG').read()
m = re.search(r'path:\s*[\"\'"]?([^\s\"\']+)', txt)
if not m:
    sys.exit('cannot find db.path in $CONFIG')
print(m.group(1))
")

[ -f "$DB" ] || { echo "Database not found: $DB" >&2; exit 1; }

q() { sqlite3 -separator '|' "$DB" "$@"; }

# ---------- Select puzzle ----------
echo ""
echo "Active puzzles:"
echo ""

declare -a P_IDS P_VERS P_TITLES
n=0
while IFS='|' read -r pid pver title; do
    P_IDS[n]=$pid
    P_VERS[n]=$pver
    P_TITLES[n]="$title"
    printf "  %2d) [%2d] %-40s (%s)\n" $((n+1)) "$pid" "$title" "$pver"
    n=$((n+1))
done < <(q "SELECT puzzle_id, puzzle_version, COALESCE(title,'(no title)')
            FROM puzzles WHERE is_active=1 ORDER BY puzzle_id, puzzle_version")

[ $n -eq 0 ] && { echo "No active puzzles found in $DB." >&2; exit 1; }

echo ""
read -rp "Select puzzle [1-$n]: " SEL
[[ "$SEL" =~ ^[1-9][0-9]*$ ]] && [ "$SEL" -le "$n" ] || { echo "Invalid selection."; exit 1; }
idx=$((SEL-1))
PID="${P_IDS[$idx]}"
PVER="${P_VERS[$idx]}"
echo "→ ${P_TITLES[$idx]} (puzzle $PID / $PVER)"

# ---------- Select metric ----------
echo ""
echo "  1) gates"
echo "  2) total_ink"
echo "  3) core_area"
echo ""
read -rp "Select metric [1-3]: " MSEL
case $MSEL in
    1) METRIC=gates;     SCOL=gates_bin_start; ZCOL=gates_bin_size ;;
    2) METRIC=total_ink; SCOL=ink_bin_start;   ZCOL=ink_bin_size   ;;
    3) METRIC=core_area; SCOL=area_bin_start;  ZCOL=area_bin_size  ;;
    *) echo "Invalid selection."; exit 1 ;;
esac

# Show current config
CUR=$(q "SELECT COALESCE($SCOL,''), COALESCE($ZCOL,'')
         FROM puzzles WHERE puzzle_id=$PID AND puzzle_version='$PVER'")
CUR_START=$(echo "$CUR" | cut -d'|' -f1)
CUR_SIZE=$(echo "$CUR"  | cut -d'|' -f2)

echo ""
if [ -n "$CUR_START" ] && [ -n "$CUR_SIZE" ]; then
    echo "Current config: bin_start=$CUR_START  bin_size=$CUR_SIZE"
else
    echo "Current config: (not yet configured)"
fi

# ---------- Prompt for new values ----------
echo ""
START_PROMPT="New bin_start (min value of 2nd bin)"
SIZE_PROMPT="New bin_size"
[ -n "$CUR_START" ] && START_PROMPT+=" [$CUR_START]"
[ -n "$CUR_SIZE"  ] && SIZE_PROMPT+=" [$CUR_SIZE]"

read -rp "$START_PROMPT: " NEW_START
read -rp "$SIZE_PROMPT: "  NEW_SIZE
NEW_START="${NEW_START:-$CUR_START}"
NEW_SIZE="${NEW_SIZE:-$CUR_SIZE}"

[[ "$NEW_START" =~ ^[0-9]+$ ]]  || { echo "bin_start must be a non-negative integer."; exit 1; }
[[ "$NEW_SIZE"  =~ ^[1-9][0-9]*$ ]] || { echo "bin_size must be a positive integer."; exit 1; }

# ---------- Preview 9-bin breakdown ----------
SVER=$(q "SELECT scoring_version FROM puzzles WHERE puzzle_id=$PID AND puzzle_version='$PVER'")

python3 - "$DB" "$PID" "$PVER" "$SVER" "$METRIC" "$NEW_START" "$NEW_SIZE" << 'PYEOF'
import sqlite3, sys

db, pid, pver, sver, metric, start, size = sys.argv[1:]
pid = int(pid); start = int(start); size = int(size)

con = sqlite3.connect(db)
rows = con.execute(
    "SELECT min_value, SUM(count) FROM histogram_counts "
    "WHERE puzzle_id=? AND puzzle_version=? AND scoring_version=? "
    "  AND metric_name=? AND count>0 "
    "GROUP BY min_value ORDER BY min_value",
    (pid, pver, sver, metric)
).fetchall()
con.close()

# Aggregate into 9 bins.
bins = [0] * 9
for val, cnt in rows:
    if val < start:
        bins[0] += cnt
    elif val >= start + 7 * size:
        bins[8] += cnt
    else:
        bins[(val - start) // size + 1] += cnt

# Build labels.
labels = [f"< {start}"]
for i in range(7):
    lo = start + i * size
    labels.append(f"{lo}–{lo + size - 1}")
labels.append(f"≥ {start + 7 * size}")

total = sum(bins)
maxc  = max(bins) if any(b > 0 for b in bins) else 1
BAR   = 30

print(f"\n  9-bin preview  ({metric}, start={start}, size={size})\n")
for i, (label, cnt) in enumerate(zip(labels, bins)):
    bar  = "█" * round(BAR * cnt / maxc)
    note = "  ← catch-all" if i in (0, 8) else ""
    print(f"  {label:>14}  {bar:<{BAR}}  {cnt}{note}")
print(f"\n  Total samples: {total}")
PYEOF

# ---------- Confirm and update ----------
echo ""
read -rp "Update DB with these settings? [y/N]: " CONFIRM
if [[ "${CONFIRM,,}" == "y" ]]; then
    q "UPDATE puzzles SET $SCOL=$NEW_START, $ZCOL=$NEW_SIZE
       WHERE puzzle_id=$PID AND puzzle_version='$PVER'"
    echo "Done."
else
    echo "Cancelled — no changes made."
fi
