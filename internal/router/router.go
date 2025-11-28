package router

import (
	"net/http"

	"github.com/mrl00/stream-processing-with-apache-flink/internal/handler"
)

func New() *http.ServeMux {
	r := http.NewServeMux()

	r.HandleFunc("GET /health", handler.HealthCheck())

	return r
}
