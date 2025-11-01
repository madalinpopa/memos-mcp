package main

import (
	"fmt"
	"log/slog"
	"net/http"
)

type HTTPMiddleware struct {
	logger *slog.Logger
}

func NewHTTPMiddleware(logger *slog.Logger) *HTTPMiddleware {
	return &HTTPMiddleware{
		logger: logger,
	}
}

func (m *HTTPMiddleware) loggerMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var (
			ip     = r.RemoteAddr
			proto  = r.Proto
			method = r.Method
			url    = r.URL.RequestURI()
		)

		m.logger.Info("request", "ip", ip, "proto", proto, "method", method, "url", url)

		next.ServeHTTP(w, r)
	})
}

func (m *HTTPMiddleware) panicRecoverMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		defer func() {
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				handleError(m.logger, w, r, fmt.Errorf("%v", err))
			}
		}()

		next.ServeHTTP(w, r)
	})
}
