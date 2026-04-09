package storage

import (
	"database/sql"
	"fmt"
	"time"
)

// HistogramBucket is one row from histogram_counts.
type HistogramBucket struct {
	MetricName       string
	MinValue         int
	MaxValue         *int // nil = open-ended
	Count            int
}

// AdjustHistogramCount increments (delta=+1) or decrements (delta=-1) the
// count for a specific bucket inside a transaction.  The row is created with
// count=0 if it does not exist yet, then adjusted.
func AdjustHistogramCount(tx *sql.Tx,
	puzzleID int, puzzleVersion, scoringVersion, bucketSetVersion,
	metricName string, minValue int, maxValue *int, delta int) error {

	now := time.Now().UTC().Format(time.RFC3339)

	// Upsert: ensure the row exists.
	_, err := tx.Exec(`
		INSERT INTO histogram_counts
			(puzzle_id, puzzle_version, scoring_version, bucket_set_version,
			 metric_name, min_value, max_value, count, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)
		ON CONFLICT DO NOTHING`,
		puzzleID, puzzleVersion, scoringVersion, bucketSetVersion,
		metricName, minValue, maxValueArg(maxValue), now)
	if err != nil {
		return fmt.Errorf("ensure histogram row: %w", err)
	}

	_, err = tx.Exec(`
		UPDATE histogram_counts
		SET count = count + ?, updated_at = ?
		WHERE puzzle_id = ? AND puzzle_version = ? AND scoring_version = ?
		  AND bucket_set_version = ? AND metric_name = ? AND min_value = ?`,
		delta, now,
		puzzleID, puzzleVersion, scoringVersion,
		bucketSetVersion, metricName, minValue)
	if err != nil {
		return fmt.Errorf("adjust histogram count: %w", err)
	}
	return nil
}

// GetHistogram returns all bucket rows for a puzzle/version/metric combination,
// ordered by min_value.
func GetHistogram(db *sql.DB,
	puzzleID int, puzzleVersion, scoringVersion, bucketSetVersion, metricName string,
) ([]HistogramBucket, error) {
	rows, err := db.Query(`
		SELECT metric_name, min_value, max_value, count
		FROM histogram_counts
		WHERE puzzle_id = ? AND puzzle_version = ? AND scoring_version = ?
		  AND bucket_set_version = ? AND metric_name = ?
		ORDER BY min_value`,
		puzzleID, puzzleVersion, scoringVersion, bucketSetVersion, metricName)
	if err != nil {
		return nil, fmt.Errorf("get histogram: %w", err)
	}
	defer rows.Close()

	var buckets []HistogramBucket
	for rows.Next() {
		var b HistogramBucket
		var maxVal sql.NullInt64
		if err := rows.Scan(&b.MetricName, &b.MinValue, &maxVal, &b.Count); err != nil {
			return nil, err
		}
		if maxVal.Valid {
			v := int(maxVal.Int64)
			b.MaxValue = &v
		}
		buckets = append(buckets, b)
	}
	return buckets, rows.Err()
}

// SampleCount returns the total number of players counted in any one metric's
// histogram (all buckets summed) for a puzzle version.  Using gates as the
// reference metric since every submission contributes exactly one gate bucket.
func SampleCount(db *sql.DB,
	puzzleID int, puzzleVersion, scoringVersion, bucketSetVersion string,
) (int, error) {
	var total sql.NullInt64
	err := db.QueryRow(`
		SELECT SUM(count)
		FROM histogram_counts
		WHERE puzzle_id = ? AND puzzle_version = ? AND scoring_version = ?
		  AND bucket_set_version = ? AND metric_name = 'gates'`,
		puzzleID, puzzleVersion, scoringVersion, bucketSetVersion,
	).Scan(&total)
	if err != nil {
		return 0, err
	}
	return int(total.Int64), nil
}

func maxValueArg(v *int) interface{} {
	if v == nil {
		return nil
	}
	return *v
}
