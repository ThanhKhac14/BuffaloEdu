# SKILL: MFE Remote App Scaffold

Auto-activates when: creating a new MFE, editing `next.config.ts` in a remote app, working in `frontend/mfe-*/`

---

## Module Federation Remote Config

```typescript
// next.config.ts (each remote app)
const { NextFederationPlugin } = require('@module-federation/nextjs-mf')

module.exports = {
  webpack(config: any) {
    config.plugins.push(
      new NextFederationPlugin({
        name: 'mfe_{name}',  // e.g. mfe_auth, mfe_dashboard
        filename: 'static/chunks/remoteEntry.js',
        exposes: {
          './{PageName}Page': './src/app/{route}/page.tsx',
          // expose ALL pages this MFE owns
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

## Tailwind Config (every MFE must extend shared tokens)

```typescript
// tailwind.config.ts
import tokens from '../../shared/ui/tokens.json'

export default {
  darkMode: 'class',
  content: [
    './src/**/*.{ts,tsx}',
    '../../shared/ui/**/*.tsx',
  ],
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

## globals.css (every MFE)

```css
@import '../../shared/ui/tokens.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## Component rules

```typescript
// ✅ Correct — server component by default
export default function QuestionBankPage() {
  return <div className="mx-auto max-w-6xl px-6 py-8">...</div>
}

// ✅ Correct — "use client" only when needed
"use client"
import { useState } from 'react'
export default function TimerWidget({ duration }: { duration: number }) {
  const [remaining, setRemaining] = useState(duration)
  // ...
}

// ❌ Wrong — hardcoded color
<div style={{ color: '#0EA5E9' }}>

// ✅ Correct — token class
<div className="text-primary">

// ❌ Wrong — inline style for spacing
<div style={{ padding: '24px' }}>

// ✅ Correct — Tailwind spacing
<div className="p-6">
```

## Import order (enforce in every file)

```typescript
// 1. React/Next
import { useState, useEffect } from 'react'
import Link from 'next/link'

// 2. External libraries
import { motion } from 'framer-motion'
import { BookOpen } from 'lucide-react'

// 3. Shared components
import { Button } from '@/shared/ui/button'
import BoCharacter from '@/shared/ui/BoCharacter'

// 4. MFE-local components
import QuestionCard from '@/components/QuestionCard'

// 5. Lib / store / api
import { useAuthStore } from '@/shared/store/auth'
import { cn } from '@/shared/utils'
import type { Question } from '@/shared/types'
```

## Bò integration pattern

```typescript
import BoCharacter from '@/shared/ui/BoCharacter'

// Score-based pose selection
function getBoProps(score: number) {
  if (score >= 90) return { pose: 'celebrating', outfit: 'variant-b', message: 'Đỉnh của chóp! Bò tự hào về mày 🌟' }
  if (score >= 70) return { pose: 'proud',       outfit: 'variant-b', message: 'Làm tốt lắm! Trâu cày không bỏ cuộc 💪' }
  if (score >= 50) return { pose: 'encouraging', outfit: 'variant-a', message: 'Cày thêm tí nữa! Lần sau chắc hơn 🎯' }
  return             { pose: 'sad',         outfit: 'variant-a', message: 'Đừng nản! Trâu ngã còn đứng dậy được 📚' }
}

// Usage
const boProps = getBoProps(score)
<BoCharacter pose={boProps.pose} size="hero" outfit={boProps.outfit} message={boProps.message} animate />
```

## Loading pattern (skeleton within 150ms)

```typescript
'use client'
import { Suspense } from 'react'
import { Skeleton } from '@/shared/ui/skeleton'

// Always wrap async data in Suspense
<Suspense fallback={<StatCardSkeleton />}>
  <StatCards />
</Suspense>

// Skeleton matches exact shape of content
function StatCardSkeleton() {
  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {Array.from({ length: 4 }).map((_, i) => (
        <div key={i} className="rounded-xl border border-border p-6 space-y-3">
          <Skeleton className="h-4 w-24" />
          <Skeleton className="h-8 w-16" />
          <Skeleton className="h-3 w-32" />
        </div>
      ))}
    </div>
  )
}
```

## Dockerfile (each MFE)

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
```

## Quality gate
After any frontend work:
1. `next build` — 0 errors, 0 warnings
2. Dark mode visual check
3. Mobile layout at 375px
4. Remote loads correctly in shell-app
