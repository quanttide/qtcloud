package main

import (
	"log"
	"net/http"

	"github.com/quanttide/qtcloud-provider/internal/config"
)

func main() {
	cfg := config.Load()
	mux := buildRouter(cfg)
	log.Printf("qtcloud-provider starting on %s", cfg.Addr)
	if err := http.ListenAndServe(cfg.Addr, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

// buildRouter 组装路由。当前为服务骨架，仅健康检查；
// 门户服务端接口（Studio/Site 数据源）按需立项后在此挂载。
func buildRouter(cfg *config.Config) *http.ServeMux {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok\n"))
	})

	return mux
}
