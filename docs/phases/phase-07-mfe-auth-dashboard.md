# Phase 7 — mfe-auth + mfe-dashboard

> Refs: `docs/shared/frontend-conventions.md` · `docs/shared/design-system.md` · `docs/shared/mascot.md`

## mfe-auth (port 3001)

### LoginPage

**Layout:** Split — form left, Bò illustration right (desktop) / stacked (mobile)

**Form (React Hook Form + Zod):**
```typescript
const schema = z.object({
  email:    z.string().email('Email không hợp lệ'),
  password: z.string().min(8, 'Mật khẩu tối thiểu 8 ký tự'),
  remember: z.boolean().optional(),
})
```

**UX:**
- Password show/hide toggle (eye icon)
- "Quên mật khẩu?" link (stub)
- Inline errors — KHÔNG redirect to error page
- Submit → POST /auth/login → store token in Zustand → redirect /dashboard

### RegisterPage

**Form:**
```typescript
z.object({
  name:            z.string().min(2),
  email:           z.string().email(),
  password:        z.string().min(8),
  confirmPassword: z.string(),
  role:            z.enum(['teacher', 'student']),
}).refine(d => d.password === d.confirmPassword, { message: 'Mật khẩu không khớp' })
```

**Role selector:** 2 large cards — Teacher / Student với icon + description.

### OnboardingPage (3 steps)

**Step 1 — Welcome:**
- Bò hero (pose: happy, outfit: A, size: hero)
- Message: "Xin chào! Tao là Bò, cùng cày thôi! 🐃"
- Framer Motion entrance animation

**Step 2 — Role & Subject:**
- Confirm role (từ register)
- Subject multi-select chips (Toán, Tiếng Anh, Vật Lý, Hóa Học, Sinh Học...)

**Step 3 — Profile:**
- Display name input
- Avatar upload stub (icon only, không cần upload thật)

**Progress:** 3-dot indicator, Framer Motion slide transition giữa steps.

---

## mfe-dashboard (port 3002)

### DashboardPage

#### Hero Banner
```tsx
// Teal → navy gradient background
// className="bg-gradient-to-r from-[#0EA5E9] to-[#1B2F4E]"
// Bò: pose=happy, outfit=variant-b, size=hero
// Framer Motion entrance: opacity 0→1 + x -20→0, 600ms
```

#### Stat Cards (4 cards)

| Card | Icon | API endpoint | Counter |
|---|---|---|---|
| Tổng học sinh | Users | GET /users/count | `useCountUp` |
| Đề thi đang chạy | FileText | GET /exams/active | `useCountUp` |
| Kết quả chờ chấm | Clock | GET /results/pending | `useCountUp` |
| Chuỗi ngày học | Flame | từ user profile | `useCountUp` |

**Loading:** 800ms skeleton → staggered fade-in (delay 75ms mỗi card).

#### Bar Chart (Recharts)

```tsx
// Score distribution across recent exams
// Fill: var(--primary)
// Animation: grow from bottom on mount (animationBegin=0, animationDuration=800)
// Axes: text-muted-foreground, no grid lines
```

#### Recent Activity Feed

6 items với: icon · title · description · timestamp (relative).
Left border `border-l-2 border-primary-subtle`.

#### Quick Actions (4 cards)

| Action | Route | Icon |
|---|---|---|
| Tạo đề thi mới | /exams/create | PlusCircle |
| Ngân hàng câu hỏi | /question-bank | Database |
| Xem báo cáo | /reports | BarChart2 |
| Thành tích | /achievements | Trophy |

Cards: `hover:shadow-md hover:-translate-y-1 transition-all duration-200`

---

## Quality Gate

```bash
cd frontend/mfe-auth && next build      # 0 errors
cd frontend/mfe-dashboard && next build # 0 errors
# Verify: Bò renders với correct pose + message
# Verify: dark mode đúng trên cả 2 MFEs
# Verify: 375px mobile layout correct
# Verify: remotes load trong shell-app
```
