# HocTrau — Project Overview & Architecture
> Đọc file này trước. Đây là nguồn sự thật duy nhất cho toàn bộ dự án.

---

## Product
| | |
|---|---|
| **App name** | HocTrau (BuffaloEdu) |
| **Tagline** | *"Cày thôi!"* |
| **Type** | Online Examination & Learning Assessment Platform |
| **Style** | Glassmorphism · Botanical/Organic · Matcha/Đất nung · NO purple/violet |
| **Users** | Teacher · Student · Admin |
| **Dev model** | Solo developer — simplicity over scalability |

---

## Tech Stack

```
┌─────────────────────────────────────────────────────┐
│                    INTERNET                         │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────▼────────┐
              │   Next.js App   │  ← Frontend (port 3000)
              │  (App Router)   │    Vercel / Docker
              └────────┬────────┘
                       │ REST API calls
              ┌────────▼────────┐
              │   Go Monolith   │  ← Backend (port 8000)
              │   (Gin router)  │    1 binary, all domains
              └────────┬────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐          ┌─────────▼────────┐
│   Supabase     │          │   Supabase       │
│  PostgreSQL    │          │  Auth + Storage  │
│  (pgx/v5 DSN) │          │  (SDK + REST)    │
└────────────────┘          └──────────────────┘
```

---

## API Domains (Go Monolith)

| Domain | Prefix | Chức năng |
|---|---|---|
| Auth | `/api/auth/*` | Sync session với Supabase Auth, role assignment |
| User | `/api/users/*` | CRUD profile, role management |
| Question | `/api/questions/*` | CRUD questions, bulk import, search |
| Exam | `/api/exams/*` | Create/publish exams, randomize |
| Submission | `/api/submissions/*` | Submit answers, auto-grading |
| Result | `/api/results/*` | Scores, reports, analytics |

---

## Frontend Routes (Next.js App Router)

| Route | Trang |
|---|---|
| `/login` `/register` `/onboarding` | Auth flows |
| `/dashboard` | Stats, Bò hero, activity |
| `/exams` `/exams/create` `/exams/[id]/take` | Exam lifecycle |
| `/question-bank` | CRUD questions |
| `/reports` `/achievements` | Analytics, streak |
| `/result/[id]` | Kết quả sau thi |

---

## Database — Supabase PostgreSQL

```sql
-- 1 project Supabase, 1 schema public
users           -- sync từ supabase.auth.users
profiles        -- extended user info, avatar_url
questions       -- content, options, correct_answer, difficulty, tags
exams           -- title, duration, settings, published
exam_questions  -- pivot: exam_id, question_id, order
submissions     -- student_id, exam_id, started_at, finalized_at
answers         -- submission_id, question_id, chosen_answer
results         -- submission_id, score, percentage, passed, breakdown
```

---

## File Index

| File | Dùng cho |
|---|---|
| `00-overview.md` | File này — đọc trước |
| `01-backend.md` | GitHub Copilot — scaffold Go monolith |
| `design/02-design.md` | AI Studio / Stitch — design system + UI mockups |
| `03-frontend.md` | GitHub Copilot — scaffold Next.js app |
| `mascots/04-mascot.md` | Adobe Firefly — generate Bò theo từng pose |
| `05-cicd.md` | GitHub Copilot — GitHub Actions pipelines |

---

## Shared Conventions

### Naming
```
services/api/       → Go monolith
frontend/app/       → Next.js App Router
migrations/         → SQL migration files (Supabase CLI)
.github/workflows/  → CI/CD pipelines
```

### Environment variables
```
# Backend (.env)
SUPABASE_DB_URL=postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres
SUPABASE_SERVICE_ROLE_KEY=...
JWT_SECRET=...
PORT=8000

# Frontend (.env.local)
NEXT_PUBLIC_SUPABASE_URL=https://[ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### Port convention
```
3000  → Next.js frontend
8000  → Go monolith REST API
54322 → Supabase local (supabase start)
```

---

## Quick Start

```bash
# 1. Clone & setup
git clone https://github.com/ThanhKhac14/BuffaloEdu.git
cd BuffaloEdu
cp .env.example .env   # điền Supabase keys

# 2. Start Supabase local (optional — dùng hosted cũng được)
supabase start
supabase db push       # apply migrations

# 3. Start backend
cd services/api && go run ./cmd/main.go

# 4. Start frontend
cd frontend && npm run dev

# 5. Access
# App:  http://localhost:3000
# API:  http://localhost:8000
```
