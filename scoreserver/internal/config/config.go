package config

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v3"
)

// Config holds all server configuration.
type Config struct {
	Server   ServerConfig   `yaml:"server"`
	DB       DBConfig       `yaml:"db"`
	RateLimit RateLimitConfig `yaml:"rate_limit"`
	Buckets  BucketConfig   `yaml:"buckets"`
}

type ServerConfig struct {
	Port       int    `yaml:"port"`
	AdminToken string `yaml:"admin_token"` // for future use
}

type DBConfig struct {
	Path string `yaml:"path"`
}

type RateLimitConfig struct {
	// Max requests per IP per minute.
	PerIPPerMinute int `yaml:"per_ip_per_minute"`
	// Max requests per install ID per minute.
	PerInstallPerMinute int `yaml:"per_install_per_minute"`
}

// BucketConfig defines histogram buckets for total_ink and core_area.
// Gates uses exact integer bins and needs no config.
type BucketConfig struct {
	Version  string   `yaml:"version"`
	TotalInk []Bucket `yaml:"total_ink"`
	CoreArea []Bucket `yaml:"core_area"`
}

// Bucket represents one histogram bucket.
// MaxExclusive == 0 means the bucket is open-ended (no upper bound).
type Bucket struct {
	MinInclusive int    `yaml:"min"`
	MaxExclusive int    `yaml:"max"` // 0 = open-ended
	Label        string `yaml:"label"`
}

// Load reads and parses a YAML config file.
func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading config %q: %w", path, err)
	}
	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("parsing config %q: %w", path, err)
	}
	if cfg.Server.Port == 0 {
		cfg.Server.Port = 8080
	}
	if cfg.DB.Path == "" {
		cfg.DB.Path = "scoreserver.db"
	}
	if cfg.RateLimit.PerIPPerMinute == 0 {
		cfg.RateLimit.PerIPPerMinute = 30
	}
	if cfg.RateLimit.PerInstallPerMinute == 0 {
		cfg.RateLimit.PerInstallPerMinute = 10
	}
	if cfg.Buckets.Version == "" {
		cfg.Buckets.Version = "v1"
	}
	return &cfg, nil
}
