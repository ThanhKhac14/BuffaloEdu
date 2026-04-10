# BuffaloEdu — Claude Code Workspace

> Đọc file này trước mọi thứ. Đây là project context duy nhất cần thiết.

## Project
- **App:** BuffaloEdu — Online Examination SaaS
- **Mascot:** Bò (Vietnamese water buffalo, nón lá, anime 2D)
- **Tagline:** *"Cày thôi!"*
- **Font:** Be Vietnam Pro + JetBrains Mono

## Stack
- **Backend:** Go 1.22+ · gRPC + Protobuf (buf CLI) · PostgreSQL (pgx/v5) · Redis · RabbitMQ
- **Frontend:** Next.js 14 · TypeScript · Module Federation · Tailwind CSS v4
- **Infra:** Traefik v3 · Docker Compose · GitHub Actions · Prometheus + Grafana · k6

## Context files (read when relevant)
- `overview/agents.md` — AI agent roles & responsibilities
- `overview/rules.md` — Non-negotiable project rules
- `overview/tasks.md` — 11-phase task plan
- `overview/prompts.md` — Phase-by-phase prompts
- `design/design-system.md` — Colors, typography, components (Be Vietnam Pro, #0EA5E9 primary)
- `mascots/04-mascot.md` — Bò character specs & Firefly prompts

## Critical rules (never violate)
- No ORM — raw SQL with pgx/v5 only
- No shared PostgreSQL databases between services
- No hardcoded hex in components — CSS token classes only
- No `any` type in TypeScript or Go
- Every Go service: handler → service → repository layers (strict separation)
- Every new service needs: Prometheus metrics interceptor + healthz RPC
- `buf generate` before any gRPC work
- `next build` must pass 0 errors after every frontend phase
- `go build ./...` must pass 0 errors after every backend phase

## Repo structure
```
BuffaloEdu/
├── CLAUDE.md              ← This file
├── overview/              ← agents, rules, tasks, prompts
├── design/                ← design-system.md, 02-design.md
├── mascots/               ← 04-mascot.md + PNG assets
├── .claude/
│   ├── commands/          ← Slash commands
│   ├── skills/            ← Auto-activated skills
│   └── agents/            ← Subagent definitions
├── 00-overview.md         ← Architecture map
├── 01-backend.md          ← Backend Copilot prompt
├── 03-frontend.md         ← Frontend MFE prompt
├── 05-cicd.md             ← CI/CD prompt
└── 06-loadbalancer.md     ← Traefik prompt
```

## Services (ports)
| Service | REST | gRPC |
|---|---|---|
| gateway | 8000 | — |
| auth | 8001 | 9001 |
| user | 8002 | 9002 |
| profile | 8003 | 9003 |
| question-bank | 8004 | 9004 |
| exam | 8005 | 9005 |
| submission | 8006 | 9006 |
| result | 8007 | 9007 |
| notification | 8008 | — |

## Frontend MFEs (ports)
| App | Port |
|---|---|
| shell-app | 3000 |
| mfe-auth | 3001 |
| mfe-dashboard | 3002 |
| mfe-exam | 3003 |
| mfe-question | 3004 |
| mfe-reports | 3005 |

## Context management
- 0–70%: work freely
- 70–80%: run `/compact`
- 80–90%: run `/compact`
- 90%+: run `/clear` (re-read CLAUDE.md after)
