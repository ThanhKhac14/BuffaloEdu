# Prompts — Copy-paste cho từng phase

Mỗi phase là 1 prompt riêng biệt gửi cho **Claude Code** (hoặc GitHub Copilot Agent mode).
Copy nguyên khối prompt, paste vào, chờ hoàn thành, verify quality gate, rồi mới chuyển phase tiếp theo.

> **Quy tắc vàng**: Luôn bắt đầu bằng lệnh đọc 4 file context. AI phải đọc context trước khi code bất cứ thứ gì.

---

## Prompt 1: Foundation — Backend

```
Read and strictly follow these files before writing any code:
- agents.md (your roles and responsibilities)
- rules.md (all project rules — non-negotiable)
- tasks.md (task list)
- design-system.md (all visual specs)

Execute Phase 1 from tasks.md completely.

Summary of Phase 1:
1. Scaffold monorepo folder structure exactly as defined in tasks.md §1.1
2. Create all .proto files for 8 services (auth, user, profile, question-bank, exam, submission, result, notification) — each with healthz RPC
3. Configure buf.yaml and buf.gen.yaml, run buf generate, verify stubs generated
4. Create root docker-compose.yml with all services, networks, volumes as defined in tasks.md §1.3
5. Create .env.example documenting all environment variables

After completion:
- Run: buf lint — must pass 0 errors
- Run: buf generate — must succeed
- Run: docker-compose config — must be valid YAML

Only output code. No explanations.
```

---

## Prompt 2: Auth & User Services

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 2 from tasks.md.

Build 4 services following the Go service template in rules.md:
1. auth service — Register, Login, Logout, RefreshToken, ValidateToken
   - JWT: access 15min / refresh 7d stored in Redis
   - bcrypt cost 12
   - Prometheus metrics interceptor
2. user service — CRUD + roles (admin/teacher/student) + soft delete
3. profile service — GetProfile, UpdateProfile
4. gateway — REST routes → gRPC fan-out, JWT middleware, CORS, rate limit, /healthz

Each service: cmd/main.go + internal/{handler,service,repository,middleware,model} + config + migrations + Dockerfile.

After completion:
- Run: go build ./... — 0 errors
- Run: go vet ./... — 0 warnings
- Run: docker-compose build auth user profile gateway — must succeed

Only output code. No explanations.
```

---

## Prompt 3: Exam Core Services

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 3 from tasks.md.

Build 5 services:
1. question-bank — CRUD questions, types (multiple_choice/true_false/short_answer), search, bulk import
2. exam — CRUD exams, RandomizeQuestions, Redis cache for published exams (TTL 10min)
3. submission — StartSubmission, SubmitAnswer, FinalizeSubmission + auto-grading + RabbitMQ publish
4. result — GetResult, ListResultsByStudent, ListResultsByExam, GetClassPerformance
5. notification — RabbitMQ consumer only, consumes submission.completed, structured log

Each service follows Go service template from rules.md.
RabbitMQ: exchange buffaloedu.events, routing key submission.completed.
Redis cache key: exam:published:{exam_id}

After completion:
- Run: go build ./... — 0 errors
- Run: docker-compose build — all services succeed

Only output code. No explanations.
```

---

## Prompt 4: Infrastructure — Traefik + CI/CD

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 4 from tasks.md.

Build infrastructure config:
1. Traefik v3 static config (infra/traefik/traefik.yml):
   - Entrypoints: web(80→443 redirect), websecure(443 TLS), traefik(8080), metrics(9090)
   - Let's Encrypt certResolver, acme.json in named volume
   - Docker provider: exposedByDefault false
   - File provider: dynamic/ directory

2. Dynamic config (infra/traefik/dynamic/):
   - middlewares.yml: security-headers, rate-limit(100/s), auth-rate-limit(10/min), CORS, compress, circuit-breaker, retry, dashboard-auth
   - tls.yml: min TLS 1.2, strong cipher suites

3. Docker labels for all services in docker-compose.yml:
   - gateway → api.buffaloedu.app (with CORS + rate-limit + circuit-breaker)
   - shell-app → buffaloedu.app + www
   - grafana → grafana.buffaloedu.app
   - dashboard → traefik.buffaloedu.app (basicAuth)
   - MFE remotes → internal network only (no public exposure)

4. Prometheus config (infra/prometheus/prometheus.yml) — scrape all services :9090

5. Grafana provisioning: datasource + 3 dashboard JSONs (traefik, go-services, buffaloedu-business)

6. GitHub Actions workflows:
   - proto-validate.yml (buf lint + breaking check on PR)
   - backend-ci.yml (matrix: go vet + test + docker build per service)
   - frontend-ci.yml (matrix: type-check + lint + next build per MFE)
   - deploy-staging.yml (push to main: SSH + docker-compose pull + up + healthcheck)
   - performance-test.yml (weekly k6 scripts)

After completion:
- Validate: docker run --rm traefik:v3.0 traefik --dry-run — 0 errors
- Verify GitHub Actions YAML syntax

Only output code. No explanations.
```

---

## Prompt 5: k6 Performance Tests

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 5 from tasks.md.

Create 4 k6 test scripts in k6/scripts/:
1. login.js — POST /auth/login · 100 VUs · 30s · ramp 10s up/down
2. submit_exam.js — POST /submissions/finalize · 50 VUs · 60s
3. fetch_result.js — GET /results/{id} · 200 VUs · 30s
4. question_bank.js — GET /questions · 100 VUs · 30s

Each script must have:
- Realistic test data (Vietnamese names, real-looking exam content)
- Thresholds: http_req_duration p(95) < 500ms, http_req_failed rate < 0.01
- Ramp-up stage (10s) → sustain → ramp-down (10s)
- Setup function with auth token acquisition

After completion:
- Run: k6 run --dry-run k6/scripts/login.js — 0 syntax errors

Only output code. No explanations.
```

---

## Prompt 6: Frontend Foundation + Shell App

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 6 from tasks.md.

Build frontend foundation:
1. Shared UI library (frontend/shared/ui/):
   - Import tokens from stitch-export (tokens.css + tokens.json)
   - Configure tailwind.config.ts to extend all tokens
   - Components: Button (5 variants, 3 sizes, loading state), Badge (6 variants), Card + sub-components, Input (with label + error), Skeleton (shimmer)

2. Shared utilities (frontend/shared/):
   - utils/cn.ts, utils/formatters.ts (formatScore, formatDate, formatDuration)
   - types/index.ts — ALL TypeScript interfaces (User, Question, Exam, Submission, Result, etc.)
   - store/auth.ts — Zustand (user, token, isAuthenticated, login, logout)
   - store/theme.ts — Zustand (theme toggle, localStorage persist, prefers-color-scheme)
   - api/client.ts — typed fetch wrapper (base URL, auto-attach JWT, refresh on 401)
   - api/auth.ts + api/exam.ts + api/question.ts + api/result.ts
   - hooks/useTheme.ts + hooks/useCountUp.ts + hooks/useInView.ts

3. BoCharacter.tsx (frontend/shared/ui/):
   - Props: pose, size, outfit?, message?, animate?
   - PNG from /public/mascot/bo-[pose]-[size].png
   - Hat as SEPARATE Framer Motion layer (animates independently)
   - Idle: scale 1→1.02→1, 3s loop, ease-in-out
   - Hat idle: rotateZ ±3deg, 4s loop
   - Speech bubble: Plus Jakarta Sans, radius-xl, surface-1 bg, shadow-lg
   - Disable all animation on prefers-reduced-motion

4. Shell app (frontend/shell-app/):
   - Module Federation host config — remotes for all 5 MFEs
   - Layout: TopNav + Sidebar (collapsible 240→64px, drawer on mobile) + main slot
   - All routes lazy-load remote MFE pages with Suspense + Skeleton fallback
   - Toast system: slide-in bottom-right, 4s dismiss, max 3 stacked
   - Keyboard shortcuts modal (Shift+?)
   - Dark mode toggle wired to theme store
   - Error boundaries per remote

After completion:
- Run: next build (shell-app) — 0 errors 0 warnings
- ThemeToggle works and persists
- BoCharacter renders with breathing animation

Only output code. No explanations.
```

---

## Prompt 7: mfe-auth + mfe-dashboard

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 7 from tasks.md.

Build 2 MFE remote apps:

mfe-auth (port 3001):
1. LoginPage — email + password + show/hide, React Hook Form + Zod, inline errors, POST /auth/login → Zustand
2. RegisterPage — name + email + password + confirm + role selector, Zod validation, POST /auth/register
3. OnboardingPage — 3-step wizard:
   - Step 1: Bò hero (happy, Outfit A), waving, speech bubble "Xin chào! Tao là Bò, cùng cày thôi! 🐃"
   - Step 2: Role confirmation + subject selection (chip multi-select)
   - Step 3: Profile setup (display name, avatar upload stub)
   - Framer Motion page transitions between steps
   - 3-dot progress indicator

mfe-dashboard (port 3002):
1. DashboardPage:
   - Bò hero banner: teal-to-navy gradient (#0EA5E9→#1B2F4E), Bò Outfit B (happy), Framer Motion entrance
   - 4 stat cards: Total Students · Active Exams · Pending Results · Daily Streak
     - 800ms skeleton loading → staggered fade-in → useCountUp
   - Bar chart (Recharts): primary color bars, grow from bottom on mount
   - Activity feed: 6 items with icons, timestamps, left timeline border
   - Quick Actions: 4 cards → /exams/create · /question-bank · /reports · /achievements

After completion:
- Run: next build in mfe-auth + mfe-dashboard — 0 errors
- Both remotes expose pages via remoteEntry.js
- Bò appears with correct pose and message
- Dark mode correct on all screens
- 375px mobile layout correct

Only output code. No explanations.
```

---

## Prompt 8: mfe-exam

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 8 from tasks.md.

Build mfe-exam (port 3003) — 3 pages:

1. CreateExamPage — 5-step stepper:
   Step 1: title, subject, duration, max attempts, description
   Step 2: question selection from bank (DataTable, filter by subject/difficulty, check to select)
   Step 3: settings (show result immediately toggle, randomize order, access code optional)
   Step 4: preview — read-only student view
   Step 5: publish confirmation → POST /exams → toast success
   Animated stepper indicator slides between steps. React Hook Form + Zod.

2. TakeExamPage — exam taking:
   Layout: question panel (flex-1) + navigator sidebar (w-64, hidden mobile)
   - QuestionCard: text + A/B/C/D options (correct border-primary on select)
   - Flag button (BookmarkIcon) per question
   - Navigator: grid of numbered buttons — unanswered(muted) / answered(primary) / flagged(warning)
   - Timer widget: countdown, warning(< 5min amber pulse), critical(< 1min red flash)
   - Bò micro appears at 5min beside timer
   - Auto-save to localStorage every 30s (key: exam_progress_{submissionId})
   - Submit modal: shows answered/total/flagged count → confirm → POST /submissions/finalize

3. ResultPage:
   - Score SVG ring (animated dashoffset from 0, 1200ms)
   - Score count-up (1200ms easeOut)
   - Bò hero (pose + outfit + message based on score %)
   - Pass/Fail badge
   - Stats row: time taken · correct/total · percentage
   - Accordion: per-question correct ✓ / wrong ✗ / skipped with correct answer shown
   - Export PDF button → toast "Đang chuẩn bị bản in..."

Score thresholds for Bò:
  90–100% → celebrating, Outfit B, "Đỉnh của chóp! Bò tự hào về mày 🌟"
  70–89%  → proud, Outfit B, "Làm tốt lắm! Trâu cày không bỏ cuộc 💪"
  50–69%  → encouraging, Outfit A, "Cày thêm tí nữa! Lần sau chắc hơn 🎯"
  < 50%   → sad, Outfit A, "Đừng nản! Trâu ngã còn đứng dậy được 📚"

After completion:
- Run: next build mfe-exam — 0 errors
- Timer countdown verified
- Auto-save to localStorage works
- Score ring animates on mount
- Bò shows correct pose for all 4 score ranges
- Dark mode correct

Only output code. No explanations.
```

---

## Prompt 9: mfe-question + mfe-reports

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 9 from tasks.md.

Build 2 MFE remote apps:

mfe-question (port 3004):
QuestionBankPage:
- Left filter sidebar: subject chips, difficulty stars (1-5), type selector, tag multi-select
- DataTable: ID · preview · subject · difficulty · type · date — sortable, bulk select, pagination
- "+ Add Question" FAB → right drawer (Framer Motion translateX 100%→0)
- CreateQuestionForm in drawer:
  - Type segmented control (Multiple Choice / True False / Short Answer)
  - Content textarea, A/B/C/D options (show only if multiple choice), correct answer selector
  - Difficulty stars (1-5), subject input, tags input
  - Submit → POST /questions → toast → close drawer → refetch table
- Bò (thinking, medium) empty state when no questions

mfe-reports (port 3005):
ReportsPage:
- Filter bar: class/exam/date-range (React Hook Form)
- 4 stat cards: avg score · pass rate · completion rate · total submissions (useCountUp)
- Area chart (Recharts): score trend over time — primary/success colors
- Bar chart: score distribution — 10-point buckets
- DataTable: student · score · time · pass/fail badge — sortable
- Export CSV → toast
- Bò (thinking, medium) empty state if no data

AchievementsPage:
- Streak card: amber bg, Bò streak-fire (Outfit B), flame Framer Motion flicker, streak count
- XP bar: fills with spring animation (overshoot) on mount
- Badge grid: earned (full color, shadow-md on hover) / locked (grayscale, lock icon overlay)
- Milestone markers: 7 days · 30 days · 100 days — Bò celebrating at reached milestones

After completion:
- Run: next build mfe-question + mfe-reports — 0 errors
- Drawer animation smooth
- Charts render correctly
- XP bar spring animation works
- Dark mode correct on all screens

Only output code. No explanations.
```

---

## Prompt 10: Polish & Responsive

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 10 from tasks.md.

Polish pass — NO new features. Refinement only.

1. ANIMATION TUNING:
   - All standard transitions: 150ms ease-out
   - Sidebar collapse: width 240→64px + icon crossfade, 300ms
   - Tab/stepper indicators slide smoothly (not jump)
   - Modals scale-in from 0.95 → 1
   - Question option selection: scale 0.98→1, 80ms spring
   - Bò idle breathing consistent across all screens (not jittery on re-renders)

2. DARK MODE AUDIT:
   - Every component correct in dark mode — go screen by screen
   - Charts readable (axes, tooltips, grid lines)
   - Badges, toasts, skeletons all correct
   - Bò speech bubble readable in both modes
   - Score ring colors correct in dark mode

3. RESPONSIVE AUDIT:
   - 375px: single column, bottom tab bar (5 items), drawer navigation, no overflow
   - 768px: icon-only sidebar, 2-col grids, tablet chart sizing
   - 1024px+: full sidebar + content
   - 1280px+: content max-width 1280px centered
   - All touch targets ≥ 44×44px
   - Exam navigator collapses correctly on mobile (slide-up drawer)

4. ACCESSIBILITY:
   - Focus rings on ALL interactive elements
   - Aria-labels on all icon-only buttons
   - Screen reader labels on Bò images (alt text)
   - No color-only information (always icon + color)

After completion:
- Run: next build all MFEs — 0 errors 0 warnings
- Visual check all screens in light + dark
- Resize check at 375px, 768px, 1024px, 1440px

Only output code. No explanations.
```

---

## Prompt 11: Refactor + Docs + Deploy

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Execute Phase 11 from tasks.md.

Final phase:

1. FRONTEND CODE AUDIT:
   - Remove all unused imports and variables
   - Fix any TypeScript `any` types
   - Extract any pattern used 3+ times into shared/ui/
   - Every file ≤ 150 lines — split if larger
   - Verify consistent naming (kebab-case files, PascalCase components)

2. BACKEND CODE AUDIT:
   - go vet ./... on all services — 0 warnings
   - Remove debug logs
   - Verify all migrations have .down.sql
   - Verify all goroutines have context cancellation

3. FINAL BUILDS:
   - next build all 6 frontend apps — 0 errors 0 warnings
   - go build ./... — 0 errors
   - docker-compose build — 0 failures
   - buf lint — 0 errors

4. ROOT README.md — create with:
   - Project overview: BuffaloEdu, Bò mascot, what it does, who it's for
   - Mermaid architecture diagram (all services + Traefik + MFEs + RabbitMQ + Redis + Prometheus)
   - Prerequisites: Go 1.22+, Node 20+, Docker, buf CLI, k6
   - Quick start: 4 commands from clone to running
   - Service catalogue table
   - MFE catalogue table
   - How to add a new backend service (7 steps)
   - How to add a new MFE (5 steps)
   - Environment variables full table
   - Monitoring section (Grafana URL, dashboards, credentials)

5. PRINT final summary:
   Total files · total components · total Go services · total routes · total lines of code

Only output code. No explanations.
```

---

## Post-deploy (nếu còn budget)

Review app sau khi deploy. Fix visual bugs, dark mode issues, broken animations:

```
Read and follow: agents.md, rules.md, design-system.md

Review the deployed app. List all visual bugs, broken interactions, incorrect dark mode, responsive issues. Fix all of them. Run next build after each fix. Only output code.
```

Hoặc thêm tính năng notification dropdown:

```
Read and follow: agents.md, rules.md, tasks.md, design-system.md

Add notification dropdown to shell-app TopNav:
- Bell icon with unread count badge
- Click → dropdown with 5 notification items (new result, exam published, student joined, etc.)
- Read/unread states (bold vs normal)
- "Mark all as read" clears badge
- Framer Motion scale-in animation on open
- Auto-close on click outside
Wire to toast when clicking a notification item.
Run next build — 0 errors. Only output code.
```
