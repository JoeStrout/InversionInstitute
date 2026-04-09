package histogram

import (
	"fmt"
	"scoreserver/internal/config"
	"scoreserver/internal/storage"
)

// BucketFor returns the bucket (min_value, max_value) that the given metric
// value falls into, using the configured bucket list.
// For gates, exact integer bins are used — min==max==value.
func BucketForGates(value int) (minVal int, maxVal *int) {
	return value, intPtr(value + 1)
}

// BucketForConfigured finds the bucket for total_ink or core_area using the
// ordered bucket list from config.  Every valid integer must map to exactly
// one bucket; the last bucket is open-ended (MaxExclusive==0).
func BucketForConfigured(value int, buckets []config.Bucket) (minVal int, maxVal *int, err error) {
	for _, b := range buckets {
		if value >= b.MinInclusive && (b.MaxExclusive == 0 || value < b.MaxExclusive) {
			if b.MaxExclusive == 0 {
				return b.MinInclusive, nil, nil
			}
			return b.MinInclusive, intPtr(b.MaxExclusive), nil
		}
	}
	return 0, nil, fmt.Errorf("value %d does not match any configured bucket", value)
}

// BucketsFromConfig converts a config.BucketConfig to storage.HistogramBucket
// slices for initial row creation.
func BucketsFromConfig(metricName string, cfgBuckets []config.Bucket) []storage.HistogramBucket {
	out := make([]storage.HistogramBucket, len(cfgBuckets))
	for i, b := range cfgBuckets {
		out[i] = storage.HistogramBucket{
			MetricName: metricName,
			MinValue:   b.MinInclusive,
		}
		if b.MaxExclusive != 0 {
			out[i].MaxValue = intPtr(b.MaxExclusive)
		}
	}
	return out
}

func intPtr(v int) *int { return &v }
