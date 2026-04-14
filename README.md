# 🐃 BuffaloEdu

> **Nền tảng thi trực tuyến — xây dựng bởi 1 người, tối ưu cho người Việt.**

Mascot: **Bò** — Trâu Việt Nam đội nón lá, phong cách anime 2D.  
Tagline: *"Cày thôi!"*

---

## Kiến trúc tổng quan

```
┌─────────────────────────────────────────────────────┐
│                     INTERNET                        │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────▼────────┐
              │   Next.js App   │  :3000  App Router · TypeScript
              └────────┬────────┘
                       │ REST
              ┌────────▼────────┐
              │   Go Monolith   │  :8000  Gin router · pgx/v5
              └────────┬────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
  ┌───────▼───────┐        ┌────────▼───────┐
  │   Supabase    │        │    Supabase    │
  │  PostgreSQL   │        │ Auth + Storage │
  └───────────────┘        └────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Go 1.24+ · Gin router · pgx/v5 raw SQL |
| **Database** | Supabase PostgreSQL (hosted) |
| **Auth** | Supabase Auth (JWT, OAuth, sessions) |
| **Storage** | Supabase Storage (avatars, file uploads) |
| **Frontend** | Next.js 14 · TypeScript strict · App Router |
| **Styling** | Tailwind CSS v4 · Design tokens |
| **Font** | Be Vietnam Pro + JetBrains Mono |
| **State** | Zustand + TanStack Query v5 |
| **Forms** | React Hook Form + Zod |
| **Animation** | Framer Motion (Bò only) |
| **Mascot** | Bò — 2D anime cel-shaded |
| **CI/CD** | GitHub Actions |

---

## Cấu trúc repo

```
BuffaloEdu/
│
├── overview/               ← 🧠 Context files — đọc trước khi code
│   ├── agents.md           ← AI agent roles
│   ├── rules.md            ← Non-negotiable project rules
│   ├── tasks.md            ← 6-phase task plan
│   └── prompts.md          ← Copy-paste prompts cho từng phase
│
├── design/                 ← 🎨 Design system
│   ├── 02-design.md        ← Stitch/AI Studio context block
│   └── design-system/      ← Tokens, components
│
├── mascots/                ← 🐃 Mascot specs
│   └── 00-mascot.md
│
├── services/
│   └── api/                ← Go monolith (1 service)
│       ├── cmd/main.go
│       ├── internal/
│       │   ├── handler/    ← HTTP handlers (Chi)
│       │   ├── service/    ← Business logic
│       │   ├── repository/ ← Raw SQL (pgx/v5)
│       │   └── middleware/ ← JWT, CORS, rate limit
│       └── migrations/     ← SQL files (Supabase CLI)
│
├── frontend/               ← Next.js App Router
│
├── 00-overview.md          ← Architecture map
├── 01-backend.md           ← Backend Copilot prompt
├── 03-frontend.md          ← Frontend Copilot prompt
├── 05-cicd.md              ← GitHub Actions Copilot prompt
└── README.md               ← File này
```

---

## Quick start

```bash
git clone https://github.com/ThanhKhac14/BuffaloEdu.git
cd BuffaloEdu
cp .env.example .env   # điền Supabase keys

# Option A — Supabase hosted (khuyến nghị)
# Tạo project tại supabase.com, copy keys vào .env
supabase db push       # apply migrations

# Option B — Supabase local
supabase start
supabase db push

# Start backend
cd services/api && go run ./cmd/main.go

# Start frontend (terminal mới)
cd frontend && npm install && npm run dev

# Access: http://localhost:3000
```

---

## Database Schema

| Table | Mô tả |
|---|---|
| `profiles` | Extended user info, role (admin/teacher/student), avatar |
| `questions` | Content, options[], correct_answer, difficulty, subject, tags |
| `exams` | Title, duration, settings, published_at |
| `exam_questions` | Pivot: exam ↔ question + order |
| `submissions` | Student exam attempt, started/finalized timestamps |
| `answers` | Per-question answers cho mỗi submission |
| `results` | Score, percentage, passed, time_taken, breakdown JSON |

Auth (users) được quản lý bởi Supabase Auth — không cần table riêng.

---

## API Routes (Go Monolith)

| Method | Route | Mô tả |
|---|---|---|
| POST | `/api/auth/sync` | Sync Supabase user → profile |
| GET/PUT | `/api/users/me` | Profile của user hiện tại |
| CRUD | `/api/questions` | Question bank |
| CRUD | `/api/exams` | Exam management |
| POST | `/api/submissions` | Start/submit exam |
| GET | `/api/results/:id` | Kết quả thi |

---

## Phases

| Phase | Nội dung | File |
|---|---|---|
| 1 | Scaffold: Go monolith + Supabase migrations + docker-compose | `overview/tasks.md` |
| 2 | Auth + User (Supabase Auth sync + profile API) | `overview/tasks.md` |
| 3 | Exam + Question + Submission + Result APIs | `overview/tasks.md` |
| 4 | Frontend: layout + auth + dashboard | `overview/tasks.md` |
| 5 | Frontend: exam + question bank + results | `overview/tasks.md` |
| 6 | Polish: dark mode, responsive, Bò animations | `overview/tasks.md` |

---

## Mascot — Bò 🐃

**Bò** là trâu nước Việt Nam, đội nón lá, phong cách anime 2D cel-shaded.

| Màu | Hex | Vị trí |
|---|---|---|
| Body fur | `#6B4F3A` | Thân |
| Face | `#83604B` | Mặt |
| Belly | `#C9BDB0` | Bụng |
| Eye iris | `#6A4224` + `#D4A44C` | Mắt |
| Nón lá | `#F5E6C8` | Nón |
| Jacket | `#1B2F4E` | Áo formal |
| Cuffs | `#0D9B8A` | Tay áo |

Xem `mascots/00-mascot.md` để có đầy đủ prompts cho tất cả poses.

---

## Design System

- **Font:** Be Vietnam Pro (UI/Body) + JetBrains Mono (code/data)
- **Theme:** Glassmorphism + Botanical/Organic, tông Matcha/Đất nung
- **Primary:** `#0EA5E9` sky-teal · **Secondary:** `#F59E0B` amber
- **Dark mode:** ✅ Class strategy, CSS custom properties
- **No purple/violet anywhere**

Xem `design/design-system/tokens.css` để có đầy đủ color tokens.

---

## License

MIT

---

## Kiến trúc tổng quan

```
┌─────────────────────────────────────────────────────────┐
│                      INTERNET                           │
└──────────────────────────┬──────────────────────────────┘
                           │
                  ┌────────▼────────┐
                  │   Traefik v3    │  Load Balancer · HTTPS · Auto SSL
                  └────────┬────────┘
                           │
                  ┌────────▼────────┐
                  │   API Gateway   │  REST → gRPC fan-out (Go)
                  └────────┬────────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    ┌────▼────┐      ┌──────▼─────┐    ┌─────▼──────┐
    │  auth   │      │    exam    │    │  question  │  ...more
    └─────────┘      └────────────┘    └────────────┘

Frontend (Microfrontend — Module Federation)
┌────────────────────────────────────────────┐
│  shell-app  (host)                         │
│  ├── mfe-auth       /login /register       │
│  ├── mfe-dashboard  /dashboard             │
│  ├── mfe-exam       /exams/*               │
│  ├── mfe-question   /question-bank         │
│  └── mfe-reports    /reports /achievements │
└────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Go 1.24+ · gRPC + Protobuf · PostgreSQL · Redis · RabbitMQ |
| **Frontend** | Next.js 14 · TypeScript · Module Federation · Tailwind CSS v4 |
| **Font** | Be Vietnam Pro + JetBrains Mono |
| **Mascot** | Bò — 2D anime cel-shaded, Adobe Firefly / Gemini |
| **Load Balancer** | Traefik v3 (free · auto-discovery · HTTPS) |
| **Monitoring** | Prometheus + Grafana |
| **CI/CD** | GitHub Actions |
| **Perf Test** | k6 |

---

## Cấu trúc repo

```
BuffaloEdu/
│
├── overview/               ← 🧠 Context files — đọc trước khi code
│   ├── agents.md           ← AI agent roles & responsibilities
│   ├── rules.md            ← Non-negotiable project rules
│   ├── tasks.md            ← 11-phase task plan
│   └── prompts.md          ← Copy-paste prompts cho từng phase
│
├── design/                 ← 🎨 Design system
│   ├── design-system.md    ← Colors, typography, spacing, components
│   └── 02-design.md        ← Stitch/AI Studio context block
│
├── mascots/                ← 🐃 Mascot specs & assets
│   └── 04-mascot.md        ← Firefly/Gemini prompts cho Bò
│
├── 00-overview.md          ← Architecture map
├── 01-backend.md           ← Backend Copilot prompt
├── 03-frontend.md          ← Frontend MFE Copilot prompt
├── 05-cicd.md              ← GitHub Actions Copilot prompt
├── 06-loadbalancer.md      ← Traefik v3 Copilot prompt
│
└── README.md               ← File này
```

---

## Cách sử dụng

### Workflow chuẩn

```
1. overview/prompts.md  → copy từng phase prompt → paste vào Claude Code
2. design/02-design.md  → paste vào Stitch / AI Studio mỗi session
3. mascots/04-mascot.md → paste vào Adobe Firefly / Gemini để generate Bò
```

### Thứ tự thực hiện

```
Phase 1–3   → Backend (Go microservices + Protobuf + Docker)
Phase 4–5   → Infrastructure (Traefik + GitHub Actions + k6)
Phase 6–9   → Frontend (MFE Module Federation)
Phase 10    → Polish & Responsive
Phase 11    → Refactor + Docs + Deploy
```

### Quick start (sau khi scaffold xong)

```bash
git clone https://github.com/ThanhKhac14/BuffaloEdu.git
cd BuffaloEdu

# Generate Protobuf stubs
cd proto && buf generate

# Start everything
docker-compose up -d

# Access
# App:       http://localhost:3000
# Traefik:   http://localhost:8080
# Grafana:   http://localhost:3100  (admin/admin)
# RabbitMQ:  http://localhost:15672 (guest/guest)
```

---

## Services

| Service | REST Port | gRPC Port | Chức năng |
|---|---|---|---|
| gateway | 8000 | — | REST → gRPC routing, JWT, rate limit |
| auth | 8001 | 9001 | Register, Login, JWT, Redis sessions |
| user | 8002 | 9002 | CRUD users, roles (admin/teacher/student) |
| profile | 8003 | 9003 | Extended user info, avatar |
| question-bank | 8004 | 9004 | CRUD questions, search, bulk import |
| exam | 8005 | 9005 | Create/publish exams, Redis cache |
| submission | 8006 | 9006 | Submit answers, auto-grading, RabbitMQ |
| result | 8007 | 9007 | Scores, reports, class performance |
| notification | 8008 | — | RabbitMQ consumer, alerts |

## Frontend MFEs

| App | Port | Routes | Owns |
|---|---|---|---|
| shell-app | 3000 | / | Layout, nav, theme, auth state |
| mfe-auth | 3001 | /login /register /onboarding | Auth flows |
| mfe-dashboard | 3002 | /dashboard | Stats, Bò hero, activity |
| mfe-exam | 3003 | /exams/* /result | Exam lifecycle |
| mfe-question | 3004 | /question-bank | CRUD questions |
| mfe-reports | 3005 | /reports /achievements | Analytics, streak |

---

## Mascot — Bò 🐃

**Bò** là trâu nước Việt Nam, đội nón lá, phong cách anime 2D cel-shaded.

| Màu | Hex | Vị trí |
|---|---|---|
| Body fur | `#6B4F3A` | Thân |
| Face | `#83604B` | Mặt |
| Belly | `#C9BDB0` | Bụng |
| Eye iris | `#6A4224` + `#D4A44C` | Mắt |
| Nón lá | `#F5E6C8` | Nón |
| Jacket | `#1B2F4E` | Áo formal |
| Cuffs | `#0D9B8A` | Tay áo |

Xem `mascots/04-mascot.md` để có đầy đủ prompts cho tất cả poses.

---

## Design System

- **Font:** Be Vietnam Pro (UI/Body) + JetBrains Mono (code/data)
- **Primary:** `#0EA5E9` sky-teal · **Secondary:** `#F59E0B` amber
- **Dark mode:** ✅ Class strategy, CSS custom properties
- **No purple/violet anywhere**

Xem `design/design-system.md` để có đầy đủ color tokens, typography, spacing, component specs.

---

## Budget estimate

| Phase | Nội dung | Est. cost |
|---|---|---|
| 1–3 | Backend microservices | ~$12 |
| 4–5 | Infra + k6 | ~$5 |
| 6–9 | Frontend MFEs | ~$15 |
| 10–11 | Polish + Deploy | ~$5 |
| **Tổng** | | **~$37** |

---

*Inspired by [prompt-to-production](https://github.com/Danchuong/prompt-to-production) methodology.*

## License

MIT
