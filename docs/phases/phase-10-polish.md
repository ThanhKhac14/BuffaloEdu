# Phase 10 — Polish & Responsive

> KHÔNG có feature mới. Refinement only.

## 10.1 — Animation Tuning

| Element | Spec |
|---|---|
| Standard transitions | `150ms ease-out` |
| Sidebar collapse | `width 240→64px + icon crossfade, 300ms` |
| Tab/stepper indicators | Slide (không jump) |
| Modal entrance | `scale 0.95→1 + opacity 0→1, 250ms` |
| Question option select | `scale 0.98→1, 80ms spring` |
| Bò idle breathing | `scale 1→1.02→1, 3s loop` — consistent, không jitter on re-renders |
| Card hover | `translateY -2px + shadow-md, 200ms` |
| Toast enter | `slide-in-right, 300ms spring` |
| Correct answer flash | `bg-success/20 flash + scale 1→1.04→1, 300ms spring` |
| Wrong answer shake | `translateX 0→8→-6→4→0px, 400ms` |

## 10.2 — Dark Mode Audit (screen by screen)

Checklist mỗi screen:
- [ ] Background, foreground, muted text đúng
- [ ] Card backgrounds (`surface-1`)
- [ ] Borders, dividers (`border-border`)
- [ ] Charts (axes, tooltips, grid lines) readable
- [ ] Badges đúng variant colors
- [ ] Toast backgrounds không transparent
- [ ] Bò speech bubble readable
- [ ] Score ring colors đúng
- [ ] Skeleton shimmer visible
- [ ] Input, select backgrounds đúng

**KHÔNG có hardcoded color anywhere — kiểm tra bằng:**
```bash
grep -r "style={{" frontend/ | grep -v "//\|test\|node_modules"
grep -rE "#[0-9a-fA-F]{3,6}" frontend/src --include="*.tsx"
```

## 10.3 — Responsive Audit

### 375px (mobile)
- [ ] Single column layout
- [ ] Bottom tab bar (5 items: Dashboard, Exams, Questions, Reports, Profile)
- [ ] Sidebar → drawer (hamburger trigger)
- [ ] Exam navigator → bottom slide-up drawer
- [ ] DataTable → horizontal scroll hoặc card view
- [ ] Charts → full width, simplified labels
- [ ] Stat cards → 2-col grid

### 768px (tablet)
- [ ] Icon-only sidebar (64px)
- [ ] 2-col grids where applicable
- [ ] Charts resize correctly

### 1024px+ (desktop)
- [ ] Full sidebar 240px
- [ ] Multi-column layouts

### 1280px+ (wide)
- [ ] Max-width `max-w-7xl mx-auto` active
- [ ] No overly wide text columns

**Touch targets:** `min-w-[44px] min-h-[44px]` trên mọi interactive element.

## 10.4 — Accessibility

- [ ] Focus rings visible trên mọi interactive element (`focus-visible:ring-2 ring-primary`)
- [ ] Aria-labels trên mọi icon-only button
- [ ] Alt text trên Bò images
- [ ] Error messages trong `aria-live` regions
- [ ] Keyboard navigation: Tab / Enter / Escape / Arrow keys
- [ ] Color không phải sole indicator (always icon + color)
- [ ] Contrast ratio ≥ 4.5:1 cho text

## Quality Gate

```bash
# Tất cả MFEs + shell
cd frontend/shell-app    && next build   # 0 errors
cd frontend/mfe-auth     && next build
cd frontend/mfe-dashboard && next build
cd frontend/mfe-exam     && next build
cd frontend/mfe-question && next build
cd frontend/mfe-reports  && next build
```
