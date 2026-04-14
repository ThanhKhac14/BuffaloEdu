# Phase 2 — Auth & User Services (Backend)

> Refs: `docs/shared/backend-conventions.md` · `docs/shared/architecture.md`

## Mục tiêu

Build 4 Go services: `auth`, `user`, `profile`, `gateway`.
Áp dụng Go service template trong `docs/shared/backend-conventions.md`.

## Service Directory Template (áp dụng cho cả 4 services)

```
services/{name}/
├── cmd/main.go
├── internal/
│   ├── handler/{name}_handler.go
│   ├── service/{name}_service.go
│   ├── repository/{name}_repository.go
│   ├── middleware/
│   │   ├── auth.go       ← JWT interceptor
│   │   ├── metrics.go    ← Prometheus (BẮTBUỘC)
│   │   ├── logging.go
│   │   └── recovery.go
│   └── model/{name}.go
├── config/config.go
├── gen/                  ← buf generate output (gitignored)
├── migrations/
│   ├── 001_init.up.sql
│   └── 001_init.down.sql
├── Dockerfile
├── .env.example
└── README.md
```

---

## auth service (:8001 / gRPC :9001)

**gRPC methods:** `Register`, `Login`, `Logout`, `RefreshToken`, `ValidateToken`, `Healthz`

**Business rules:**
- JWT: access token 15min, refresh token 7 days
- Redis key: `session:{user_id}:{token_id}` TTL 7d
- Password: bcrypt cost 12
- ValidateToken: check Redis + verify JWT signature

**Migration:**
```sql
-- 001_init.up.sql
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role          VARCHAR(20) NOT NULL DEFAULT 'student' CHECK (role IN ('admin','teacher','student')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at    TIMESTAMPTZ
);
```

---

## user service (:8002 / gRPC :9002)

**gRPC methods:** `CreateUser`, `GetUser`, `UpdateUser`, `DeleteUser`, `ListUsers`, `ChangeRole`, `Healthz`

**Business rules:**
- Roles: `admin` · `teacher` · `student`
- Soft delete (`deleted_at` timestamp)
- ListUsers: pagination với `page` + `page_size`

---

## profile service (:8003 / gRPC :9003)

**gRPC methods:** `GetProfile`, `UpdateProfile`, `Healthz`

**Business rules:**
- 1 profile per user (FK → user_id)
- Avatar: store URL only (không store binary)

---

## gateway (:8000)

**Role:** Public REST entry point, routes tới internal gRPC services.

**Routes:**
```
POST /auth/register          → auth.Register
POST /auth/login             → auth.Login
POST /auth/refresh           → auth.RefreshToken
POST /auth/logout            → auth.Logout
GET|POST|PUT|DELETE /users/** → user service
GET|PUT /profiles/**          → profile service
GET /healthz                 → 200 OK
```

**Middleware (theo thứ tự):**
1. Recovery (panic handler)
2. Logging (structured JSON)
3. CORS
4. Rate limiting
5. JWT validation (trừ /auth/register, /auth/login, /healthz)

---

## Prometheus Metrics (BẮTBUỘC trên mọi service)

```go
// middleware/metrics.go
func Metrics() grpc.UnaryServerInterceptor {
    requests := promauto.NewCounterVec(prometheus.CounterOpts{
        Name: "grpc_requests_total",
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

Expose tại `:9090/metrics` mỗi service.

---

## Dockerfile Pattern (áp dụng cho mọi service)

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o service ./cmd/main.go

FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/service /service
EXPOSE 8001 9001
ENTRYPOINT ["/service"]
```

## Quality Gate

```bash
go build ./...             # 0 errors
go vet ./...               # 0 warnings
docker-compose build auth user profile gateway
```
