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

**Backend:** Go 1.24+ · Gin router · REST HTTP · Supabase PostgreSQL (pgx/v5 raw SQL) · Supabase Auth (JWT) · Supabase Storage

**Frontend:** Next.js 14+ (App Router, TypeScript strict) · @supabase/supabase-js · Tailwind CSS v4 · Zustand · TanStack Query v5 · React Hook Form + Zod · Framer Motion

**Infra:** Supabase (hosted database + auth + storage) · Docker Compose (1 container) · GitHub Actions

---

## 🚨 Hard Rules (never violate)

### Backend
- **KHÔNG ORM** — `pgx/v5` raw SQL only
- **KHÔNG gRPC** — REST HTTP (Gin router) only
- **KHÔNG microservices** — 1 Go monolith duy nhất
- Layering: `handler → service → repository` (strict separation)
- Sau mỗi thay đổi: `go build ./...` — 0 errors

### Frontend
- **KHÔNG hardcode hex** — CSS token classes only (`text-primary`, `bg-surface-1`)
- **KHÔNG `style={{}}`** cho colors/spacing
- `"use client"` chỉ khi cần hooks/events
- Sau mỗi thay đổi: `next build` — 0 errors, 0 warnings
- Loading state trong **150ms**

### Supabase
- Auth do Supabase quản lý — KHÔNG tự build auth service
- JWT validate bằng `SUPABASE_JWT_SECRET` trong Go middleware
- Sau khi user đăng ký: gọi `POST /api/auth/sync` để tạo profile
- Storage: chỉ lưu URL, không lưu binary trong PostgreSQL

---

## 📁 Repository Structure

```
BuffaloEdu/
├── .github/
│   └── copilot-instructions.md ← THIS FILE
├── overview/
│   ├── rules.md        ← Non-negotiable rules
│   ├── tasks.md        ← 6-phase task plan
│   └── agents.md       ← AI agent roles
├── design/             ← Design system tokens
├── mascots/            ← Bò mascot specs
├── services/
│   └── api/            ← Go monolith (1 service)
│       ├── cmd/main.go
│       ├── internal/
│       │   ├── handler/    ← HTTP handlers
│       │   ├── service/    ← Business logic
│       │   ├── repository/ ← Raw SQL (pgx/v5)
│       │   └── middleware/ ← JWT, CORS, logging
│       └── migrations/     ← SQL files
├── frontend/           ← Next.js App Router
├── docker-compose.yml
└── .env.example
```

---

## 🗺️ API Map (Go Monolith — port 8000)

| Domain | Routes | Chức năng |
|---|---|---|
| Auth | `POST /api/auth/sync` | Sync Supabase user → profiles table |
| User | `GET/PUT /api/users/me` | Profile management |
| Question | `CRUD /api/questions` | Question bank |
| Exam | `CRUD /api/exams` | Exam management + publish |
| Submission | `/api/submissions` | Start/submit/grade |
| Result | `/api/results` | Scores + analytics |

## 🖥️ Frontend Routes (Next.js — port 3000)

| Route | Trang |
|---|---|
| `/login` `/register` `/onboarding` | Auth flows (Supabase Auth) |
| `/dashboard` | Stats, Bò hero |
| `/exams/*` | Create, take, manage exams |
| `/question-bank` | CRUD questions |
| `/reports` `/achievements` | Analytics, streak |
| `/result/[id]` | Kết quả thi |

---

## ⚡ Slash Commands

| Command | Dùng khi |
|---|---|
| `/review` | Code review theo conventions |
| `/bootstrap api` | Scaffold Go monolith structure |
| `/bootstrap page <name>` | Scaffold Next.js page + components |
| `/deploy` | Build + verify |
| `/compact` | Summarize session khi context 70%+ |

---

## 📖 Phase Docs

| Phase | Nội dung |
|---|---|
| 1 | Scaffold Go monolith + Supabase migrations |
| 2 | Auth + User API |
| 3 | Exam + Question + Submission + Result APIs |
| 4 | Frontend: layout + auth + dashboard |
| 5 | Frontend: exam + question bank + results |
| 6 | Polish: dark mode, responsive, animations |

Chi tiết: `overview/tasks.md`
