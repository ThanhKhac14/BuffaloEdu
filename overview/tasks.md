# Task Plan — BuffaloEdu (Solo Developer)

Execute phases in order. Confirm each quality gate before moving on.
Read `design/design-system/tokens.css` before writing any component.
Read `overview/rules.md` before any code.

---

## Phase 1: Foundation — Scaffold (~1 ngày)

### 1.1 — Go monolith scaffold
```
services/api/
├── cmd/main.go
├── internal/handler/ service/ repository/ middleware/ model/
├── config/config.go
├── migrations/001_init.up.sql + 001_init.down.sql
├── Dockerfile
└── .env.example
```

### 1.2 — SQL migrations
Create `migrations/001_init.up.sql` with all tables (xem schema trong `01-backend.md`):
`profiles`, `questions`, `exams`, `exam_questions`, `submissions`, `answers`, `results`
Enable RLS trên tất cả tables.

### 1.3 — Supabase setup
- Tạo Supabase project tại supabase.com (hoặc `supabase start` local)
- Apply migrations: `supabase db push`
- Copy keys vào `.env`

### 1.4 — docker-compose.yml
Chỉ cần 1 service: `api` (Go monolith).
Supabase dùng hosted — không cần postgres container.

### Quality gate
- `go build ./...` — 0 errors
- `supabase db push` — migrations applied cleanly
- `docker-compose build` — builds successfully

---

## Phase 2: Auth + User API (~1 ngày)

### 2.1 — Auth middleware
`internal/middleware/auth.go`:
- Extract `Authorization: Bearer <jwt>` header
- Verify JWT với `SUPABASE_JWT_SECRET`
- Inject `user_id` (UUID) vào request context

### 2.2 — Auth handler
`POST /api/auth/sync`:
- Upsert user vào `profiles` table (id từ JWT sub, default role = student)
- Trả về profile object

### 2.3 — User handler
- `GET /api/users/me` — lấy profile của current user
- `PUT /api/users/me` — update display_name, bio, avatar_url
- `GET /api/users` — list users (admin only)
- `PUT /api/users/:id/role` — đổi role (admin only)

### Quality gate
- `go build ./...` — 0 errors
- Test với curl: sync → profile returned
- JWT với role sai → 403

---

## Phase 3: Exam Core APIs (~2 ngày)

### 3.1 — Question API
CRUD + search. Xem routes trong `01-backend.md`.
- Filter: subject, difficulty, type, tags[], full-text search on content
- Bulk import: POST `/api/questions/bulk` — nhận JSON array
- Soft delete: set `deleted_at`, filter `WHERE deleted_at IS NULL`

### 3.2 — Exam API
CRUD + publish + randomize.
- `POST /api/exams/:id/publish` — set `published_at = NOW()`
- `POST /api/exams/:id/randomize` — select N questions filtered by subject/difficulty/tags → insert into `exam_questions`
- Unpublished exams: only creator can see/edit

### 3.3 — Submission API
- `POST /api/submissions` — tạo submission record, check max_attempts
- `PUT /api/submissions/:id/answers` — upsert answers batch (cho phép save nhiều lần)
- `POST /api/submissions/:id/finalize` — auto-grade + tạo result record
  - So sánh `answers.chosen_answer` vs `questions.correct_answer`
  - Tính score, percentage, passed, per-question breakdown JSON
  - Set `finalized_at = NOW()`

### 3.4 — Result API
- `GET /api/results/:submission_id` — result + breakdown (của current user)
- `GET /api/results` — list kết quả của current user
- `GET /api/results/exam/:exam_id` — class stats (teacher/admin): avg, pass rate, distribution

### Quality gate
- `go build ./...` — 0 errors
- End-to-end test: create question → create exam → add questions → publish → start submission → finalize → get result
- Auto-grading tính đúng score

---

## Phase 4: Frontend Foundation + Auth + Dashboard (~2 ngày)

### 4.1 — Next.js app scaffold
```
frontend/
├── app/
│   ├── layout.tsx           # Providers: Supabase, TanStack Query, Zustand
│   ├── (auth)/              # Public routes
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── onboarding/page.tsx
│   └── (app)/               # Protected routes
│       ├── layout.tsx        # TopNav + Sidebar
│       ├── dashboard/page.tsx
│       └── ...
├── components/
│   ├── ui/                  # Button, Card, Input, Badge, Skeleton, ThemeToggle
│   ├── BoCharacter.tsx      # Bò mascot
│   └── layout/             # TopNav, Sidebar
├── lib/
│   ├── supabase/            # createClient (browser + server)
│   ├── api/                 # Typed fetch wrapper → Go API
│   └── utils/               # cn(), formatters
├── store/
│   ├── auth.ts              # Zustand: user, session
│   └── theme.ts             # Zustand: theme, persist
└── hooks/
    └── useCountUp.ts · useInView.ts
```

### 4.2 — Supabase Auth integration
- `lib/supabase/client.ts` — createBrowserClient
- `lib/supabase/server.ts` — createServerClient (for Server Components)
- Middleware: `middleware.ts` — refresh session, redirect unauthenticated to /login
- After signup/login: call `POST /api/auth/sync` để tạo profile

### 4.3 — Auth pages
LoginPage: email + password, React Hook Form + Zod, `supabase.auth.signInWithPassword`
RegisterPage: name + email + password + role, `supabase.auth.signUp`
OnboardingPage: 3 steps — Welcome (Bò waving) → role confirm → display name

### 4.4 — Shared UI components
Button (5 variants), Card, Input, Badge, Skeleton, ThemeToggle — từ design tokens.
BoCharacter: pose, size, message props; idle breathing animation; speech bubble.

### 4.5 — Dashboard page
- Bò hero banner (happy pose, animated entrance)
- Stat cards: Total Exams · Active Submissions · Avg Score · Streak (useCountUp, 800ms skeleton)
- Bar chart (Recharts): score distribution
- Quick Actions: 4 cards → /exams/create, /question-bank, /reports, /achievements

### Quality gate
- `next build` — 0 errors, 0 warnings
- Login → redirect to /dashboard
- Dashboard loads within 2s
- Dark mode toggles correctly

---

## Phase 5: Frontend Exam + Question + Results (~2 ngày)

### 5.1 — Question Bank page (`/question-bank`)
- Filter sidebar: subject, difficulty stars, type, tags
- DataTable: sortable, paginated, bulk select
- "+ Add" button → right drawer (Framer Motion slide)
- CreateQuestionForm in drawer: type selector, content, options A-D, correct answer, difficulty stars
- Bò empty state (thinking pose) khi không có questions

### 5.2 — Create Exam (5-step stepper `/exams/create`)
Step 1: Basic info (title, subject, duration, max attempts)
Step 2: Select questions (DataTable từ question bank, filter + multi-select)
Step 3: Settings (show result immediately, randomize, access code)
Step 4: Preview (read-only student view)
Step 5: Publish confirmation → `POST /api/exams` + publish

### 5.3 — Take Exam (`/exams/[id]/take`)
- Left: QuestionCard (text + options A/B/C/D, flag button, prev/next)
- Right sidebar: navigator grid (unanswered/answered/flagged/current colors)
- Timer countdown: warning < 5min (amber pulse), critical < 1min (red flash), Bò micro at 5min
- Auto-save to localStorage every 30s
- Submit modal: summary → confirm → finalize

### 5.4 — Result page (`/result/[id]`)
- Score ring (SVG, animated dashoffset 1200ms)
- Bò hero (pose + message theo score range: <50% sad, 50-80% ok, >80% celebrate)
- Score count-up + pass/fail badge
- Per-question accordion: correct ✓ wrong ✗ skipped — với correct answer

### 5.5 — Reports page (`/reports`)
- Stat cards: avg score, pass rate, completion rate
- Area chart: score trends
- DataTable: per-student (teacher view)
- Achievements: streak card (Bò + flame), XP bar, badge grid

### Quality gate
- `next build` — 0 errors
- Timer auto-submit works
- Auto-save verified in localStorage
- Bò shows correct pose per score range
- Dark mode correct on all pages

---

## Phase 6: Polish (~1 ngày)

NO new features — only refinement.

### 6.1 — Animation audit
- All transitions 150ms ease-out
- Sidebar collapses smoothly (300ms)
- Modals scale-in from center
- Bò idle breathing consistent across all screens

### 6.2 — Dark mode audit
- Mọi component đúng trong dark mode
- Charts, badges, toasts, skeletons readable
- No hardcoded colors anywhere

### 6.3 — Responsive audit
- 375px: single column, bottom tab bar
- 768px: 2-col grids, icon-only sidebar
- 1024px+: full sidebar layout
- Max-width: `max-w-7xl mx-auto`
- Touch targets ≥ 44px

### 6.4 — Code cleanup
- `go vet ./...` — 0 warnings
- `next build` — 0 warnings
- Remove debug logs
- All TypeScript strict, no `any`
- Every component file ≤ 150 lines

### Quality gate — ALL must pass
- `next build` — 0 errors, 0 warnings
- `go build ./...` — 0 errors
- `docker-compose build` — 0 failures

