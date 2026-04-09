package config

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v3"
)

// Config holds all server configuration.
type Config struct {
	Server    ServerConfig    `yaml:"server"`
	DB        DBConfig        `yaml:"db"`
	RateLimit RateLimitConfig `yaml:"rate_limit"`
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
	return &cfg, nil
}
