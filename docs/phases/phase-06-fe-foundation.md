# Phase 6 — Frontend Foundation + Shell App

> Refs: `docs/shared/frontend-conventions.md` · `docs/shared/design-system.md` · `docs/shared/mascot.md`

## Mục tiêu

Build shared UI library, BoCharacter component, Zustand stores, API client, và shell-app host.

---

## 6.1 — Shared UI Library (frontend/shared/ui/)

### tokens.css
CSS custom properties cho light + dark mode. Source: `docs/shared/design-system.md`.
```css
:root {
  --background: #ffffff;
  --foreground: #0f172a;
  /* ... all tokens from design-system.md */
}
[data-theme="dark"] {
  --background: #0f172a;
  /* ... */
}
```

### tailwind.config.ts (extend tokens)
```typescript
import tokens from './tokens.json'
export default {
  darkMode: 'class',
  content: ['./src/**/*.{ts,tsx}', '../**/*.tsx'],
  theme: {
    extend: {
      colors: tokens.colors,
      fontFamily: {
        sans: ['Be Vietnam Pro', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
}
```

### Components cần tạo
- `button.tsx` — 5 variants, 3 sizes, loading state
- `card.tsx` — CardHeader, CardContent, CardTitle, CardDescription
- `badge.tsx` — 6 variants
- `input.tsx` — với label + error message
- `skeleton.tsx` — shimmer animation
- `theme-toggle.tsx` — wired to theme store

---

## 6.2 — Shared Utilities (frontend/shared/)

### store/auth.ts
```typescript
interface AuthState {
  user: User | null
  accessToken: string | null
  isAuthenticated: boolean
  login: (token: string, user: User) => void
  logout: () => void
}
// Zustand store — singleton via Module Federation
```

### store/theme.ts
```typescript
// Toggle + persist localStorage + respect prefers-color-scheme on first visit
// Adds/removes .dark class on <html>
```

### api/client.ts
```typescript
// Typed fetch wrapper:
// - Base URL từ NEXT_PUBLIC_API_URL
// - Auto-attach Authorization: Bearer {token}
// - Auto-refresh on 401
// - Typed errors

export const client = {
  get:    <T>(path: string): Promise<T>,
  post:   <T>(path: string, body: unknown): Promise<T>,
  put:    <T>(path: string, body: unknown): Promise<T>,
  delete: <T>(path: string): Promise<T>,
}
```

### hooks/
- `useCountUp.ts` — animate number 0→final over duration
- `useTimer.ts` — countdown với warning/critical states
- `useInView.ts` — Intersection Observer trigger

---

## 6.3 — BoCharacter.tsx

```typescript
// frontend/shared/ui/BoCharacter.tsx
// Load PNG từ /public/mascot/bo-{pose}-{size}.png
// Hat là SEPARATE Framer Motion layer
// Idle breathing: scale 1→1.02→1, 3s loop
// Speech bubble: Be Vietnam Pro, rounded-2xl, bg-surface-1, shadow-lg

// Hat animations (xem docs/shared/mascot.md):
// idle: rotateZ ±3deg, 4s loop
// celebrating: y -60px + spin 360deg spring
// surprised: rotateZ 35deg spring
// sleeping: y +20px covering eyes

// BẮTBUỘC: disable tất cả animation khi prefers-reduced-motion
```

---

## 6.4 — Shell App (frontend/shell-app/)

### Module Federation Host
```typescript
// next.config.ts
new NextFederationPlugin({
  name: 'shell',
  remotes: {
    mfe_auth:      `mfe_auth@${process.env.MFE_AUTH_URL}/static/chunks/remoteEntry.js`,
    mfe_dashboard: `mfe_dashboard@${process.env.MFE_DASHBOARD_URL}/static/chunks/remoteEntry.js`,
    mfe_exam:      `mfe_exam@${process.env.MFE_EXAM_URL}/static/chunks/remoteEntry.js`,
    mfe_question:  `mfe_question@${process.env.MFE_QUESTION_URL}/static/chunks/remoteEntry.js`,
    mfe_reports:   `mfe_reports@${process.env.MFE_REPORTS_URL}/static/chunks/remoteEntry.js`,
  },
  shared: { react: { singleton: true }, 'react-dom': { singleton: true }, zustand: { singleton: true } },
})
```

### Layout
- `TopNav`: logo + nav links + user avatar + dark mode toggle
- `Sidebar`: collapsible 240→64px, icon-only on tablet, drawer on mobile
  - Nav item active: `bg-primary-subtle text-primary font-medium`
- Main content slot

### Routes (tất cả dùng `React.lazy` + `Suspense` + skeleton fallback)

```typescript
const LoginPage     = React.lazy(() => import('mfe_auth/LoginPage'))
const DashboardPage = React.lazy(() => import('mfe_dashboard/DashboardPage'))
// ...
```

### Error Boundaries
Wrap mỗi remote MFE trong Error Boundary riêng.

### Toast System
- Slide-in bottom-right
- Auto-dismiss 4s
- Max 3 stacked
- Variants: success · error · warning · info

## Quality Gate

```bash
cd frontend/shell-app && next build  # 0 errors, 0 warnings
# Verify: theme toggle works + persists
# Verify: BoCharacter renders với breathing animation
```
