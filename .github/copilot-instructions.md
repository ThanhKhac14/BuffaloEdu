# BuffaloEdu — GitHub Copilot Instructions

> Đọc file này đầu tiên. Đây là project context tự động load vào mọi Copilot session.

---

## 🎯 Project

| | |
|---|---|
| **App** | BuffaloEdu (HocTrau) — Online Examination & Learning SaaS |
| **Mascot** | Bò — Trâu Việt Nam đội nón lá, anime 2D cel-shaded |
| **Tagline** | *"Cày thôi!"* |
| **Users** | Teacher · Student · Admin |
| **Style** | Vibe: Đồng quê Việt Nam, tươi sáng (Fresh like Matcha), nhẹ nhàng (Chill) và hài hước (Meme-friendly).

Visuals: Giao diện lớp kính mờ (Glassmorphism) và Botanical/Organic theme trên nền phong cảnh.

Color Rule: Chủ đạo tông Xanh Matcha/Đất nung. TUYỆT ĐỐI KHÔNG dùng bất kỳ sắc độ Tím (Purple/Violet) nào.
 |

---

## 🏗️ Tech Stack

**Backend:** Go 1.24+ · gRPC + Protobuf (buf CLI) · PostgreSQL (pgx/v5 raw SQL) · Redis · RabbitMQ · Prometheus · OpenAPI (gateway REST)

**Frontend:** Next.js 14+ (App Router, TypeScript strict) · Module Federation · Tailwind CSS v4 · Zustand · TanStack Query v5 · React Hook Form + Zod · Framer Motion

**Infra:** Traefik v3 · Supabase (auth, storage, database) · Docker Compose · GitHub Actions · k6

---

## 🚨 Hard Rules (never violate)

### Backend
- **KHÔNG ORM** — `pgx/v5` raw SQL only
- **KHÔNG share PostgreSQL** giữa các services
- **KHÔNG expose gRPC** ports (9001–9009) ra ngoài
- Layering: `handler → service → repository` (strict separation)
- Sau mỗi thay đổi: `go build ./...` — 0 errors

### Frontend
- **KHÔNG hardcode hex** — CSS token classes only (`text-primary`, `bg-surface-1`)
- **KHÔNG `style={{}}`** cho colors/spacing
- `"use client"` chỉ khi cần hooks/events
- Sau mỗi thay đổi: `next build` — 0 errors, 0 warnings
- Loading state trong **150ms**

### Proto
- Sau khi sửa `.proto`: `buf lint` + `buf generate`
- Mọi service phải có `healthz` RPC + Prometheus metrics interceptor

---

## 📁 Repository Structure

```
BuffaloEdu/
├── .github/
│   ├── hooks/                   ← Copilot Cloud Agent hooks
│   ├── agents/                  ← Agent definitions (backend, frontend, devops...)
│   ├── commands/                ← Slash commands (/review /bootstrap /deploy)
│   ├── skills/                  ← Auto-activated skill templates
│   └── copilot-instructions.md ← THIS FILE
├── docs/
│   ├── phases/                  ← Phase-by-phase implementation docs
│   │   ├── phase-01-foundation.md
│   │   ├── phase-02-auth-user.md
│   │   ├── phase-03-exam-core.md
│   │   ├── phase-04-infrastructure.md
│   │   ├── phase-05-k6-tests.md
│   │   ├── phase-06-fe-foundation.md
│   │   ├── phase-07-mfe-auth-dashboard.md
│   │   ├── phase-08-mfe-exam.md
│   │   ├── phase-09-mfe-question-reports.md
│   │   ├── phase-10-polish.md
│   │   └── phase-11-refactor-deploy.md
│   └── shared/
│       ├── architecture.md      ← System architecture overview
│       ├── backend-conventions.md
│       ├── frontend-conventions.md
│       ├── design-system.md
│       └── mascot.md
├── proto/                       ← Protobuf definitions
├── services/                    ← Go microservices
├── frontend/                    ← Next.js MFE apps
├── infra/                       ← Traefik, Prometheus, Grafana
├── k6/                          ← Performance tests
└── scripts/hooks/               ← Copilot hook scripts
```

---

## 🗺️ Services Map

| Service | REST | gRPC | Chức năng |
|---|---|---|---|
| gateway | 8000 | — | REST → gRPC routing, JWT, CORS, rate limit |
| auth | 8001 | 9001 | Register, Login, JWT, Redis sessions |
| user | 8002 | 9002 | CRUD users, roles (admin/teacher/student) |
| profile | 8003 | 9003 | Extended user info, avatar |
| question-bank | 8004 | 9004 | CRUD questions, search, bulk import |
| exam | 8005 | 9005 | Create/publish exams, Redis cache |
| submission | 8006 | 9006 | Submit answers, auto-grading, RabbitMQ |
| result | 8007 | 9007 | Scores, reports, analytics |
| notification | 8008 | — | RabbitMQ consumer |

## 🖥️ Frontend MFE Map

| App | Port | Routes |
|---|---|---|
| shell-app | 3000 | / — layout, nav, auth state |
| mfe-auth | 3001 | /login /register /onboarding |
| mfe-dashboard | 3002 | /dashboard |
| mfe-exam | 3003 | /exams/* /result |
| mfe-question | 3004 | /question-bank |
| mfe-reports | 3005 | /reports /achievements |

---

## ⚡ Slash Commands

| Command | Dùng khi |
|---|---|
| `/review` | Code review theo conventions |
| `/bootstrap service <name>` | Scaffold Go microservice mới |
| `/bootstrap mfe <name>` | Scaffold Next.js MFE mới |
| `/bootstrap proto <name>` | Tạo .proto file mới |
| `/deploy all` | Build + verify toàn bộ |
| `/test-all` | Chạy full test suite |
| `/compact` | Summarize session khi context 70%+ |

---

## 📖 Phase Docs

Đọc file phase tương ứng khi làm việc:

| Phase | File | Nội dung |
|---|---|---|
| 1 | `docs/phases/phase-01-foundation.md` | Monorepo, Protobuf, docker-compose |
| 2 | `docs/phases/phase-02-auth-user.md` | Auth, User, Profile, Gateway services |
| 3 | `docs/phases/phase-03-exam-core.md` | Question, Exam, Submission, Result, Notification |
| 4 | `docs/phases/phase-04-infrastructure.md` | Traefik, Prometheus, GitHub Actions |
| 5 | `docs/phases/phase-05-k6-tests.md` | k6 performance scripts |
| 6 | `docs/phases/phase-06-fe-foundation.md` | Shared UI, BoCharacter, shell-app |
| 7 | `docs/phases/phase-07-mfe-auth-dashboard.md` | mfe-auth + mfe-dashboard |
| 8 | `docs/phases/phase-08-mfe-exam.md` | Create exam, take exam, result |
| 9 | `docs/phases/phase-09-mfe-question-reports.md` | Question bank + reports/achievements |
| 10 | `docs/phases/phase-10-polish.md` | Animation, dark mode, responsive |
| 11 | `docs/phases/phase-11-refactor-deploy.md` | Refactor, docs, final deploy |
