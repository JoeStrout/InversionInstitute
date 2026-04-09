package histogram

import "scoreserver/internal/storage"

// Percentile returns the fraction of samples that have a value strictly better
// (lower) than playerBestValue, based on the histogram buckets.
//
// For gates (exact bins), "better" = min_value < playerBestValue.
// For ink/area (ranged bins), we count all buckets whose min_value < the
// player's bucket min_value, plus a partial contribution from the player's
// own bucket (treating the player's value as the midpoint).
//
// This is a simple rank-based percentile suitable for display; it does not
// claim statistical precision.
func Percentile(buckets []storage.HistogramBucket, playerBestValue int, totalSamples int) float64 {
	if totalSamples == 0 {
		return 0
	}

	// Find which bucket the player falls into.
	playerBucket := -1
	for i, b := range buckets {
		if playerBestValue == b.MinValue {
			playerBucket = i
			break
		}
		if b.MaxValue != nil && playerBestValue >= b.MinValue && playerBestValue < *b.MaxValue {
			playerBucket = i
			break
		}
		if b.MaxValue == nil && playerBestValue >= b.MinValue {
			playerBucket = i
			break
		}
	}

	// Sum counts for all buckets strictly below the player's.
	below := 0
	for i, b := range buckets {
		if i < playerBucket {
			below += b.Count
		}
	}

	// Add half of the player's own bucket as an approximation.
	withinBucket := 0
	if playerBucket >= 0 {
		withinBucket = buckets[playerBucket].Count / 2
	}

	return float64(below+withinBucket) / float64(totalSamples)
}
