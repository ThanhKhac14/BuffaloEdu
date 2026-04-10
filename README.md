# 🐃 BuffaloEdu

> **Nền tảng thi trực tuyến thế hệ mới — xây dựng bằng AI, tối ưu cho người Việt.**

Mascot: **Bò** — Trâu Việt Nam đội nón lá, phong cách anime 2D.  
Tagline: *"Cày thôi!"*

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
| **Backend** | Go 1.22+ · gRPC + Protobuf · PostgreSQL · Redis · RabbitMQ |
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
