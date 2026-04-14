# Frontend Conventions — BuffaloEdu

## Naming

| Element | Convention | Example |
|---|---|---|
| Files | `kebab-case.tsx` | `question-card.tsx` |
| Components | `PascalCase` | `QuestionCard` |
| Hooks | `useCamelCase` | `useTimer` |
| Types | `PascalCase` | `ExamResult` |

## Color Tokens (STRICT)

```tsx
// ✅ CSS token classes
<div className="bg-surface-1 text-foreground border-border">
<button className="bg-primary text-primary-foreground hover:bg-primary-hover">
<p className="text-danger">Error</p>

// ❌ NEVER hardcode hex
<div style={{ color: '#0F172A' }}>
<div className="text-[#0EA5E9]">
```

## Server vs Client Components

```tsx
// ✅ Default: Server Component
export default function ExamListPage() {
  return <div className="p-6">...</div>
}

// ✅ Client: chỉ khi cần hooks/events
"use client"
import { useState } from 'react'
export default function TimerWidget({ duration }: { duration: number }) {
  const [remaining, setRemaining] = useState(duration)
}
```

## Import Order

```tsx
// 1. React/Next
import { useState } from 'react'
import Link from 'next/link'

// 2. External
import { motion } from 'framer-motion'
import { BookOpen } from 'lucide-react'

// 3. Shared UI + stores
import { Button } from '@/shared/ui/button'
import BoCharacter from '@/shared/ui/BoCharacter'
import { useAuthStore } from '@/shared/store/auth'

// 4. MFE-local
import QuestionCard from '@/components/question-card'

// 5. Types
import type { Question } from '@/shared/types'
```

## Loading State (within 150ms)

```tsx
<Suspense fallback={<StatCardsSkeleton />}>
  <StatCards />
</Suspense>

// Skeleton matches exact shape of content
function StatCardsSkeleton() {
  return (
    <div className="grid gap-4 sm:grid-cols-4">
      {Array.from({ length: 4 }).map((_, i) => (
        <div key={i} className="rounded-xl border border-border p-6 space-y-3">
          <Skeleton className="h-4 w-24" />
          <Skeleton className="h-8 w-16" />
        </div>
      ))}
    </div>
  )
}
```

## Module Federation Pattern

```typescript
// Remote app — exposes pages
new NextFederationPlugin({
  name: 'mfe_auth',
  filename: 'static/chunks/remoteEntry.js',
  exposes: { './LoginPage': './src/app/login/page.tsx' },
  shared: { react: { singleton: true } },
})

// Shell — loads remotes via Suspense + Error Boundary
const LoginPage = React.lazy(() => import('mfe_auth/LoginPage'))
```

## Quality Gates

```bash
next build                 # 0 errors, 0 warnings
npx tsc --noEmit           # type check
npx eslint "**/*.{ts,tsx}" # lint
```

## Tailwind Token Classes Reference

| Token class | Usage |
|---|---|
| `bg-background` / `text-foreground` | Page bg + body text |
| `bg-surface-1` | Card background |
| `bg-surface-2` | Input / sidebar background |
| `text-muted-foreground` | Secondary text |
| `border-border` | All borders |
| `bg-primary` / `text-primary` | Primary actions |
| `bg-primary-subtle` | Badge bg, tag bg |
| `text-success` / `text-danger` / `text-warning` | Semantic colors |
