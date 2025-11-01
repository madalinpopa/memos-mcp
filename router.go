package main

import (
	"net/http"

	"github.com/justinas/alice"
	"github.com/modelcontextprotocol/go-sdk/mcp"
)

func newStreamableHttpHandler(s *mcp.Server) http.Handler {
	return mcp.NewStreamableHTTPHandler(
		func(r *http.Request) *mcp.Server { return s }, nil,
	)
}

func newHandlerWithMiddleware(m *HTTPMiddleware, s *mcp.Server) http.Handler {
	mux := http.NewServeMux()

	mux.Handle("/mcp", newStreamableHttpHandler(s))

	base := alice.New(m.panicRecoverMiddleware, m.loggerMiddleware)
	return base.Then(mux)
}
