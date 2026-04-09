# Task Plan — BuffaloEdu

Execute phases in order. Do NOT skip phases. Each phase must pass quality gate before moving on.
Read `design-system.md` before writing any component. Read `rules.md` before any code. Read `agents.md` to know your role.

---

## Phase 1: Foundation — Backend (~$4)

### 1.1 — Monorepo scaffold
```
buffaloedu/
├── proto/
│   ├── buf.yaml
│   ├── buf.gen.yaml
│   └── {service}/v1/*.proto
├── services/
│   ├── gateway/ auth/ user/ profile/
│   ├── question-bank/ exam/ submission/ result/ notification/
├── frontend/
│   ├── shell-app/ mfe-auth/ mfe-dashboard/
│   ├── mfe-exam/ mfe-question/ mfe-reports/
│   └── shared/
├── infra/traefik/ prometheus/ grafana/
├── .github/workflows/
├── docker-compose.yml
├── .env.example
└── README.md
```

### 1.2 — Protobuf definitions
Create `.proto` files for all 8 services: auth, user, profile, question-bank, exam, submission, result, notification.
Each must include: service definition, request/response messages, `healthz` RPC.
Configure `buf.yaml` and `buf.gen.yaml` to generate Go stubs into `services/{name}/gen/`.

### 1.3 — Root docker-compose.yml
Services: traefik + gateway + all 8 backend services + postgres×8 + redis + rabbitmq + prometheus + grafana.
Networks: `buffaloedu_public` (traefik + gateway + frontends) · `buffaloedu_internal` (gRPC only, internal: true).
Volumes: one per postgres, redis, rabbitmq, traefik_acme, prometheus_data, grafana_data.

### 1.4 — .env.example
Document ALL environment variables: DB_DSN, REDIS_URL, RABBITMQ_URL, JWT_SECRET, GRPC ports, service names.

### Quality gate
- `buf generate` — 0 errors, stubs generated
- `docker-compose config` — valid YAML
- All `.proto` files lint clean: `buf lint`

---

## Phase 2: Auth & User Services (~$4)

### 2.1 — auth service
gRPC methods: Register, Login, Logout, RefreshToken, ValidateToken.
- JWT: access 15min, refresh 7d, stored in Redis (`session:{user_id}:{token_id}`)
- Password: bcrypt cost 12
- Follow Go service template from `rules.md`
- Prometheus metrics interceptor: request count + latency histogram
- SQL migrations: `001_users.up.sql`

### 2.2 — user service
gRPC methods: CreateUser, GetUser, UpdateUser, DeleteUser, ListUsers, ChangeRole.
- Roles: `admin` · `teacher` · `student`
- Soft delete (`deleted_at`)
- SQL migrations

### 2.3 — profile service
gRPC methods: GetProfile, UpdateProfile.
- One profile per user (FK to user_id)
- SQL migrations

### 2.4 — gateway (REST entry)
Routes all REST → internal gRPC.
Middleware: JWT validation, request logging, rate limiting, CORS.
`GET /healthz` → 200 OK.

### Quality gate
- `go build ./...` in each service — 0 errors
- `go vet ./...` — 0 warnings
- `docker-compose build` — all 4 services build

---

## Phase 3: Exam Core Services (~$4)

### 3.1 — question-bank service
gRPC methods: CreateQuestion, GetQuestion, UpdateQuestion, DeleteQuestion, ListQuestions, SearchQuestions, BulkImport.
- Types: `multiple_choice` · `true_false` · `short_answer`
- Fields: content, options[], correct_answer, difficulty(1-5), subject, tags[], created_by
- Full-text search on content
- SQL migrations

### 3.2 — exam service
gRPC methods: CreateExam, PublishExam, GetExam, ListExams, UpdateExam, DeleteExam, RandomizeQuestions.
- RandomizeQuestions: select N questions filtered by subject/difficulty/tags
- Cache published exam: Redis key `exam:published:{exam_id}` TTL 10min
- SQL migrations

### 3.3 — submission service
gRPC methods: StartSubmission, SubmitAnswer, FinalizeSubmission, GetSubmission.
- Auto-grading on FinalizeSubmission: compare answers → calculate score
- On finalize: publish RabbitMQ event to exchange `buffaloedu.events`, routing key `submission.completed`
  Payload: `{ submission_id, student_id, exam_id, score, passed }`
- SQL migrations

### 3.4 — result service
gRPC methods: GetResult, ListResultsByStudent, ListResultsByExam, GenerateReport, GetClassPerformance.
- Store: score, percentage, passed, time_taken_seconds, per_question breakdown
- SQL migrations

### 3.5 — notification service
- RabbitMQ consumer only (no gRPC server)
- Consumes `submission.completed`
- For now: structured log the event (future: email/websocket)

### Quality gate
- `go build ./...` — 0 errors
- `buf generate` still clean
- All 5 services build in docker-compose

---

## Phase 4: Infrastructure — Traefik + CI/CD (~$3)

### 4.1 — Traefik v3
`infra/traefik/traefik.yml` — static config: entrypoints (80→443 redirect, 443 TLS, 8080 dashboard, 9090 metrics).
`infra/traefik/dynamic/middlewares.yml` — security-headers, rate-limit, auth-rate-limit, CORS, compress, circuit-breaker.
`infra/traefik/dynamic/tls.yml` — TLS options, min TLS 1.2.

Docker labels per service:
- gateway: `api.buffaloedu.app` with CORS + rate-limit
- shell-app: `buffaloedu.app` + `www.buffaloedu.app`
- grafana: `grafana.buffaloedu.app`
- dashboard: `traefik.buffaloedu.app` + basicAuth

### 4.2 — Prometheus + Grafana
`infra/prometheus/prometheus.yml` — scrape all services on `:9090/metrics`.
Grafana provisioning: datasource (prometheus) + 3 dashboards (traefik, go-services, buffaloedu-business).

### 4.3 — GitHub Actions workflows
- `proto-validate.yml` — buf lint + buf breaking on PR
- `backend-ci.yml` — matrix build per service: go vet + test + docker build
- `frontend-ci.yml` — matrix build per MFE: type-check + lint + build
- `deploy-staging.yml` — on push to main: SSH + docker-compose pull + up
- `performance-test.yml` — weekly k6 scripts

### Quality gate
- Traefik config validates: `docker run --rm -v $(pwd)/infra/traefik:/etc/traefik traefik:v3.0 traefik --configFile=/etc/traefik/traefik.yml --dry-run`
- GitHub Actions YAML validates (no syntax errors)

---

## Phase 5: k6 Performance Tests (~$2)

### 5.1 — k6 scripts
Location: `k6/scripts/`

- `login.js` — POST /auth/login · 100 VUs · 30s
- `submit_exam.js` — POST /submissions/finalize · 50 VUs · 60s
- `fetch_result.js` — GET /results/{id} · 200 VUs · 30s
- `question_bank.js` — GET /questions · 100 VUs · 30s

Each script: ramp-up 10s → sustain → ramp-down 10s.
Thresholds: `p95 < 500ms`, `error_rate < 0.01`.

### Quality gate
- `k6 run --dry-run k6/scripts/login.js` — no syntax errors

---

## Phase 6: Frontend Foundation + Shell App (~$4)

### 6.1 — Shared UI library
`frontend/shared/ui/`
- Import `tokens.css` and `tokens.json` from stitch-export
- Configure `tailwind.config.ts` to extend tokens
- Components: Button (5 variants, 3 sizes), Badge (6 variants), Card + sub-components, Input, Skeleton, ThemeToggle

### 6.2 — Shared utilities
`frontend/shared/`
- `utils/cn.ts` — classname merger
- `utils/formatters.ts` — formatScore, formatDate, formatDuration
- `types/index.ts` — ALL TypeScript interfaces
- `store/auth.ts` — Zustand auth store (user, token, isAuthenticated, login, logout)
- `store/theme.ts` — Zustand theme store (theme, toggleTheme, persist localStorage)
- `api/client.ts` — typed fetch wrapper (base URL from env, auto-attach token, refresh on 401)
- `api/auth.ts` · `api/exam.ts` · `api/question.ts` · `api/result.ts` — domain API modules
- `hooks/useTheme.ts` · `hooks/useCountUp.ts` · `hooks/useInView.ts`

### 6.3 — BoCharacter component
`frontend/shared/ui/BoCharacter.tsx`
- Props: `pose`, `size`, `outfit?`, `message?`, `animate?`
- Load PNG from `/public/mascot/bo-[pose]-[size].png`
- Hat as separate Framer Motion layer (animate independently)
- Idle breathing animation (scale 1→1.02→1, 3s loop)
- Speech bubble: Plus Jakarta Sans, radius-xl, white/surface-1 bg, shadow-lg
- Disable all animation when `prefers-reduced-motion` is set

### 6.4 — Shell app
`frontend/shell-app/`
- Next.js App Router + Module Federation host config
- Layout: TopNav + Sidebar (collapsible) + main content slot
- Routes: lazy-load all remote MFE pages
- Global toast system (slide-in bottom-right, 4s auto-dismiss, max 3 stacked)
- Keyboard shortcuts modal (Shift+?) listing all shortcuts
- Dark mode toggle wired to theme store
- Error boundary per remote MFE with fallback UI

### Quality gate
- `next build` in shell-app — 0 errors
- BoCharacter renders correctly in isolation
- Theme toggle works, persists to localStorage

---

## Phase 7: mfe-auth + mfe-dashboard (~$4)

### 7.1 — mfe-auth
Pages: LoginPage · RegisterPage · OnboardingPage (3 steps)

LoginPage:
- Email + password, show/hide toggle
- React Hook Form + Zod validation
- Submit → POST /auth/login → store token in Zustand auth store
- Error inline (not redirect)
- "Forgot password" link (stub)

RegisterPage:
- Name, email, password + confirm, role selector (Teacher/Student)
- Zod schema validation
- Submit → POST /auth/register → auto-login

OnboardingPage:
- Step 1: Welcome — Bò hero pose, waving, Outfit A
- Step 2: Role confirmation + subject selection
- Step 3: Profile setup (display name, avatar upload stub)
- Progress indicator (3 dots)
- Framer Motion page transitions between steps

### 7.2 — mfe-dashboard
DashboardPage:
- Bò hero banner: teal-navy gradient, Bò Outfit B (happy pose), animated entrance
- Stat cards: Total Students · Active Exams · Pending Results · Daily Streak
  - useCountUp hook, 800ms skeleton loading then staggered fade-in
- Bar chart (Recharts): exam score distribution — primary color bars, grow animation on mount
- Recent Activity feed: 6 items with icons, timestamps
- Quick Actions: 4 cards linking to /exams/create, /question-bank, /reports, /achievements

### Quality gate
- `next build` in mfe-auth + mfe-dashboard — 0 errors
- Both remotes register correctly in shell
- Bò renders with correct pose and message
- Dark mode correct on all screens

---

## Phase 8: mfe-exam (~$4)

### 8.1 — Create Exam (5-step stepper)
Step 1: Basic info — title, subject, duration, max attempts, description
Step 2: Question selection — DataTable from question bank, filter by subject/difficulty, select N questions
Step 3: Settings — show result immediately, randomize order, access code (optional)
Step 4: Preview — read-only student view of exam
Step 5: Publish — confirmation, POST /exams + publish

All steps: React Hook Form, Zod, inline validation.
Stepper: animated indicator sliding between steps.

### 8.2 — Take Exam
Layout: question panel left (flex-1) · navigator sidebar right (w-64, hidden mobile)

Question panel:
- Current question: text + A/B/C/D options (QuestionCard component)
- Option click → answered state + navigator updates
- Flag question button (bookmark icon)
- Previous / Next buttons

Navigator sidebar:
- Grid of question numbers
- Color-coded: unanswered (muted) · answered (primary) · flagged (warning) · current (primary bold border)
- Click → jump to question

Timer widget (top of screen):
- useTimer hook: countdown from duration_minutes
- Normal → Warning (< 5min, amber, pulse) → Critical (< 1min, red, flash)
- Bò micro appears at 5min warning
- Auto-submit when reaches 0

Auto-save: localStorage every 30s (`exam_progress_{submission_id}`)

Submit confirmation modal: summary (answered/total/flagged) → confirm → POST /submissions/finalize

### 8.3 — Result Page
- Score circle (SVG ring, animated dashoffset, 1200ms)
- Bò hero (pose/outfit/message based on score %)
- Score count-up (1200ms easeOut)
- Pass/Fail badge
- Stats row: time taken · correct count · score percentage
- Per-question accordion: correct ✓ / wrong ✗ / skipped — with correct answer shown
- Export PDF button (stub → toast "Đang chuẩn bị bản in...")

### Quality gate
- `next build` mfe-exam — 0 errors
- Timer works correctly
- Auto-save to localStorage verified
- Bò shows correct pose for each score range
- Dark mode correct on all 3 pages

---

## Phase 9: mfe-question + mfe-reports (~$3)

### 9.1 — mfe-question
QuestionBankPage:
- Filter sidebar: subject, difficulty (1-5 stars), type, tags (multi-select)
- DataTable: ID · content preview · subject · difficulty · type · created date
  - Sortable columns, bulk select, row hover
  - Pagination
- "+ Add Question" floating button → right drawer (Framer Motion slide)
- CreateQuestionForm in drawer:
  - Type selector (segmented: Multiple Choice / True False / Short Answer)
  - Content textarea
  - Options A/B/C/D (for multiple choice)
  - Correct answer selector
  - Difficulty stars (1-5)
  - Subject + tags
  - Submit → POST /questions → toast success + close drawer
- Bò empty state (thinking) when no questions

### 9.2 — mfe-reports
ReportsPage:
- Filters: class/exam/date range (React Hook Form)
- Stat cards: avg score · pass rate · completion rate · total submissions
  - useCountUp on all numbers
- Area chart (Recharts): score trends over time
- Bar chart: score distribution per exam
- DataTable: per-student performance (name · score · time · pass/fail)
- Export CSV button (stub → toast)
- Bò empty state (thinking) when no data

AchievementsPage:
- StreakCard: Bò streak-fire (Outfit B), flame animation, amber background
- XP progress bar: fills with spring animation on mount
- Badge grid: earned (full color) / locked (grayscale + lock icon)
- Milestone timeline: 7 / 30 / 100 day markers with Bò celebrating at each

### Quality gate
- `next build` mfe-question + mfe-reports — 0 errors
- Drawer slide animation smooth
- All charts render with correct data
- Bò empty states appear with correct message
- Dark mode correct

---

## Phase 10: Polish & Responsive (~$3)

NO new features — only refinement.

### 10.1 — Animation tuning
- All transitions 150ms ease-out
- Sidebar collapses smoothly (width 240→64px + icon crossfade, 300ms)
- Tab indicators slide (not jump)
- Modals scale-in from center
- Question option selection springs (scale 0.98→1, 80ms)
- Bò idle breathing consistent across all screens

### 10.2 — Dark mode audit
- Every component correct in dark mode
- Charts, badges, toasts, skeletons all readable
- Bò speech bubble readable in both modes
- No hardcoded colors anywhere

### 10.3 — Responsive audit
- 375px: single column, bottom tab bar, drawer navigation
- 768px: icon-only sidebar, 2-col grids
- 1024px+: full layout with sidebar
- 1280px+: content max-width locked
- No horizontal overflow anywhere
- All touch targets ≥ 44px

### 10.4 — Edge cases
- Focus rings on all interactive elements (keyboard navigation)
- Aria-labels on all icon-only buttons
- Empty states on every data screen
- Loading skeletons match exact shape of real content
- Error boundaries tested (remote MFE failure shows fallback)

### Quality gate
- `next build` all MFEs — 0 errors
- All quality gates from previous phases still pass

---

## Phase 11: Refactor + Docs + Deploy (~$2)

### 11.1 — Code audit
- Remove all unused imports, variables
- Fix any TypeScript `any` types
- Move hardcoded strings to locale/config files
- Extract any pattern used 3+ times into shared component
- Verify consistent naming (kebab-case files, PascalCase components)
- Every file ≤ 150 lines (split if larger)

### 11.2 — Backend audit
- All services: `go vet ./...` clean
- Remove debug logs
- Verify all migrations have `.down.sql` counterpart
- Verify all RabbitMQ connections close on shutdown

### 11.3 — Final build
- `next build` all MFEs — 0 errors 0 warnings
- `go build ./...` all services — 0 errors
- `docker-compose build` all — 0 failures

### 11.4 — Documentation
Root README.md must contain:
1. Project overview (BuffaloEdu — what it is, who it's for)
2. Architecture diagram (Mermaid): all services + Traefik + MFEs + RabbitMQ + Redis
3. Prerequisites: Go 1.22+, Node 20+, Docker, buf CLI, k6
4. Quick start: clone → buf generate → docker-compose up → open localhost
5. Service catalogue: service · port · gRPC port · responsibilities
6. MFE catalogue: app · route · owns
7. How to add a new backend service (7 steps)
8. How to add a new MFE (5 steps)
9. Environment variables table
10. Monitoring: Grafana URL, dashboards, credentials

### 11.5 — Final summary
Print: total files · total components · total lines of code · all routes · all services.

### Quality gate — ALL must pass
- `next build` — 0 errors
- `go build ./...` — 0 errors
- `docker-compose build` — 0 failures
- `buf lint` — 0 errors
