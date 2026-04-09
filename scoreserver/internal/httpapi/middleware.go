package httpapi

import (
	"crypto/sha256"
	"encoding/hex"
	"net"
	"net/http"
	"sync"
	"time"
)

const maxBodyBytes = 64 * 1024 // 64 KB — well above the ~2 KB circuit PNG

// LimitBody wraps a handler to enforce a request body size limit.
func LimitBody(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		r.Body = http.MaxBytesReader(w, r.Body, maxBodyBytes)
		next.ServeHTTP(w, r)
	})
}

// rateLimiter tracks request counts per key within a rolling window.
type rateLimiter struct {
	mu       sync.Mutex
	counts   map[string][]time.Time
	window   time.Duration
	maxCount int
}

func newRateLimiter(window time.Duration, maxCount int) *rateLimiter {
	return &rateLimiter{
		counts:   make(map[string][]time.Time),
		window:   window,
		maxCount: maxCount,
	}
}

// Allow returns true if the key is within the rate limit.
func (rl *rateLimiter) Allow(key string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	cutoff := now.Add(-rl.window)

	// Trim expired timestamps.
	times := rl.counts[key]
	i := 0
	for i < len(times) && times[i].Before(cutoff) {
		i++
	}
	times = times[i:]

	if len(times) >= rl.maxCount {
		rl.counts[key] = times
		return false
	}
	rl.counts[key] = append(times, now)
	return true
}

// RateLimiters holds per-IP and per-install rate limiters.
type RateLimiters struct {
	ByIP      *rateLimiter
	ByInstall *rateLimiter
}

// NewRateLimiters constructs limiters using counts-per-minute settings.
func NewRateLimiters(perIPPerMin, perInstallPerMin int) *RateLimiters {
	return &RateLimiters{
		ByIP:      newRateLimiter(time.Minute, perIPPerMin),
		ByInstall: newRateLimiter(time.Minute, perInstallPerMin),
	}
}

// HashIP returns a one-way hash of an IP address for storage.
func HashIP(remoteAddr string) string {
	host, _, err := net.SplitHostPort(remoteAddr)
	if err != nil {
		host = remoteAddr
	}
	h := sha256.Sum256([]byte(host))
	return hex.EncodeToString(h[:8]) // first 8 bytes is plenty for dedup
}

// RemoteIP extracts the client IP, respecting X-Forwarded-For if present.
func RemoteIP(r *http.Request) string {
	if fwd := r.Header.Get("X-Forwarded-For"); fwd != "" {
		// Take the first (leftmost) address — the original client.
		if idx := len(fwd); idx > 0 {
			for i, c := range fwd {
				if c == ',' {
					return fwd[:i]
				}
			}
			return fwd
		}
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}
