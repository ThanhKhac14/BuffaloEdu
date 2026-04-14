# BuffaloEdu — Frontend Prompt (GitHub Copilot)
> Dùng trong GitHub Copilot Agent mode (@workspace).
> Chạy sau khi backend (01-backend.md) đã scaffold xong.

---

```
# FRONTEND SCAFFOLD — BuffaloEdu Next.js App Router + Supabase Auth

## Role
You are a senior frontend engineer specializing in Next.js App Router.
Scaffold the complete BuffaloEdu frontend as a single Next.js application.
Follow every constraint exactly. Do NOT add features beyond what is specified.
Do NOT hardcode hex values. Do NOT use inline style={{}} for colors/spacing.

---

## Tech Stack
- Framework:    Next.js 14+ (App Router, TypeScript strict)
- Auth:         @supabase/supabase-js (Supabase Auth — browser + server)
- Styling:      Tailwind CSS v4 (extends design tokens)
- State:        Zustand (auth store, theme store)
- Data fetch:   TanStack Query v5
- Forms:        React Hook Form + Zod
- Charts:       Recharts
- Animation:    Framer Motion (BoCharacter + page transitions only)
- Icons:        Lucide React
- Dark mode:    Tailwind class strategy

---

## Repository Structure (generate exactly this)
```
frontend/
├── app/
│   ├── layout.tsx              # Root: Providers (Supabase, Query, theme)
│   ├── globals.css             # @import tokens.css + tailwind directives
│   ├── middleware.ts           # Refresh session + protect routes
│   ├── (auth)/                 # Public routes — no sidebar
│   │   ├── layout.tsx
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── onboarding/page.tsx
│   └── (app)/                  # Protected routes — with nav/sidebar
│       ├── layout.tsx          # TopNav + Sidebar + content slot
│       ├── dashboard/page.tsx
│       ├── exams/
│       │   ├── page.tsx        # Exam list
│       │   ├── create/page.tsx
│       │   └── [id]/
│       │       ├── page.tsx    # Exam detail
│       │       └── take/page.tsx
│       ├── question-bank/page.tsx
│       ├── reports/page.tsx
│       ├── achievements/page.tsx
│       └── result/[id]/page.tsx
├── components/
│   ├── ui/                     # Design system components
│   │   ├── Button.tsx          # 5 variants: primary, secondary, outline, ghost, danger
│   │   ├── Card.tsx            # Card + CardHeader + CardContent + CardFooter
│   │   ├── Input.tsx           # with label, error, icon slot
│   │   ├── Badge.tsx           # 6 variants: default, success, warning, error, info, neutral
│   │   ├── Skeleton.tsx        # matches exact shape of real content
│   │   └── ThemeToggle.tsx     # sun/moon icon, persists theme
│   ├── layout/
│   │   ├── TopNav.tsx
│   │   └── Sidebar.tsx         # collapsible, icon-only on collapse
│   └── BoCharacter.tsx         # Bò mascot — Framer Motion
├── lib/
│   ├── supabase/
│   │   ├── client.ts           # createBrowserClient()
│   │   └── server.ts           # createServerClient() for Server Components
│   ├── api/
│   │   ├── client.ts           # typed fetch → Go API (NEXT_PUBLIC_API_URL)
│   │   ├── question.ts
│   │   ├── exam.ts
│   │   ├── submission.ts
│   │   └── result.ts
│   └── utils/
│       ├── cn.ts               # classname merger (clsx + tailwind-merge)
│       └── formatters.ts       # formatScore, formatDate, formatDuration
├── store/
│   ├── auth.ts                 # Zustand: user, session, login, logout
│   └── theme.ts                # Zustand: theme, toggleTheme, persist localStorage
├── hooks/
│   ├── useCountUp.ts           # animates number from 0 to target
│   └── useInView.ts            # IntersectionObserver for scroll animations
├── types/
│   └── index.ts                # All TypeScript interfaces (User, Exam, Question, etc.)
├── public/
│   └── mascot/                 # Bo-{pose}-{size}.png files
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── .env.local.example
```

---

## Supabase Auth Integration

### lib/supabase/client.ts
```typescript
import { createBrowserClient } from '@supabase/ssr'
export const createClient = () =>
  createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
```

### middleware.ts
- Use `createMiddlewareClient` to refresh session on every request
- Redirect unauthenticated users to /login (protect all /app routes)
- Redirect authenticated users away from /login, /register

### After auth (login/register)
- Call `POST /api/auth/sync` with Bearer token → creates profile on Go backend
- Store user + session in Zustand auth store

---

## Design System Integration

### tailwind.config.ts
```typescript
import tokens from '../design/design-system/tokens.json'
export default {
  darkMode: 'class',
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: tokens.colors,
      spacing: tokens.spacing,
      borderRadius: tokens.radius,
      boxShadow: tokens.shadow,
      fontFamily: {
        sans: ['Be Vietnam Pro', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
}
```

### globals.css
```css
@import '../design/design-system/tokens.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
```

---

## Pages Implementation

### Auth pages
**LoginPage**: email + password, show/hide toggle, React Hook Form + Zod, `supabase.auth.signInWithPassword`, inline error (not redirect), loading button state.

**RegisterPage**: name + email + password + confirm + role selector (Teacher/Student), `supabase.auth.signUp`.

**OnboardingPage**: 3 steps — Welcome (Bò waving) → role confirm → display name. Framer Motion transitions between steps.

### Dashboard
- Bò hero banner: teal-navy gradient, Bò happy pose, animated entrance (300ms ease-out)
- Stat cards: My Exams · My Results · Avg Score · Streak — useCountUp + Skeleton 800ms
- Bar chart (Recharts): score distribution, grow animation on mount
- Quick Actions: 4 cards → /exams/create, /question-bank, /reports, /achievements

### Question Bank (`/question-bank`)
- Filter sidebar: subject, difficulty stars, type, tags
- DataTable: sortable + paginated + bulk select
- "+ Add" button → right drawer (Framer Motion `x: 400 → 0`)
- CreateQuestionForm in drawer: type selector, content, options A-D, correct answer, difficulty 1-5 stars, subject, tags
- Bò empty state (thinking pose) when no questions

### Create Exam (5-step stepper `/exams/create`)
- Step 1: title, subject, duration, max attempts, description
- Step 2: select questions (DataTable + filter + multi-select)
- Step 3: settings (show result, randomize, access code)
- Step 4: preview (read-only student view)
- Step 5: confirm + publish — POST /api/exams + /api/exams/:id/publish
- Stepper: animated line indicator

### Take Exam (`/exams/[id]/take`)
- Left panel: QuestionCard (text + options A/B/C/D, flag button, prev/next)
- Right sidebar (w-64, hidden mobile): navigator grid — unanswered/answered/flagged/current colors
- Timer: countdown from duration_minutes. amber pulse <5min, red flash <1min, Bò micro at 5min warning
- Auto-save to localStorage every 30s (`exam_progress_{submission_id}`)
- Submit modal: summary → confirm → POST /api/submissions/:id/finalize

### Result (`/result/[id]`)
- Score ring: SVG animated dashoffset 1200ms
- Bò hero pose by score: <50% sad, 50-80% encouraging, >80% celebrating
- Score count-up + pass/fail badge
- Per-question accordion: ✓ / ✗ / skipped + correct answer shown

### Reports (`/reports`)
- Stat cards: avg score, pass rate, completion rate, total submissions
- Area chart (Recharts): score trends
- DataTable: per-student (teacher sees class, student sees own)
- Export CSV stub → toast

### Achievements (`/achievements`)
- StreakCard: Bò streak-fire, amber background, flame animation
- XP bar: spring animation on mount
- Badge grid: earned (full color) / locked (grayscale)

---

## BoCharacter Component (components/BoCharacter.tsx)
```typescript
interface BoProps {
  pose: 'happy' | 'celebrating' | 'thinking' | 'sad' | 'encouraging' |
        'waving' | 'streak-fire' | 'perfect-score' | 'sleeping' | 'micro'
  size: 'hero' | 'medium' | 'small' | 'micro'
  message?: string
  animate?: boolean
}
```
- Load PNG: `/public/mascot/bo-{pose}-{size}.png`
- Framer Motion idle: `scale: [1, 1.02, 1]`, 3s loop
- Speech bubble: Be Vietnam Pro, `rounded-xl`, white/surface-1 bg, `shadow-lg`
- `animate={false}` + `prefers-reduced-motion` support

---

## Constraints
- NEVER hardcode hex colors — Tailwind token classes only
- NEVER use `style={{}}` for colors or spacing
- ALWAYS use `dark:` prefix for dark mode
- MUST handle loading state within 150ms — show Skeleton
- MUST auto-save exam progress to localStorage every 30s
- MUST be responsive: 375px, 768px, 1024px+
- MUST respect `prefers-reduced-motion` for animations
- NEVER use `any` — strict TypeScript throughout

---

## .env.local.example
```
NEXT_PUBLIC_SUPABASE_URL=https://[ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
NEXT_PUBLIC_API_URL=http://localhost:8000
```

---

## Execution Order — confirm after each phase

Phase 1: Scaffold folder structure + tailwind config + globals.css + Supabase clients
Phase 2: Shared UI components (Button, Card, Input, Badge, Skeleton, ThemeToggle)
Phase 3: Zustand stores + API client + types
Phase 4: Auth layout + login + register + onboarding pages
Phase 5: App layout (TopNav + Sidebar) + Dashboard page + BoCharacter component
Phase 6: Question Bank page + drawer + form
Phase 7: Create Exam (stepper) + Take Exam + Result pages
Phase 8: Reports + Achievements pages
Phase 9: Responsive + dark mode audit + animations

Begin Phase 1. List all files to create, then generate. Confirm before Phase 2.
```

