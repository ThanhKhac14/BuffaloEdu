# Learnify — Frontend Prompt (GitHub Copilot · Microfrontend)
> Dùng trong GitHub Copilot Agent mode (@workspace).
> Chạy sau khi đã có stitch-export/ từ file 02-design.md.

---

```
# FRONTEND SCAFFOLD — Learnify Microfrontend (Module Federation)

## Role
You are a senior frontend architect specializing in Next.js and Microfrontend architecture.
Scaffold the complete Learnify frontend using Module Federation (Webpack 5).
Follow every constraint exactly. Do NOT invent design tokens — import from stitch-export/.

---

## Architecture Decision: Module Federation (Webpack 5)
Chosen because:
- Native Next.js support via @module-federation/nextjs-mf
- Each MFE deploys independently without rebuilding others
- Shared dependencies (React, design tokens) loaded once
- No framework lock-in for future MFEs
- Works with existing Docker + GitHub Actions setup

---

## Repository Structure
```
frontend/
├── shell-app/              # Host — layout, routing, auth state
├── mfe-auth/               # Remote — login, register, onboarding
├── mfe-dashboard/          # Remote — home, stats, Bo banner
├── mfe-exam/               # Remote — create, take, result
├── mfe-question/           # Remote — question bank management
├── mfe-reports/            # Remote — analytics, achievements, streak
├── shared/
│   ├── ui/                 # Shared component library (from stitch-export)
│   ├── hooks/              # useTheme, useAuth, useToast
│   ├── types/              # Shared TypeScript types
│   ├── utils/              # formatDate, formatScore, etc.
│   └── api/                # Typed API client (fetch wrapper)
└── stitch-export/
    ├── tokens.css
    ├── tokens.json
    └── components/         # Generated .tsx components from Stitch
```

---

## Tech Stack
- Framework:    Next.js 14+ (App Router, TypeScript)
- MFE:          @module-federation/nextjs-mf
- Styling:      Tailwind CSS (extends tokens.json)
- State:        Zustand (lightweight, no Redux)
- Data fetch:   TanStack Query (React Query v5)
- Forms:        React Hook Form + Zod validation
- Charts:       Recharts
- Animation:    Framer Motion (Bo, page transitions)
- Icons:        Lucide React
- Dark mode:    Tailwind class strategy

---

## Shell App — Host Configuration

### next.config.ts (shell-app)
```typescript
const { NextFederationPlugin } = require('@module-federation/nextjs-mf')

module.exports = {
  webpack(config) {
    config.plugins.push(
      new NextFederationPlugin({
        name: 'shell',
        remotes: {
          mfe_auth:      `mfe_auth@${process.env.MFE_AUTH_URL}/_next/static/chunks/remoteEntry.js`,
          mfe_dashboard: `mfe_dashboard@${process.env.MFE_DASHBOARD_URL}/_next/static/chunks/remoteEntry.js`,
          mfe_exam:      `mfe_exam@${process.env.MFE_EXAM_URL}/_next/static/chunks/remoteEntry.js`,
          mfe_question:  `mfe_question@${process.env.MFE_QUESTION_URL}/_next/static/chunks/remoteEntry.js`,
          mfe_reports:   `mfe_reports@${process.env.MFE_REPORTS_URL}/_next/static/chunks/remoteEntry.js`,
        },
        shared: {
          react: { singleton: true, requiredVersion: false },
          'react-dom': { singleton: true, requiredVersion: false },
          zustand: { singleton: true },
        },
      })
    )
    return config
  },
}
```

### Shell app responsibilities
- Global layout: TopNav + Sidebar + main content slot
- Route definitions → lazy-load remote MFE pages
- Auth state (Zustand store shared via Module Federation)
- Dark mode toggle + persist to localStorage
- Global toast notifications
- Error boundaries per MFE

### Shell routing
```
/                    → redirect to /dashboard
/login               → mfe-auth/LoginPage
/register            → mfe-auth/RegisterPage
/onboarding          → mfe-auth/OnboardingPage
/dashboard           → mfe-dashboard/DashboardPage
/question-bank       → mfe-question/QuestionBankPage
/exams/create        → mfe-exam/CreateExamPage
/exams/[id]/take     → mfe-exam/TakeExamPage
/exams/[id]/result   → mfe-exam/ResultPage
/reports             → mfe-reports/ReportsPage
/achievements        → mfe-reports/AchievementsPage
```

---

## Each Remote MFE — Template Structure
Apply to: mfe-auth, mfe-dashboard, mfe-exam, mfe-question, mfe-reports

```
mfe-{name}/
├── src/
│   ├── app/               # Next.js App Router pages
│   ├── components/        # MFE-specific components
│   ├── hooks/             # MFE-specific hooks
│   ├── store/             # Zustand slices (local state)
│   └── api/               # API calls for this domain
├── next.config.ts         # Federation plugin as REMOTE
├── tailwind.config.ts     # Extends shared tokens
├── tsconfig.json          # Extends root tsconfig
├── Dockerfile
└── .env.example
```

### next.config.ts (each remote)
```typescript
new NextFederationPlugin({
  name: 'mfe_{name}',
  filename: 'static/chunks/remoteEntry.js',
  exposes: {
    './{PageName}Page': './src/app/{route}/page.tsx',
    // expose all pages this MFE owns
  },
  shared: { react: { singleton: true }, 'react-dom': { singleton: true } }
})
```

---

## Design System Integration — MANDATORY

### Setup steps (run once per MFE)
```bash
# Copy from stitch-export into shared/ui
cp stitch-export/tokens.css  shared/ui/tokens.css
cp stitch-export/tokens.json shared/ui/tokens.json
cp stitch-export/components/ shared/ui/components/ -r
```

### tailwind.config.ts (every app extends this)
```typescript
import tokens from '../../shared/ui/tokens.json'
export default {
  darkMode: 'class',
  content: ['./src/**/*.{ts,tsx}', '../../shared/ui/**/*.tsx'],
  theme: {
    extend: {
      colors: tokens.colors,
      spacing: tokens.spacing,
      borderRadius: tokens.radius,
      boxShadow: tokens.shadow,
      fontFamily: {
        sans: ['Plus Jakarta Sans', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
}
```

### globals.css (every app)
```css
@import '../../shared/ui/tokens.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
```

---

## Shared State (Zustand via Module Federation)

### Auth store (shared/store/auth.ts)
```typescript
interface AuthState {
  user: User | null
  accessToken: string | null
  isAuthenticated: boolean
  login: (token: string, user: User) => void
  logout: () => void
}
```

### Theme store (shared/store/theme.ts)
```typescript
interface ThemeState {
  theme: 'light' | 'dark'
  toggleTheme: () => void
}
// Persist to localStorage. Apply 'dark' class to <html> on mount.
// Respect prefers-color-scheme on first visit.
```

---

## API Client (shared/api/client.ts)
```typescript
// Typed fetch wrapper
// Base URL from env: NEXT_PUBLIC_API_URL
// Auto-attach Authorization header from auth store
// Refresh token on 401
// Throw typed errors
// All methods: get<T>, post<T>, put<T>, delete<T>
```

### Domain API modules (one per MFE)
```
shared/api/
├── client.ts       # Base client
├── auth.ts         # login, register, refresh, logout
├── user.ts         # CRUD users
├── question.ts     # CRUD questions, search, bulk
├── exam.ts         # CRUD exams, publish, randomize
├── submission.ts   # start, submit, finalize
├── result.ts       # get results, reports
└── types.ts        # Shared API types (DTOs)
```

---

## Pages Implementation Guide

### mfe-auth pages
- LoginPage: email + password, show/hide password toggle, "Remember me", forgot password link
- RegisterPage: name, email, password + confirm, role selector
- OnboardingPage: 3-step wizard with Bo hero (Framer Motion page transitions)

### mfe-dashboard pages
- DashboardPage:
  - Bo hero banner (teal-navy gradient, Framer Motion entrance)
  - StatCards: TanStack Query fetches /users/count, /exams/active, /results/pending
  - DailyStreak: amber card, Bo streak-fire (Framer Motion idle loop)
  - RecentActivity: paginated feed
  - QuickActions: Launch Assessment → navigate to /exams

### mfe-exam pages
- CreateExamPage: React Hook Form + Zod, 5-step stepper
- TakeExamPage:
  - Question panel: current question + A/B/C/D radio options
  - Navigator sidebar: grid of question numbers (answered/unanswered/flagged)
  - TimerWidget: countdown, useInterval hook, Bo micro at 5min/1min
  - Auto-save answers to localStorage every 30s
  - Submit: confirmation modal, POST /submissions/finalize
- ResultPage:
  - Score count-up animation (Framer Motion, 1200ms)
  - Bo hero (pose/message based on score %)
  - Per-question accordion: correct/wrong/skipped
  - Share result button

### mfe-question pages
- QuestionBankPage:
  - FilterSidebar: subject, difficulty (1-5), type, tags (multi-select)
  - DataTable: sortable columns, bulk select, inline edit
  - Right drawer (Framer Motion slide): CreateQuestionForm
  - BulkImport: CSV upload with preview

### mfe-reports pages
- ReportsPage:
  - Filters: class, exam, date range (react-hook-form)
  - StatCards: avg score, pass rate, completion rate
  - BarChart (Recharts): score distribution
  - DataTable: per-student performance, export CSV
  - Bo empty state (thinking pose) if no data
- AchievementsPage:
  - StreakCard: Bo streak-fire, amber background
  - XPProgressBar: spring animation on fill (Framer Motion)
  - BadgeGrid: earned (full color) / locked (grayscale + lock icon)
  - MilestoneTimeline: 7 / 30 / 100 day markers

---

## Bo Integration (Framer Motion)

### BoCharacter component (shared/ui/BoCharacter.tsx)
```typescript
interface BoProps {
  pose: 'happy' | 'celebrating' | 'thinking' | 'sad' |
        'encouraging' | 'proud' | 'streak-fire' | 'perfect-score' |
        'sleeping' | 'surprised' | 'error'
  size: 'hero' | 'medium' | 'small' | 'micro'
  message?: string
  animate?: boolean  // enable idle breathing animation
}
```
- Load PNG from /public/mascot/Bo-{pose}-{size}.png
- Framer Motion: idle breathing (scale 1→1.02→1, 3s loop)
- Message: speech bubble, Plus Jakarta Sans, positioned top-left
- animate={false} respects prefers-reduced-motion

---

## Docker Setup (one per MFE)

### Dockerfile (each MFE)
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
```

### Ports
```
shell-app:    3000
mfe-auth:     3001
mfe-dashboard:3002
mfe-exam:     3003
mfe-question: 3004
mfe-reports:  3005
```

---

## Constraints — NEVER violate
- NEVER hardcode hex colors — Tailwind tokens only
- NEVER use inline style={{}} for colors or spacing
- ALWAYS use dark: prefix for dark mode
- NEVER share database or API state directly — use shared Zustand stores
- ALWAYS lazy-load remote MFE pages (React.lazy + Suspense with skeleton fallback)
- ALWAYS add Error Boundary wrapper around each remote MFE in shell
- MUST handle loading state within 150ms — show skeleton, not blank screen
- MUST auto-save exam progress to localStorage every 30 seconds
- MUST be responsive — test layout at 375px, 768px, 1024px, 1440px
- MUST respect prefers-reduced-motion for all Framer Motion animations

---

## Execution Order — confirm after each phase

Phase 1: Scaffold folder structure + shared/ directory + root package.json
Phase 2: Shell app — layout, routing, Zustand stores, API client
Phase 3: Design system integration — tokens, tailwind configs, shared UI import
Phase 4: mfe-auth — login, register, onboarding pages
Phase 5: mfe-dashboard — dashboard page + stat cards + Bo banner
Phase 6: mfe-exam — create, take, result pages
Phase 7: mfe-question — question bank page
Phase 8: mfe-reports — reports + achievements pages
Phase 9: Dockerfiles + docker-compose frontend section
Phase 10: BoCharacter component + all Framer Motion animations

Begin Phase 1. List all files to be created, then generate. Confirm before Phase 2.
```
