# HocTrau — Project Overview & Architecture
> Đọc file này trước. Đây là nguồn sự thật duy nhất cho toàn bộ dự án.

---

## Product
| | |
|---|---|
| **App name** | HocTrau |
| **Tagline** | Assess smarter, learn faster |
| **Type** | Online Examination & Learning Assessment Platform |
| **Style** | Modern SaaS, Duolingo-energy, friendly, NO purple/violet |
| **Users** | Teacher · Student · Admin |

---

## Tech Stack

```
┌─────────────────────────────────────────────────────┐
│                    INTERNET                         │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────▼────────┐
              │  Traefik v3     │  ← Load Balancer / Reverse Proxy
              │  (HTTPS, LB)    │    Free · Auto SSL · Docker-native
              └────────┬────────┘
                       │
              ┌────────▼────────┐
              │  API Gateway    │  ← REST → gRPC fan-out (Golang)
              └────────┬────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   ┌────▼────┐   ┌─────▼────┐  ┌─────▼────┐
   │  auth   │   │  user    │  │  exam    │  ... more services
   │ service │   │ service  │  │ service  │
   └────┬────┘   └─────┬────┘  └─────┬────┘
        │              │              │
        └──────────────┼──────────────┘
                       │
            ┌──────────▼──────────┐
            │  RabbitMQ · Redis   │
            │  PostgreSQL (each)  │
            └─────────────────────┘

Frontend (Microfrontend — Module Federation)
┌──────────────────────────────────────────────┐
│  shell-app (Next.js — host)                  │
│  ├── mfe-auth      (login, register)         │
│  ├── mfe-dashboard (home, stats)             │
│  ├── mfe-exam      (create, take, result)    │
│  ├── mfe-question  (bank, management)        │
│  └── mfe-reports   (analytics, streak)      │
└──────────────────────────────────────────────┘

Observability
┌──────────────────────────────────────────────┐
│  Prometheus → Grafana                        │
│  Traefik dashboard (:8080)                   │
│  k6 (performance testing)                   │
└──────────────────────────────────────────────┘

CI/CD: GitHub Actions → Docker build → push → deploy
```

---

## Services Map

| Service | Port | gRPC | Domain | DB |
|---|---|---|---|---|
| gateway | 8000 | — | Infrastructure | — |
| auth | 8001 | 9001 | Security | PostgreSQL auth_db |
| user | 8002 | 9002 | Identity | PostgreSQL user_db |
| profile | 8003 | 9003 | Identity | PostgreSQL profile_db |
| question-bank | 8004 | 9004 | Exam | PostgreSQL question_db |
| exam | 8005 | 9005 | Exam | PostgreSQL exam_db + Redis |
| submission | 8006 | 9006 | Exam | PostgreSQL submission_db |
| result | 8007 | 9007 | Analytics | PostgreSQL result_db |
| notification | 8008 | — | Async | RabbitMQ consumer |

---

## Frontend MFE Map

| App | Route | Owns |
|---|---|---|
| shell-app | / | Layout, nav, theme, auth state |
| mfe-auth | /login · /register · /onboarding | Auth flows |
| mfe-dashboard | /dashboard | Stats, "Bo" - Vietnamese Buffalo hero, activity |
| mfe-exam | /exams/* · /exams/[id]/take · /result | Exam lifecycle |
| mfe-question | /question-bank | CRUD questions |
| mfe-reports | /reports · /achievements | Analytics, streak |

---

## File Index — 7 prompt files

| File | Dùng cho |
|---|---|
| `00-overview.md` | File này — đọc trước |
| `01-backend.md` | GitHub Copilot — scaffold toàn bộ backend microservices |
| `02-design.md` | AI Studio / Stitch — design system + UI mockups |
| `03-frontend.md` | GitHub Copilot — scaffold microfrontend (Module Federation) |
| `04-mascot.md` | Adobe Firefly — generate Bo the Buffalo theo từng pose |
| `05-cicd.md` | GitHub Copilot — GitHub Actions pipelines |
| `06-loadbalancer.md` | GitHub Copilot — Traefik v3 config + SSL + routing |

---

## Shared Conventions

### Naming
```
services/           → Go microservices
frontend/           → MFE shell + remote apps
proto/              → Shared Protobuf
infra/              → Traefik, docker-compose, monitoring
.github/workflows/  → CI/CD pipelines
```

### Environment files
```
.env.example        → root (shared infra vars)
services/{name}/.env.example → per-service vars
frontend/{app}/.env.example  → per-MFE vars
```

### Port convention
```
80 / 443   → Traefik (public)
8080       → Traefik dashboard
8000–8009  → Backend REST (via gateway)
9001–9009  → Backend gRPC (internal only)
3000       → shell-app
3001–3005  → MFE remote apps
```

---

## Quick Start (sau khi scaffold xong)

```bash
# 1. Clone & setup
git clone https://github.com/your-org/HocTrau
cd HocTrau
cp .env.example .env

# 2. Generate Protobuf
cd proto && buf generate

# 3. Start everything
docker-compose up -d

# 4. Access
# App:              https://HocTrau.local
# Traefik dashboard: http://localhost:8080
# Grafana:          http://localhost:3100 (admin/admin)
```
