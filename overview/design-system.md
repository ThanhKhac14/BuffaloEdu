# Design System — BuffaloEdu

Single source of truth for all visual decisions. Every component must reference this file. Never invent tokens not defined here.

---

## Color Tokens

Use as Tailwind classes via CSS custom properties. Never use raw hex in components.

### Light Mode
```css
--background:         #ffffff;    /* bg-background */
--foreground:         #0f172a;    /* text-foreground */
--muted:              #f1f5f9;    /* bg-muted */
--muted-foreground:   #475569;    /* text-muted-foreground */
--border:             #e2e8f0;    /* border-border */
--border-focus:       #0ea5e9;    /* focus ring */
--primary:            #0ea5e9;    /* bg-primary, text-primary */
--primary-foreground: #ffffff;    /* text-primary-foreground */
--primary-hover:      #0284c7;    /* hover state */
--primary-subtle:     #e0f2fe;    /* bg-primary-subtle (badge bg, tag bg) */
--secondary:          #f59e0b;    /* bg-secondary (streak, highlights) */
--success:            #10b981;    /* text-success, bg-success */
--warning:            #f59e0b;    /* text-warning */
--danger:             #f43f5e;    /* bg-danger, text-danger */
--info:               #38bdf8;    /* text-info */
--surface-0:          #ffffff;    /* page background */
--surface-1:          #f8fafc;    /* card background */
--surface-2:          #f1f5f9;    /* input bg, sidebar bg */
```

### Dark Mode
```css
--background:         #0f172a;
--foreground:         #f8fafc;
--muted:              #1e293b;
--muted-foreground:   #94a3b8;
--border:             #334155;
--border-focus:       #38bdf8;
--primary:            #38bdf8;
--primary-foreground: #0f172a;
--primary-hover:      #0ea5e9;
--primary-subtle:     #0c4a6e;
--secondary:          #fcd34d;
--success:            #34d399;
--warning:            #fcd34d;
--danger:             #fb7185;
--info:               #7dd3fc;
--surface-0:          #0f172a;
--surface-1:          #1e293b;
--surface-2:          #334155;
```

---

## Typography

### Font Families
- **Body/UI**: Plus Jakarta Sans (`font-sans`) — Vietnamese-optimized, friendly
- **Code/Data**: JetBrains Mono (`font-mono`) — question IDs, scores, code

### Scale (use exactly these — no others)

| Name | Class | Weight | Tracking | Usage |
|---|---|---|---|---|
| Display | `text-5xl sm:text-6xl` | `font-bold` | `tracking-tighter` | Hero only |
| H1 | `text-3xl sm:text-4xl` | `font-bold` | `tracking-tight` | Page titles |
| H2 | `text-2xl sm:text-3xl` | `font-bold` | `tracking-tight` | Section headings |
| H3 | `text-lg` | `font-semibold` | default | Card titles |
| H4 | `text-base` | `font-semibold` | default | Subsection labels |
| Body | `text-sm` or `text-base` | `font-normal` | default | Paragraphs |
| Small | `text-xs` | `font-normal` | default | Timestamps, help text |
| Label | `text-sm` | `font-medium` | default | Form labels, nav items |
| Overline | `text-xs font-semibold uppercase tracking-wider` | — | — | Section tags |
| Mono | `text-sm font-mono` | `font-normal` | default | Scores, IDs, code |

---

## Spacing System

Strict 4px base. Only these Tailwind values:

| Tailwind | Pixels | Usage |
|---|---|---|
| `1` | 4px | Icon-to-text gap |
| `2` | 8px | Badge padding, small gaps |
| `3` | 12px | Input padding |
| `4` | 16px | Card internal gaps |
| `5` | 20px | — |
| `6` | 24px | Card padding, section gaps |
| `8` | 32px | Large component gaps |
| `10` | 40px | — |
| `12` | 48px | Section inner padding |
| `16` | 64px | — |
| `20` | 80px | — |
| `24` | 96px | Section outer `py-24` |

---

## Border Radius

| Element | Class | Pixels |
|---|---|---|
| Buttons | `rounded-lg` | 8px |
| Cards | `rounded-xl` | 12px |
| Badges | `rounded-full` | 9999px |
| Inputs | `rounded-lg` | 8px |
| Modals | `rounded-2xl` | 16px |
| Avatars | `rounded-full` | 9999px |
| Icon containers | `rounded-lg` | 8px |
| Question options | `rounded-lg` | 8px |

---

## Shadows

| State | Class | Usage |
|---|---|---|
| Rest | none (border only) | Cards, inputs |
| Hover | `shadow-md` | Interactive cards |
| Elevated | `shadow-lg` | Modals, dropdowns, Bò speech bubble |
| Focus | `ring-1 ring-primary` | Inputs, buttons |

---

## Component Specs

### Button
```
Variants:
  default      → bg-primary text-primary-foreground hover:bg-primary-hover
  secondary    → bg-muted text-foreground hover:bg-muted/80
  ghost        → bg-transparent text-muted-foreground hover:bg-muted hover:text-foreground
  outline      → border border-border text-foreground hover:bg-muted
  danger       → bg-danger text-white hover:bg-danger/90

Sizes:
  sm      → h-8 px-3 text-xs rounded-md
  default → h-9 px-4 text-sm rounded-lg
  lg      → h-11 px-6 text-sm rounded-lg

States:
  disabled → opacity-50 cursor-not-allowed
  loading  → spinner replacing text, disabled
  active   → active:scale-[0.98]

All buttons: font-medium transition-all duration-150
```

### Card
```
Base: rounded-xl border border-border bg-surface-1

Parts:
  CardHeader  → px-6 pt-6
  CardTitle   → text-lg font-semibold text-foreground
  CardDesc    → text-sm text-muted-foreground mt-1
  CardContent → px-6 pb-6

Hover (interactive): hover:shadow-md hover:-translate-y-1 transition-all duration-200
```

### Badge / Tag
```
Base: inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium

Variants:
  default     → bg-primary-subtle text-primary
  success     → bg-success/10 text-success
  warning     → bg-warning/10 text-warning
  danger      → bg-danger/10 text-danger
  info        → bg-info/10 text-info
  outline     → border border-border text-muted-foreground
  secondary   → bg-secondary/10 text-secondary
```

### Input
```
Base: w-full rounded-lg border border-border bg-surface-2 px-3 py-2 text-sm text-foreground
      placeholder:text-muted-foreground
      focus:border-border-focus focus:outline-none focus:ring-1 focus:ring-primary
      transition-colors duration-150

Error state: border-danger focus:ring-danger
             error text below: text-xs text-danger
```

### Skeleton
```
Base: animate-pulse rounded-md bg-muted

Shimmer variant: bg-gradient-to-r from-muted via-surface-2 to-muted bg-[length:200%_100%]
                 animate-shimmer

Match exact dimensions of replaced content.
Show for 800ms on dashboard mount.
```

### Question Card
```
Base: rounded-xl border border-border bg-surface-1 p-6

States:
  unanswered → border-border
  answered   → border-primary bg-primary-subtle/30
  correct    → border-success bg-success/10 (result reveal)
  wrong      → border-danger bg-danger/10 (result reveal)

Options (A/B/C/D):
  Base: rounded-lg border border-border px-4 py-3 text-sm cursor-pointer
        hover:border-primary hover:bg-primary-subtle/20 transition-colors
  Selected: border-primary bg-primary-subtle/30
  Correct:  border-success bg-success/10 text-success font-medium
  Wrong:    border-danger bg-danger/10 text-danger font-medium
```

### Timer Widget
```
Base: flex items-center gap-2 font-mono text-lg font-semibold text-foreground

States:
  normal   → text-foreground
  warning  → text-warning (< 5 min) + pulse scale animation
  critical → text-danger bg-danger/10 rounded-lg px-3 py-1 (< 1 min) + flash animation

Bò micro appears beside timer at warning state.
```

### Score Display (Result Page)
```
Hero number: text-7xl font-bold font-mono text-foreground
             count-up animation 0 → final, 1200ms easeOut

Circle ring: SVG, 120×120px
  Background ring: stroke-muted strokeWidth=8
  Progress ring:   stroke-[score-color] strokeWidth=8 strokeLinecap=round
                   dashoffset animates on mount

Score colors:
  90–100% → text-success stroke-success
  70–89%  → text-primary stroke-primary
  50–69%  → text-warning stroke-warning
  < 50%   → text-danger  stroke-danger
```

---

## Layout Patterns

### Dashboard Page
```tsx
<div className="mx-auto max-w-6xl space-y-8 px-6 py-8">
  {/* Page header */}
  <div className="flex items-center justify-between">
    <div>
      <h1 className="text-2xl font-bold text-foreground tracking-tight">Title</h1>
      <p className="text-sm text-muted-foreground mt-1">Description</p>
    </div>
    <Button>Action</Button>
  </div>
  {/* Content */}
  <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">...</div>
</div>
```

### Exam Take Layout
```tsx
<div className="flex h-screen overflow-hidden">
  {/* Left: Question panel */}
  <div className="flex-1 overflow-y-auto p-6">...</div>
  {/* Right: Navigator sidebar (hidden mobile) */}
  <div className="w-64 border-l border-border overflow-y-auto p-4 hidden lg:block">...</div>
</div>
```

### Sidebar
```
Width: w-60 (full) · w-16 (icon-only, tablet) · drawer (mobile)
Background: bg-surface-1
Border: border-r border-border
Nav item active: bg-primary-subtle text-primary font-medium
Nav item hover: bg-muted text-foreground
Item padding: px-3 py-2.5
Item radius: rounded-lg
Item gap: gap-1
```

---

## Mascot — Bò the Buffalo

### Visual spec (LOCKED)
```
Species:  Vietnamese water buffalo — humanoid, male, friendly
Style:    2D anime cel-shaded, Disney Junior / Nickelodeon quality
Outfit A: White short-sleeve shirt + black khaki pants (casual)
Outfit B: Navy jacket #1B2F4E + teal cuffs #0D9B8A (formal, hero screens)
```

### Color tokens (LOCKED)
```
body:      #6B4F3A    face:      #83604B    belly:     #C9BDB0
horns:     #3D3530    horn_tips: #DCD0B8    nose:      #2A1A0A
eye_iris:  #6A4224    eye_ring:  #D4A44C
nonla:     #F5E6C8    ribbon:    #4A7C59
jacket:    #1B2F4E    cuffs:     #0D9B8A    patch:     #0D9B8A
```

### Sizes
| Size | Dimensions | Usage |
|---|---|---|
| hero | 240×360px (2:3) | Onboarding, result reveal |
| medium | 120×120px | Empty states, streak |
| small | 64×64px | Toast, inline |
| micro | 32×32px | Timer, tab bar |

### Appearance map
| Screen | Size | Pose | Outfit | Message |
|---|---|---|---|---|
| Onboarding | hero | happy | A | "Xin chào! Tao là Bò, cùng cày thôi! 🐃" |
| Dashboard hero | hero | happy | B | Tagline |
| Result 90–100% | hero | celebrating | B | "Đỉnh của chóp! Bò tự hào về mày 🌟" |
| Result 70–89% | hero | proud | B | "Làm tốt lắm! Trâu cày không bỏ cuộc 💪" |
| Result 50–69% | medium | encouraging | A | "Cày thêm tí nữa! Lần sau chắc hơn 🎯" |
| Result < 50% | medium | sad | A | "Đừng nản! Trâu ngã còn đứng dậy được 📚" |
| Empty states | medium | thinking | A | (xem bảng dưới) |
| Streak active | medium | streak-fire | B | "Bò đang giữ lửa! Đừng để tắt nhé." |
| 404 | medium | sleeping | A | "Trang này đang nghỉ trưa... 😴" |
| Error | small | sad | A | "Bò đang sửa máy cày, thử lại sau!" |
| Timer 5min | micro | thinking | — | amber pulse |
| Timer 1min | micro | surprised | — | red flash |

### Empty state messages
| Screen | Message |
|---|---|
| No questions | "Chưa có câu hỏi. Tạo câu hỏi đầu tiên đi!" |
| No exams | "Chưa có đề thi. Bắt đầu tạo đề thôi!" |
| No results | "Chưa có kết quả. Học sinh chưa làm bài." |
| No students | "Lớp học trống. Mời học sinh tham gia nhé!" |
| Search empty | "Bò tìm mãi không thấy 🔍 Thử từ khác đi!" |

### Hat animation (Framer Motion — separate layer)
```
idle:        rotateZ ±3deg, 4s loop ease-in-out
celebrating: y -60px + rotateZ 360deg, spring, then falls back
surprised:   rotateZ 35deg rapid, spring
sleeping:    y +20px covering eyes, slow ease
```

---

## Animation Keyframes (globals.css)

```css
@keyframes fade-in {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes slide-up {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes scale-in {
  from { opacity: 0; transform: scale(0.95); }
  to   { opacity: 1; transform: scale(1); }
}
@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
@keyframes pulse-scale {
  0%, 100% { transform: scale(1); }
  50%       { transform: scale(1.02); }
}
@keyframes flash-red {
  0%, 100% { background-color: transparent; }
  50%       { background-color: rgb(var(--danger) / 0.15); }
}
```

Utility classes:
```css
.animate-fade-in   { animation: fade-in 0.5s ease-out both; }
.animate-slide-up  { animation: slide-up 0.6s ease-out both; }
.animate-scale-in  { animation: scale-in 0.3s ease-out both; }
.animate-shimmer   { animation: shimmer 1.5s infinite linear; }
.delay-75  { animation-delay: 75ms; }
.delay-150 { animation-delay: 150ms; }
.delay-225 { animation-delay: 225ms; }
.delay-300 { animation-delay: 300ms; }
.delay-375 { animation-delay: 375ms; }
.delay-450 { animation-delay: 450ms; }
```
