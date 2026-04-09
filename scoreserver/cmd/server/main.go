package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"scoreserver/internal/config"
	"scoreserver/internal/httpapi"
	"scoreserver/internal/storage"
	"time"
)

func main() {
	cfgPath := flag.String("config", "config.local.yaml", "path to config YAML file")
	flag.Parse()

	cfg, err := config.Load(*cfgPath)
	if err != nil {
		log.Fatalf("config: %v", err)
	}

	db, err := storage.Open(cfg.DB.Path)
	if err != nil {
		log.Fatalf("db: %v", err)
	}
	defer db.Close()

	srv := &httpapi.Server{
		DB:  db,
		Cfg: cfg,
		Limiter: httpapi.NewRateLimiters(
			cfg.RateLimit.PerIPPerMinute,
			cfg.RateLimit.PerInstallPerMinute,
		),
	}

	mux := http.NewServeMux()
	srv.RegisterRoutes(mux)

	addr := fmt.Sprintf(":%d", cfg.Server.Port)
	log.Printf("scoreserver listening on %s (db: %s)", addr, cfg.DB.Path)
	hs := &http.Server{
		Addr:         addr,
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
	}
	if err := hs.ListenAndServe(); err != nil {
		log.Fatalf("server: %v", err)
	}
}
