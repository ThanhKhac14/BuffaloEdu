# Backend Conventions — BuffaloEdu

## Naming

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case.go` | `question_handler.go` |
| Packages | lowercase | `handler`, `service`, `repository` |
| Types | `PascalCase` | `ExamService` |
| Functions (exported) | `PascalCase` | `CreateQuestion` |
| Variables | `camelCase` | `examID` |
| SQL migrations | `NNN_desc.up/down.sql` | `001_init.up.sql` |

## Handler (thin)

```go
// ✅ Validate + call service only
func (h *Handler) CreateQuestion(ctx context.Context, req *pb.CreateQuestionRequest) (*pb.CreateQuestionResponse, error) {
    if req.Content == "" {
        return nil, status.Error(codes.InvalidArgument, "content is required")
    }
    q, err := h.svc.CreateQuestion(ctx, service.CreateQuestionInput{Content: req.Content})
    if err != nil {
        return nil, status.Error(codes.Internal, err.Error())
    }
    return &pb.CreateQuestionResponse{Question: toProto(q)}, nil
}
```

## Repository (raw SQL)

```go
// ✅ pgx/v5, NO ORM
func (r *Repository) CreateQuestion(ctx context.Context, in CreateInput) (*model.Question, error) {
    const q = `INSERT INTO questions (content, difficulty) VALUES ($1, $2) RETURNING id, content, created_at`
    var m model.Question
    if err := r.db.QueryRow(ctx, q, in.Content, in.Difficulty).Scan(&m.ID, &m.Content, &m.CreatedAt); err != nil {
        return nil, fmt.Errorf("create question: %w", err)
    }
    return &m, nil
}

// ❌ NEVER
r.db.Create(&question)  // GORM — FORBIDDEN
```

## Config (viper)

```go
// config/config.go — KHÔNG os.Getenv scattered
type Config struct {
    DatabaseURL string
    RedisURL    string
    GRPCAddr    string
    JWTSecret   string
}
func Load() Config {
    viper.AutomaticEnv()
    return Config{
        DatabaseURL: viper.GetString("DATABASE_URL"),
        GRPCAddr:    viper.GetString("GRPC_ADDR"),
    }
}
```

## Context

```go
// ✅ context.Context là tham số đầu tiên của mọi hàm gọi DB/gRPC
func (s *Service) GetExam(ctx context.Context, id string) (*model.Exam, error)

// Goroutine phải có cleanup
go func() {
    select {
    case <-ctx.Done():
        return
    case msg := <-msgs:
        process(msg)
    }
}()
```

## Migrations

```sql
-- migrations/001_init.up.sql
CREATE TABLE questions (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content    TEXT NOT NULL,
    difficulty INT  NOT NULL CHECK (difficulty BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- migrations/001_init.down.sql
DROP TABLE IF EXISTS questions;
```

Rules: Mọi migration phải có `.up.sql` + `.down.sql`. KHÔNG auto-migrate trong code.

## Proto Rules

- Location: `proto/{service}/v1/{service}.proto`
- Package: `buffaloedu.{service}.v1`
- Bắt buộc: `healthz` RPC trên mọi service
- Sau khi sửa: `buf lint` → `buf generate`

## Quality Gates

```bash
go build ./...       # 0 errors
go vet ./...         # 0 warnings
buf lint             # nếu sửa .proto
buf generate         # nếu sửa .proto
```
