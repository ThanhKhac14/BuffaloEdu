# Project Rules — BuffaloEdu

These rules are NON-NEGOTIABLE. Follow them in every line of code, every config file, every workflow.

---

## Tech Stack (locked — do not change)

### Backend
| Layer | Technology | Version |
|---|---|---|
| Language | Golang | 1.24+ |
| Transport (internal) | gRPC + Protobuf | latest |
| Proto tooling | buf CLI | latest |
| Database | PostgreSQL (pgx/v5) | 16+ |
| Cache | Redis | 7+ |
| Queue | RabbitMQ | 3+ |
| Monitoring | Prometheus + Grafana | latest |
| Perf testing | k6 | latest |
| Container | Docker + Docker Compose | latest |

### Frontend
| Layer | Technology | Version |
|---|---|---|
| Framework | Next.js App Router | 14+ |
| Language | TypeScript (strict) | 5+ |
| MFE | @module-federation/nextjs-mf | latest |
| Styling | Tailwind CSS v4 | latest |
| Fonts | Plus Jakarta Sans + JetBrains Mono | via next/font |
| Icons | Lucide React | latest |
| State | Zustand | latest |
| Data fetching | TanStack Query v5 | latest |
| Forms | React Hook Form + Zod | latest |
| Charts | Recharts | latest |
| Animation | Framer Motion (Bò only + page transitions) | latest |
| Load balancer | Traefik v3 | latest |
| CI/CD | GitHub Actions | — |

### Allowed frontend dependencies (ONLY these per MFE)
```json
{
  "next": "latest",
  "react": "latest",
  "react-dom": "latest",
  "@module-federation/nextjs-mf": "latest",
  "lucide-react": "latest",
  "zustand": "latest",
  "@tanstack/react-query": "latest",
  "react-hook-form": "latest",
  "zod": "latest",
  "recharts": "latest",
  "framer-motion": "latest"
}
```

### Forbidden
- No ORM (no GORM, Ent, etc.) — raw SQL with pgx/v5 only
- No shared PostgreSQL databases between services
- No Redux, MobX, or other state managers — Zustand only
- No UI component libraries (shadcn, MUI, Chakra) — build from design system
- No Axios — use native fetch with typed wrapper
- No `any` type anywhere — strict TypeScript
- No `@ts-ignore` — fix the type error instead
- No Framer Motion outside of BoCharacter, page transitions, and hat animations
- No hardcoded hex values in components — CSS token classes only

---

## Go Service Template (apply to EVERY service)

```
services/{name}/
├── cmd/main.go              # Entry: load config → connect deps → start gRPC server
├── internal/
│   ├── handler/             # gRPC method implementations — thin, call service only
│   ├── service/             # Business logic — no DB access here
│   ├── repository/          # ALL DB + Redis queries — pgx/v5, raw SQL
│   ├── middleware/          # gRPC interceptors: auth, logging, metrics, recovery
│   └── model/               # Domain structs (NOT proto-generated types)
├── config/config.go         # Env loading via viper → typed Config struct
├── gen/                     # Generated proto stubs (gitignored, from buf generate)
├── migrations/              # SQL files: 001_init.up.sql, 001_init.down.sql
├── Dockerfile
├── .env.example
└── README.md
```

Layer rules:
- `handler` calls `service` only — never touches repository or DB directly
- `service` calls `repository` only — no SQL in service
- `repository` is the only layer that touches PostgreSQL or Redis

---

## Design Rules

### Colors
- Only use tokens from `design-system.md`
- Never use raw hex values in components — always CSS variable classes
  - YES: `text-foreground`, `bg-primary`, `border-border`
  - NO: `text-[#0a0a0a]`, `bg-[#0EA5E9]`
- Exception: gradient definitions in globals.css

### Spacing
Strict 4px base. Only these Tailwind values:
`1(4px) · 2(8px) · 3(12px) · 4(16px) · 5(20px) · 6(24px) · 8(32px) · 10(40px) · 12(48px) · 16(64px) · 20(80px)`

- Section padding: `py-24 px-6`
- Card padding: `p-6`
- Card gaps: `gap-4` (tight) · `gap-6` (normal) · `gap-8` (loose)
- Max content width: `max-w-7xl` (1280px) with `mx-auto`

### Typography
- Only 2 fonts: Plus Jakarta Sans (body/UI) and JetBrains Mono (code/data/IDs)
- Headings: `font-bold tracking-tight`
- Body: `text-sm` or `text-base`, normal weight
- Labels: `text-sm font-medium text-muted-foreground`
- Never use `text-lg` for body text

### Components
- Cards: `rounded-xl border border-border bg-background`
- Buttons: `rounded-lg` with size variants
- Inputs: `rounded-lg border border-border`
- Badges: `rounded-full`
- Modals: `rounded-2xl` with backdrop blur
- Consistent everywhere — no exceptions

### Shadows
- Cards at rest: no shadow (border only)
- Cards on hover: `shadow-md`
- Modals/overlays: `shadow-lg`
- Never use `shadow-2xl`

### Dark mode
- Toggle via `.dark` class on `<html>` — Tailwind class strategy
- Persist to `localStorage`, respect `prefers-color-scheme` on first visit
- Every component MUST work in both light and dark
- Test both modes after every frontend phase

### Responsive
- Mobile-first: default styles for mobile, override with `sm:` `md:` `lg:`
- Breakpoints: 375px · 768px · 1024px · 1280px
- No horizontal scroll at any breakpoint (except data tables)
- Touch targets minimum 44×44px

---

## Frontend File Conventions

### Naming
- Files: `kebab-case.tsx` (e.g., `question-card.tsx`, `timer-widget.tsx`)
- Components: `PascalCase` (e.g., `QuestionCard`, `TimerWidget`)
- Hooks: `useCamelCase` (e.g., `useTimer`, `useExamProgress`)
- Types/Interfaces: `PascalCase`
- Utils: `camelCase`

### Component rules
- One component per file
- Props interface in same file or imported from `shared/types/`
- Server components by default — `"use client"` only when required
- Max 150 lines per file — split if larger
- Page files compose components — minimal logic in pages

### Imports order
```tsx
// 1. React/Next
import { useState, useEffect } from "react"
import Link from "next/link"

// 2. External libraries
import { motion } from "framer-motion"
import { BookOpen } from "lucide-react"

// 3. Shared components
import { Button } from "@/shared/ui/button"
import BoCharacter from "@/shared/ui/BoCharacter"

// 4. MFE-local components
import QuestionCard from "@/components/QuestionCard"

// 5. Lib / store / api
import { useAuthStore } from "@/shared/store/auth"
import { cn } from "@/shared/utils"
import type { Question } from "@/shared/types"
```

---

## Animation Rules

### Timing
- Standard transition: `150ms ease-out`
- Entrance animation: `500ms ease-out`
- Stagger delay between items: `50–75ms`
- Max animation sequence: `600ms`
- Bò idle breathing: `3s ease-in-out infinite`
- Score count-up: `1200ms easeOut`

### Types
- `fade-in`: opacity 0→1, translateY 8px→0
- `slide-up`: opacity 0→1, translateY 20px→0
- `scale-in`: opacity 0→1, scale 0.95→1
- `shimmer`: horizontal gradient sweep (skeletons)
- `spring`: cubic-bezier(0.34, 1.56, 0.64, 1) — Bò jumps, badge pop

### Rules
- Never animate layout-triggering properties (`width`, `height`, `top`, `left`)
- Prefer `transform` and `opacity` — GPU-accelerated
- Scroll animations trigger once only
- No animation blocks content visibility (`animation-fill-mode: both`)
- Button active state: `active:scale-[0.98]`
- Respect `prefers-reduced-motion` — disable ALL Framer Motion when set

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Backend Rules

### Go
- Strict typing — no `any`, no `interface{}`
- `context.Context` as first param on every function that calls DB or gRPC
- Every goroutine has context cancellation or WaitGroup cleanup
- Structured logging: `slog` or `zerolog`
- Config loaded via `viper` — never `os.Getenv` scattered in code

### Database
- Raw SQL with pgx/v5 — never ORM
- Named parameters in queries — no positional `$1` scattered in business logic
- Migration files in `migrations/` — never auto-migrate in code
- One PostgreSQL database per service — no cross-service DB access

### gRPC
- All `.proto` files in `/proto/{service}/v1/`
- Shared via `go.mod replace` directive
- `buf generate` from `/proto` root — never manually write stubs
- Every service has `healthz` RPC method
- Every service has Prometheus metrics interceptor

### Ports (reserved — do not change)
```
80 / 443    → Traefik (public)
8080        → Traefik dashboard
8000        → gateway REST
9001–9009   → gRPC internal only
3000        → shell-app
3001        → mfe-auth
3002        → mfe-dashboard
3003        → mfe-exam
3004        → mfe-question
3005        → mfe-reports
9090        → Prometheus (per service metrics)
3100        → Grafana
15672       → RabbitMQ management UI
```

---

## Content Rules (Mock Data)

- All mock text must be realistic Vietnamese/English professional content
- No lorem ipsum — write real content
- Exam names: realistic subject names (Toán 12, Vật lý THPT, Tiếng Anh B1...)
- Student/teacher names: fictional, diverse Vietnamese names
- Scores: realistic (not round numbers — use 8.25/10 not 8/10)
- Dates: April 2026 (current month)

---

## Quality Gates (every phase)

### Backend phases:
1. `go build ./...` — 0 errors
2. `go vet ./...` — 0 warnings
3. `buf generate` — 0 errors
4. `docker-compose build` — all services build

### Frontend phases:
1. `next build` — 0 errors, 0 warnings
2. Verify page renders correctly
3. Check dark mode
4. Check mobile view at 375px
5. Check Module Federation remote loads correctly in shell
