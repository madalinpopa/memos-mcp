package main

import (
	"flag"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

var (
	port   string
	logger *slog.Logger
)

func main() {

	flag.StringVar(&port, "port", "4000", "Port to listen on")
	flag.Parse()

	logger = slog.New(slog.NewTextHandler(os.Stdout, nil))

	mcpServer := mcp.NewServer(&mcp.Implementation{
		Name:    "memos",
		Version: "0.1.0",
	}, nil)

	middleware := NewHTTPMiddleware(logger)
	handler := newHandlerWithMiddleware(middleware, mcpServer)

	server := &http.Server{
		Addr:         ":" + port,
		Handler:      handler,
		ErrorLog:     slog.NewLogLogger(logger.Handler(), slog.LevelError),
		IdleTimeout:  time.Minute,
		ReadTimeout:  time.Second * 5,
		WriteTimeout: time.Second * 10,
	}

	logger.Info("server started", "port", port)
	if err := server.ListenAndServe(); err != nil {
		logger.Error("server failed", "err", err)
		os.Exit(1)
	}

}
