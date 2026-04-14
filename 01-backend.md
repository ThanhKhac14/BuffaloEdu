# BuffaloEdu — Backend Prompt (GitHub Copilot)
> Dùng trong GitHub Copilot Agent mode (@workspace). Chạy từng phase, confirm trước khi tiếp.

---

```
# BACKEND SCAFFOLD — BuffaloEdu Go Monolith + Supabase

## Role
You are a senior backend engineer specializing in Go.
Scaffold the complete BuffaloEdu backend as a single Go monolith.
Follow every constraint exactly. Do NOT add features beyond what is specified.
Do NOT use ORM. Do NOT invent abstractions not asked for.

---

## Tech Stack
- Language:      Golang 1.24+
- Architecture:  Monolith (all domains in 1 binary)
- Transport:     REST HTTP (Gin router)
- Database:      Supabase PostgreSQL — pgx/v5, raw SQL only
- Auth:          Supabase Auth — validate JWT from frontend, sync user to profiles table
- Storage:       Supabase Storage — store URL only, never binary in PG
- Container:     1 Dockerfile for the monolith

---

## Repository Structure (generate exactly this)
```
BuffaloEdu/
├── services/
│   └── api/
│       ├── cmd/
│       │   └── main.go
│       ├── internal/
│       │   ├── handler/        # HTTP handlers — thin, call service only
│       │   │   ├── auth.go
│       │   │   ├── user.go
│       │   │   ├── question.go
│       │   │   ├── exam.go
│       │   │   ├── submission.go
│       │   │   └── result.go
│       │   ├── service/        # Business logic — no DB access
│       │   ├── repository/     # All SQL queries — pgx/v5, raw SQL
│       │   ├── middleware/     # JWT auth, CORS, rate limit, logging
│       │   └── model/          # Domain structs
│       ├── config/
│       │   └── config.go       # Env vars via viper → typed Config
│       ├── migrations/         # SQL: 001_init.up.sql, 001_init.down.sql
│       ├── Dockerfile
│       └── .env.example
├── frontend/                   # Next.js — handled in 03-frontend.md
├── .github/workflows/          # CI/CD — handled in 05-cicd.md
├── docker-compose.yml
├── .env.example
└── supabase/                   # supabase CLI config
    └── config.toml
```

---

## Go Module Template
```
services/api/
├── cmd/main.go              # Entry: load config → connect DB → register routes → listen
├── internal/
│   ├── handler/             # HTTP handlers — 1 file per domain, thin
│   ├── service/             # Business logic — no SQL here
│   ├── repository/          # ALL pgx/v5 SQL queries — 1 file per domain
│   ├── middleware/          # HTTP middleware: auth, cors, rate-limit, logging
│   └── model/               # Domain structs (NOT DB structs)
├── config/config.go         # All env vars via os.Getenv or viper → Config struct
├── migrations/              # 001_init.up.sql, 001_init.down.sql
├── Dockerfile
└── .env.example
```

Layer rules:
- `handler` calls `service` only
- `service` calls `repository` only
- `repository` is the ONLY layer that touches Supabase PostgreSQL

---

## Domains — Full Specification

### auth handler
- Role: Validate Supabase JWT, sync user to profiles table, assign role
- POST `/api/auth/sync` — called after Supabase signup; upsert into profiles table
- Middleware: extract `Authorization: Bearer <supabase_jwt>`, verify with Supabase service key, inject user_id into context

### user handler
- GET    `/api/users/me`         — get own profile
- PUT    `/api/users/me`         — update own profile (display_name, bio)
- GET    `/api/users`            — list users (admin only)
- PUT    `/api/users/:id/role`   — change role (admin only): admin · teacher · student

### question handler
- GET    `/api/questions`        — list + filter (subject, difficulty, type, tags, search)
- POST   `/api/questions`        — create (teacher/admin)
- GET    `/api/questions/:id`    — get single question
- PUT    `/api/questions/:id`    — update (owner/admin)
- DELETE `/api/questions/:id`    — soft delete (owner/admin)
- POST   `/api/questions/bulk`   — bulk import from JSON array

### exam handler
- GET    `/api/exams`            — list exams (teacher sees own, student sees published)
- POST   `/api/exams`            — create exam (teacher/admin)
- GET    `/api/exams/:id`        — get exam with questions
- PUT    `/api/exams/:id`        — update exam (unpublished only)
- DELETE `/api/exams/:id`        — delete (unpublished only)
- POST   `/api/exams/:id/publish` — publish exam
- POST   `/api/exams/:id/randomize` — auto-select N questions by filter

### submission handler
- POST   `/api/submissions`           — start submission (student)
- PUT    `/api/submissions/:id/answers` — save answers batch
- POST   `/api/submissions/:id/finalize` — submit exam, trigger auto-grading
- GET    `/api/submissions/:id`       — get submission detail

### result handler
- GET    `/api/results/:submission_id` — get result + per-question breakdown
- GET    `/api/results`               — list results for current user
- GET    `/api/results/exam/:exam_id` — class performance (teacher/admin)

---

## Database Schema (Supabase PostgreSQL)

```sql
-- migrations/001_init.up.sql

-- profiles (extends supabase auth.users)
CREATE TABLE profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT '',
    role        TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('admin','teacher','student')),
    avatar_url  TEXT,
    bio         TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- questions
CREATE TABLE questions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by  UUID NOT NULL REFERENCES profiles(id),
    type        TEXT NOT NULL CHECK (type IN ('multiple_choice','true_false','short_answer')),
    content     TEXT NOT NULL,
    options     JSONB,           -- [{key:"A", text:"..."}, ...]  null for short_answer
    correct_answer TEXT NOT NULL,
    difficulty  INT NOT NULL CHECK (difficulty BETWEEN 1 AND 5),
    subject     TEXT NOT NULL,
    tags        TEXT[] DEFAULT '{}',
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- exams
CREATE TABLE exams (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by              UUID NOT NULL REFERENCES profiles(id),
    title                   TEXT NOT NULL,
    description             TEXT,
    duration_minutes        INT NOT NULL,
    max_attempts            INT NOT NULL DEFAULT 1,
    show_result_immediately BOOLEAN DEFAULT TRUE,
    randomize_order         BOOLEAN DEFAULT FALSE,
    published_at            TIMESTAMPTZ,
    deleted_at              TIMESTAMPTZ,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- exam_questions (pivot)
CREATE TABLE exam_questions (
    exam_id     UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(id),
    position    INT NOT NULL,
    PRIMARY KEY (exam_id, question_id)
);

-- submissions
CREATE TABLE submissions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id     UUID NOT NULL REFERENCES exams(id),
    student_id  UUID NOT NULL REFERENCES profiles(id),
    started_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finalized_at TIMESTAMPTZ,
    attempt_num INT NOT NULL DEFAULT 1
);

-- answers
CREATE TABLE answers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id   UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
    question_id     UUID NOT NULL REFERENCES questions(id),
    chosen_answer   TEXT,
    is_correct      BOOLEAN,
    saved_at        TIMESTAMPTZ DEFAULT NOW()
);

-- results
CREATE TABLE results (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id   UUID NOT NULL UNIQUE REFERENCES submissions(id),
    score           NUMERIC(5,2) NOT NULL,
    percentage      NUMERIC(5,2) NOT NULL,
    passed          BOOLEAN NOT NULL,
    time_taken_sec  INT,
    breakdown       JSONB,   -- [{question_id, correct, chosen, expected}]
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- enable RLS
ALTER TABLE profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE exams          ENABLE ROW LEVEL SECURITY;
ALTER TABLE exam_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions    ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers        ENABLE ROW LEVEL SECURITY;
ALTER TABLE results        ENABLE ROW LEVEL SECURITY;
```

---

## Constraints — MUST follow
- NEVER use ORM — pgx/v5 with raw SQL only
- NEVER put SQL in handler or service layer — only in repository
- NEVER store binary data in PostgreSQL — Supabase Storage URL only
- JWT validation: use Supabase service role key to verify token, extract sub as user_id
- MUST use structured logging (slog)
- MUST use viper for all config/env loading
- MUST return consistent JSON error format: `{"error": "message", "code": "ERROR_CODE"}`
- Soft delete: set deleted_at, never hard-delete questions/exams

---

## docker-compose.yml (development only)

```yaml
services:
  api:
    build: ./services/api
    ports:
      - "8000:8000"
    env_file: .env
    # Supabase DB_URL points to hosted Supabase — no local postgres needed

  # Optional: run Supabase locally
  # supabase local dev: supabase start (managed by supabase CLI, not docker-compose)
```

---

## .env.example

```
# Supabase
SUPABASE_DB_URL=postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres
SUPABASE_JWT_SECRET=your-supabase-jwt-secret
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# App
PORT=8000
ENV=development
LOG_LEVEL=info
```

---

## Execution Order — confirm after each phase

Phase 1: Scaffold services/api/ structure + config + cmd/main.go
Phase 2: SQL migration files (001_init.up.sql + down)
Phase 3: Implement repository layer (all domains)
Phase 4: Implement service layer (all domains)
Phase 5: Implement handler layer + route registration
Phase 6: docker-compose.yml + .env.example

Begin Phase 1. List all files you will create, then generate them. Confirm before Phase 2.
```
