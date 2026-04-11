#!/usr/bin/env python3
"""
configure_bins.py — interactively set histogram display bins for a puzzle.

For each of the three metrics (gates, total_ink, core_area) it shows the
current 9-bin preview, prompts for new bin_start and bin_size (Enter keeps
the current value), shows the resulting preview, then does a single UPDATE
on confirmation.

Usage (run from scoreserver/):
    python3 scripts/configure_bins.py [config.local.yaml]
"""

import re
import sqlite3
import sys


# ── Config ────────────────────────────────────────────────────────────────────

def load_db_path(config_path):
    with open(config_path) as f:
        for line in f:
            m = re.match(r'\s*path:\s*([^\s#]+)', line)
            if m:
                return m.group(1)
    sys.exit(f"Cannot find db.path in {config_path}")


# ── Histogram helpers ─────────────────────────────────────────────────────────

def get_exact_histogram(db, puzzle_id, puzzle_version, scoring_version, metric):
    return db.execute(
        "SELECT min_value, SUM(count) FROM histogram_counts "
        "WHERE puzzle_id=? AND puzzle_version=? AND scoring_version=? "
        "  AND metric_name=? AND count>0 "
        "GROUP BY min_value ORDER BY min_value",
        (puzzle_id, puzzle_version, scoring_version, metric),
    ).fetchall()


def derive_bins(rows):
    """Return (bin_start, bin_size) auto-derived from observed data range."""
    if not rows:
        return 0, 1
    min_val = rows[0][0]
    max_val = rows[-1][0]
    size = max(1, (max_val - min_val + 6) // 7)
    return min_val, size


def show_preview(rows, start, size, metric):
    if not rows:
        print(f"  (no histogram data yet for {metric})")
        return

    counts = [0] * 9
    for val, cnt in rows:
        if val < start:
            counts[0] += cnt
        elif val >= start + 7 * size:
            counts[8] += cnt
        else:
            counts[(val - start) // size + 1] += cnt

    labels = [f"< {start}"]
    for i in range(7):
        lo = start + i * size
        labels.append(f"{lo}-{lo + size - 1}")
    labels.append(f">= {start + 7 * size}")

    total = sum(counts)
    maxc  = max(counts) if any(c > 0 for c in counts) else 1
    BAR   = 30

    print(f"  start={start}  size={size}")
    for i, (label, cnt) in enumerate(zip(labels, counts)):
        bar  = "\u2588" * round(BAR * cnt / maxc)
        note = "  <- catch-all" if i in (0, 8) else ""
        print(f"  {label:>14}  {bar:<{BAR}}  {cnt}{note}")
    print(f"  Total: {total}")


# ── Interactive helpers ───────────────────────────────────────────────────────

def prompt_int(prompt, default=None, min_val=0):
    """Prompt for an integer; Enter returns default if one is provided."""
    suffix = f" [{default}]" if default is not None else ""
    while True:
        raw = input(f"{prompt}{suffix}: ").strip()
        if not raw and default is not None:
            return default
        try:
            val = int(raw)
            if val < min_val:
                print(f"  Must be >= {min_val}.")
                continue
            return val
        except ValueError:
            print("  Please enter an integer.")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    config = sys.argv[1] if len(sys.argv) > 1 else "config.local.yaml"
    db_path = load_db_path(config)
    db = sqlite3.connect(db_path)

    # ── Select puzzle ──────────────────────────────────────────────────────
    puzzles = db.execute(
        "SELECT puzzle_id, puzzle_version, scoring_version, COALESCE(title,'(no title)'), "
        "       gates_bin_start, gates_bin_size, "
        "       ink_bin_start,   ink_bin_size, "
        "       area_bin_start,  area_bin_size "
        "FROM puzzles WHERE is_active=1 ORDER BY puzzle_id, puzzle_version"
    ).fetchall()

    if not puzzles:
        sys.exit("No active puzzles found.")

    print("\nActive puzzles:\n")
    for i, p in enumerate(puzzles):
        print(f"  {i+1:2}) [{p[0]:2}] {p[3]:<40} ({p[1]})")
    print()

    while True:
        raw = input(f"Select puzzle [1-{len(puzzles)}]: ").strip()
        try:
            idx = int(raw) - 1
            if 0 <= idx < len(puzzles):
                break
        except ValueError:
            pass
        print("  Invalid selection.")

    p = puzzles[idx]
    pid, pver, sver, title = p[0], p[1], p[2], p[3]
    cur = {
        "gates":     (p[4], p[5]),
        "total_ink": (p[6], p[7]),
        "core_area": (p[8], p[9]),
    }
    print(f"-> {title} (puzzle {pid} / {pver})\n")

    # ── Configure each metric ──────────────────────────────────────────────
    METRICS = [
        ("gates",     "gates_bin_start", "gates_bin_size"),
        ("total_ink", "ink_bin_start",   "ink_bin_size"),
        ("core_area", "area_bin_start",  "area_bin_size"),
    ]

    new_vals = {}

    for metric, _scol, _zcol in METRICS:
        rows    = get_exact_histogram(db, pid, pver, sver, metric)
        c_start, c_size = cur[metric]

        print(f"--- {metric} ---")

        if c_start is not None and c_size is not None:
            print(f"Current: bin_start={c_start}  bin_size={c_size}")
            show_preview(rows, c_start, c_size, metric)
        else:
            print("Current: (not yet configured — auto-derived preview below)")
            show_preview(rows, *derive_bins(rows), metric)

        print()
        n_start = prompt_int("  New bin_start", default=c_start, min_val=0)
        n_size  = prompt_int("  New bin_size",  default=c_size,  min_val=1)

        print("\n  After:")
        show_preview(rows, n_start, n_size, metric)
        print()

        new_vals[metric] = (n_start, n_size)

    # ── Confirm and commit ─────────────────────────────────────────────────
    answer = input("Update DB with all three metrics? [y/N]: ").strip().lower()
    if answer == "y":
        db.execute(
            "UPDATE puzzles "
            "SET gates_bin_start=?, gates_bin_size=?, "
            "    ink_bin_start=?,   ink_bin_size=?, "
            "    area_bin_start=?,  area_bin_size=? "
            "WHERE puzzle_id=? AND puzzle_version=?",
            (
                new_vals["gates"][0],     new_vals["gates"][1],
                new_vals["total_ink"][0], new_vals["total_ink"][1],
                new_vals["core_area"][0], new_vals["core_area"][1],
                pid, pver,
            ),
        )
        db.commit()
        print("Done.")
    else:
        print("Cancelled — no changes made.")

    db.close()


if __name__ == "__main__":
    main()
