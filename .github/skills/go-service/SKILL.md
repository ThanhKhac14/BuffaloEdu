# SKILL: Go Microservice Scaffold

Auto-activates when: creating a new Go service, editing `cmd/main.go`, working in `services/*/internal/`

---

## Layered Architecture (STRICT — never violate)

```
handler     → receives gRPC request, validates, calls service, returns response
service     → business logic only, calls repository, NO SQL here
repository  → ALL database/Redis queries, raw SQL with pgx/v5, NO business logic
middleware  → gRPC interceptors: auth, logging, metrics, recovery
model       → domain structs (NOT proto-generated types)
config      → viper-based env loading, returns typed Config struct
```

## Service entry point (cmd/main.go)

```go
package main

import (
    "context"
    "log/slog"
    "net"
    "os"
    "os/signal"
    "syscall"

    "google.golang.org/grpc"
    "google.golang.org/grpc/reflection"

    "{service}v1 "github.com/buffaloedu/proto/{service}/v1"
    "github.com/buffaloedu/services/{service}/config"
    "github.com/buffaloedu/services/{service}/internal/handler"
    "github.com/buffaloedu/services/{service}/internal/middleware"
    "github.com/buffaloedu/services/{service}/internal/repository"
    "github.com/buffaloedu/services/{service}/internal/service"
)

func main() {
    cfg := config.Load()
    logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

    // DB connection
    db, err := repository.NewDB(cfg.DatabaseURL)
    if err != nil {
        logger.Error("db connect failed", "err", err)
        os.Exit(1)
    }
    defer db.Close()

    // Redis connection
    rdb := repository.NewRedis(cfg.RedisURL)
    defer rdb.Close()

    // Wire layers
    repo := repository.New(db, rdb)
    svc  := service.New(repo, logger)
    hdlr := handler.New(svc, logger)

    // gRPC server
    srv := grpc.NewServer(
        grpc.ChainUnaryInterceptor(
            middleware.Recovery(logger),
            middleware.Logging(logger),
            middleware.Metrics(),
            middleware.Auth(cfg.JWTSecret),
        ),
    )
    {service}v1.Register{Service}ServiceServer(srv, hdlr)
    reflection.Register(srv)

    lis, err := net.Listen("tcp", cfg.GRPCAddr)
    if err != nil {
        logger.Error("listen failed", "err", err)
        os.Exit(1)
    }

    // Graceful shutdown
    ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
    defer stop()

    go func() {
        logger.Info("gRPC server started", "addr", cfg.GRPCAddr)
        if err := srv.Serve(lis); err != nil {
            logger.Error("serve failed", "err", err)
        }
    }()

    <-ctx.Done()
    logger.Info("shutting down gracefully")
    srv.GracefulStop()
}
```

## Handler pattern

```go
// THIN — only validate, call service, map response
func (h *Handler) CreateQuestion(ctx context.Context, req *pb.CreateQuestionRequest) (*pb.CreateQuestionResponse, error) {
    if req.Content == "" {
        return nil, status.Error(codes.InvalidArgument, "content is required")
    }
    q, err := h.svc.CreateQuestion(ctx, service.CreateQuestionInput{
        Content:   req.Content,
        Options:   req.Options,
        Correct:   req.CorrectAnswer,
        Difficulty: int(req.Difficulty),
    })
    if err != nil {
        return nil, status.Error(codes.Internal, err.Error())
    }
    return &pb.CreateQuestionResponse{Question: toProto(q)}, nil
}
```

## Repository pattern (pgx/v5 raw SQL)

```go
// ALL SQL lives here — never in service or handler
func (r *Repository) CreateQuestion(ctx context.Context, input CreateInput) (*model.Question, error) {
    const q = `
        INSERT INTO questions (content, options, correct_answer, difficulty, subject, created_by)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id, content, options, correct_answer, difficulty, subject, created_by, created_at`

    row := r.db.QueryRow(ctx, q,
        input.Content, input.Options, input.Correct,
        input.Difficulty, input.Subject, input.CreatedBy,
    )
    var m model.Question
    if err := row.Scan(&m.ID, &m.Content, &m.Options, &m.CorrectAnswer,
        &m.Difficulty, &m.Subject, &m.CreatedBy, &m.CreatedAt); err != nil {
        return nil, fmt.Errorf("create question: %w", err)
    }
    return &m, nil
}
```

## Prometheus metrics interceptor

```go
func Metrics() grpc.UnaryServerInterceptor {
    requests := promauto.NewCounterVec(prometheus.CounterOpts{
        Name: "grpc_requests_total",
        Help: "Total gRPC requests",
    }, []string{"method", "status"})

    duration := promauto.NewHistogramVec(prometheus.HistogramOpts{
        Name:    "grpc_request_duration_seconds",
        Buckets: prometheus.DefBuckets,
    }, []string{"method"})

    return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
        start := time.Now()
        resp, err := handler(ctx, req)
        status := "ok"
        if err != nil { status = "error" }
        requests.WithLabelValues(info.FullMethod, status).Inc()
        duration.WithLabelValues(info.FullMethod).Observe(time.Since(start).Seconds())
        return resp, err
    }
}
```

## healthz RPC (every service must have this)

```go
func (h *Handler) Healthz(ctx context.Context, req *pb.HealthzRequest) (*pb.HealthzResponse, error) {
    return &pb.HealthzResponse{Status: "ok"}, nil
}
```

## Migration file naming
```
migrations/
├── 001_init.up.sql
├── 001_init.down.sql
├── 002_add_tags.up.sql
└── 002_add_tags.down.sql
```

## Dockerfile

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o service ./cmd/main.go

FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/service /service
EXPOSE 8000 9000
ENTRYPOINT ["/service"]
```

## Quality gate
After any Go service work:
1. `go build ./...` — 0 errors
2. `go vet ./...` — 0 warnings
3. `buf generate` if .proto changed
4. `docker-compose build {service}` — succeeds
