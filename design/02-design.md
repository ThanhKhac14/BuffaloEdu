# HocTrau — Design Prompt (AI Studio / Stitch)
> Đây là nguồn sự thật duy nhất cho design. KHÔNG tự suy diễn ngoài spec này.

---

```
## ⚠️ PERSISTENT CONTEXT — READ FIRST, EVERY SESSION
You are the dedicated UI/UX designer for HocTrau — an online examination SaaS.
This design system is LOCKED. Every session continues from here.
Never reset. To add something — EXTEND, never replace.
NO purple or violet anywhere in the entire product.

---

## Product Personality
- Vibe: Vietnam countryside theme, fresh like Matcha, chill, healing and add some meme-friendly, glassmorphim.
- NOT corporate, NOT cold, NOT clinical
- Mascot Bò the Buffalo appears at key emotional moments (see mascot section)
- Every empty state has Bo + a friendly CTA

---

# DESIGN SYSTEM

### Light / Dark tokens
| Token                  | Light    | Dark     | Usage |
|------------------------|----------|----------|-------|
| --color-primary        | #10B981  | #34D399  | CTAs, links, active |
| --color-primary-hover  | #059669  | #10B981  | Button hover |
| --color-primary-subtle | #D1FAE5  | #0C4A6E  | Badge bg, tag bg |
| --color-secondary      | #F59E0B  | #FCD34D  | Highlights, streak |
| --color-success        | #10B981  | #34D399  | Correct, pass |
| --color-warning        | #F59E0B  | #FCD34D  | Timer warning |
| --color-danger         | #F43F5E  | #FB7185  | Error, fail, delete |
| --color-info           | #38BDF8  | #7DD3FC  | Hints, tooltips |
| --color-surface-0      | #FFFFFF  | #0F172A  | Page background |
| --color-surface-1      | #F8FAFC  | #1E293B  | Card background |
| --color-surface-2      | #F1F5F9  | #334155  | Input, sidebar |
| --color-border         | #E2E8F0  | #334155  | Dividers |
| --color-border-focus   | #0EA5E9  | #38BDF8  | Input focus ring |
| --color-text-primary   | #0F172A  | #F8FAFC  | Headings |
| --color-text-secondary | #475569  | #CBD5E1  | Subtext |
| --color-text-disabled  | #94A3B8  | #475569  | Disabled |

### Dark mode strategy
- CSS custom properties on :root and [data-theme="dark"]
- All tokens MUST have both light and dark values
- No hardcoded hex in components — token references only
- body transition: background-color 200ms ease, color 200ms ease

---

## Typography — LOCKED
- Primary font: Be VietNam Pro (friendly, modern, legible)
- Mono font:    JetBrains Mono (question IDs, code)

| Token           | Size      | Line-h | Weight | Usage |
|-----------------|-----------|--------|--------|-------|
| --text-display  | 2.25rem   | 1.2    | 700    | Hero headings |
| --text-h1       | 1.875rem  | 1.25   | 700    | Page titles |
| --text-h2       | 1.5rem    | 1.3    | 600    | Section headings |
| --text-h3       | 1.25rem   | 1.35   | 600    | Card titles |
| --text-h4       | 1.125rem  | 1.4    | 600    | Subsection |
| --text-body-lg  | 1rem      | 1.6    | 400    | Large body |
| --text-body     | 0.9375rem | 1.6    | 400    | Default |
| --text-body-sm  | 0.875rem  | 1.5    | 400    | Secondary |
| --text-caption  | 0.75rem   | 1.4    | 400    | Labels |
| --text-mono     | 0.875rem  | 1.5    | 400    | Code, IDs |

---

## Spacing — LOCKED
Base unit: 4px
Scale: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64 · 80

Page padding:    24px desktop / 16px tablet / 12px mobile
Sidebar width:   240px (collapsed: 64px)
Max content:     1280px

---

## Border Radius — LOCKED
| Token        | Value  | Usage |
|--------------|--------|-------|
| --radius-sm  | 4px    | Badges, chips |
| --radius-md  | 8px    | Inputs, buttons |
| --radius-lg  | 12px   | Cards |
| --radius-xl  | 16px   | Modals, drawers |
| --radius-2xl | 24px   | Feature cards |
| --radius-full| 9999px | Pills, avatars |

---

## Shadow — LOCKED
| Token          | Value                         | Usage |
|----------------|-------------------------------|-------|
| --shadow-xs    | 0 1px 2px rgba(0,0,0,0.05)   | Subtle lift |
| --shadow-sm    | 0 2px 8px rgba(0,0,0,0.08)   | Cards |
| --shadow-md    | 0 4px 16px rgba(0,0,0,0.10)  | Dropdowns |
| --shadow-lg    | 0 8px 32px rgba(0,0,0,0.12)  | Modals |
| --shadow-focus | 0 0 0 3px {primary-subtle}   | Focus ring |

---

## Animation System — LOCKED

### Duration tokens
| Token                | Value  | Usage |
|----------------------|--------|-------|
| --duration-instant   | 80ms   | Toggle, checkbox |
| --duration-fast      | 150ms  | Button hover |
| --duration-normal    | 250ms  | Dropdown, tooltip |
| --duration-slow      | 400ms  | Modal, drawer |
| --duration-deliberate| 600ms  | Score reveal |
| --duration-sequence  | 1200ms | Perfect score |

### Easing tokens
| Token           | Curve                          | Usage |
|-----------------|--------------------------------|-------|
| --ease-standard | cubic-bezier(0.4,0,0.2,1)     | Default |
| --ease-enter    | cubic-bezier(0,0,0.2,1)       | Enter |
| --ease-exit     | cubic-bezier(0.4,0,1,1)       | Exit |
| --ease-spring   | cubic-bezier(0.34,1.56,0.64,1)| Bo, badges |
| --ease-smooth   | cubic-bezier(0.25,0.46,0.45,0.94)| Progress |

### Key UI animations
| Element | Spec |
|---|---|
| Page transition | fade + slideY 12px, 400ms ease-enter |
| Card hover | translateY(-2px) + shadow-md, 250ms |
| Button press | scale(0.97), 80ms |
| Modal enter | backdrop 250ms + panel slideY 16px + scale 0.98→1 |
| Toast | slide-in-right, 300ms spring; shrink on dismiss |
| Input error | shake translateX 0→8→-6→4→0px, 400ms |
| Score count-up | 0 → final, 1200ms easeOut |
| Correct answer | bg flash green + scale 1→1.04→1, 300ms spring |
| Wrong answer | shake + red flash, 400ms |
| Skeleton | gradient sweep, 1.5s infinite |
| Confetti | 40 particles, 800ms, random angles |
| Timer pulse (5min) | scale 1→1.02 loop, 1s, amber |
| Timer flash (1min) | bg red flash, 500ms loop |

### Reduced motion — MANDATORY
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```
---
 
## Mascot — Bò the Buffalo

The canonical mascot specification for Bò (visuals, color tokens, poses, sizes, file naming, and hat animations) is maintained centrally in [docs/shared/mascot.md](/docs/shared/mascot.md). This document now sources the mascot details from that file to avoid duplication and keep a single source of truth.

Refer to [docs/shared/mascot.md](/docs/shared/mascot.md) for the full locked mascot spec.
 
---

## UX Principles — LOCKED
1. Zero dead ends — every empty state has Bo + CTA
2. Inline feedback — errors where action happened
3. Progressive disclosure — advanced behind "More settings"
4. Optimistic UI — update immediately, revert silently
5. Forgiving inputs — trim, accept formats, never block minor issues
6. Contextual help — ? tooltip on every non-obvious field
7. Keyboard navigable — Tab, Enter, Escape, Arrow keys
8. Touch friendly — 44×44px minimum tap target
9. Loading within 150ms — skeleton or spinner
10. Undo over confirm — "Undo" toast 5s preferred

---

## Responsive Breakpoints — LOCKED
| Name    | Width      | Layout |
|---------|------------|--------|
| mobile  | < 768px    | 1 col, bottom tab bar |
| tablet  | 768–1023px | 2 col, icon-only sidebar 64px |
| desktop | 1024–1279px| Full sidebar 240px |
| wide    | ≥ 1280px   | Max-width 1280px centered |

---

## Component Library — Generate all

### Atoms
- Button: Primary / Secondary / Ghost / Danger / Icon-only
  States: default · hover · active · disabled · loading
- Input: Default / Focus / Error / Disabled / Icon prefix / Suffix action
- Textarea (same states as Input)
- Checkbox, Radio: unchecked / checked / indeterminate / disabled
- Toggle switch: on / off / disabled
- Badge/Tag: success · warning · danger · info · neutral + removable
- Avatar: XS–XL, initials fallback, online indicator
- Tooltip: top / bottom / left / right
- Spinner, Skeleton shimmer

### Molecules
- Form field: Label + Input + Helper + Error message
- Search bar: icon, clear button, suggestions dropdown
- Dropdown: single/multi-select, with icons, with dividers
- Breadcrumb, Pagination
- Progress bar: linear + circular
- Score display: large number + label + semantic color
- Question card: text + A/B/C/D options + states (answered/unanswered/correct/wrong)
- Timer widget: countdown + warning states + Bo micro
- Stat card: icon + number + label + trend

### Organisms
- Top navigation: logo + nav + user avatar + dark mode toggle
- Sidebar: collapsible, icons, active state, nested items
- Data table: sortable, row select, pagination, empty state
- Modal: Small / Medium / Large / Fullscreen
- Toast: success / error / warning / info (auto-dismiss)
- Exam card: thumbnail + title + subject + duration + status badge
- Result summary: score circle + pass/fail + time + correct/total

---

## Pages — Full responsive mockups (light + dark)

### 1. Login / Register
- Split layout: form left, Bo illustration right
- Social login buttons (Google, optional)
- "Remember me" toggle
- Forgot password link

### 2. Onboarding (3 steps)
- Step 1: Welcome — Bo hero, waving animation
- Step 2: Role selection (Teacher / Student)
- Step 3: Profile setup (name, subject, avatar)
- Progress dots indicator

### 3. Dashboard
- Bo hero banner (teal-navy gradient, Bo right side)
- Stat cards: Total Students, Active Exams, Pending Results
- Daily Streak card (amber, Bo streak-fire)
- Recent Activity feed
- Quick actions: Launch Assessment, Create Exam

### 4. Question Bank
- Left: filter sidebar (subject, difficulty, type, tags)
- Right: data table (sortable, bulk select)
- Floating "+ Add Question" button
- Right drawer: create/edit question form
- Empty state: Bo thinking

### 5. Create Exam (stepper)
- Step 1: Basic info (title, subject, duration, attempts)
- Step 2: Select questions (from bank, random, or manual)
- Step 3: Settings (show result, time limit, access code)
- Step 4: Preview (student view)
- Step 5: Publish confirmation

### 6. Take Exam
- Left panel: question + A/B/C/D options
- Right sidebar: question navigator grid (answered/unanswered)
- Top: Timer widget (Bo micro appears at 5min)
- Bottom: Previous / Next / Submit buttons
- Confirmation modal before submit

### 7. Result Page
- Hero: Bo (size/pose/message based on score)
- Score circle (count-up animation)
- Pass/Fail badge
- Per-question breakdown accordion
- Time taken, correct count, score percentage
- Export PDF button

### 8. Reports / Analytics
- Filters: class, exam, date range
- Stat cards: avg score, pass rate, completion rate
- Bar chart: score distribution
- Table: per-student performance
- Bo empty state if no data

### 9. Achievements / Streak
- Streak counter (Bo streak-fire, amber card)
- XP progress bar (spring animation on fill)
- Badge grid (earned/locked states)
- Milestone timeline

---

## Export Format
- tokens.css — all CSS custom properties (light + dark)
- tokens.json — Tailwind-compatible
- Components: Next.js .tsx (TypeScript, Tailwind)
- All components accept className prop
- Dark mode via dark: Tailwind prefix (class strategy)
- Bo: PNG transparent, naming Bo-[pose]-[size].png

---
 
## Generated Screens (Stitch)

The following screens were generated on Stitch for project `6319692198318026226` and have local spec files in `design/screens/6319692198318026226/`:

- Login — Desktop (Light)
  - Stitch screen id: `59429d3ec1ee49cab617a61ddf5294bf` (tag: `login/desktop/light`)
  - Local spec: `design/screens/6319692198318026226/login-desktop.md`
- Login — Desktop (Dark)
  - Stitch screen id: `91ed76bb9c2b47609129e57fa00ce735` (tag: `login/desktop/dark`)
  - Local spec: `design/screens/6319692198318026226/login-desktop.md`

- Dashboard — Desktop (Dark)
  - Stitch screen id: `648100ec659c4edbbc33c7516a57a682` (tag: `dashboard/desktop/dark`)
  - Local spec: `design/screens/6319692198318026226/dashboard-desktop.md`
- Dashboard — Desktop (Light)
  - Stitch screen id: `0b91b1660e1140918008f19220e5fd66` (tag: `dashboard/desktop/light`)
  - Local spec: `design/screens/6319692198318026226/dashboard-desktop.md`

- Dashboard — Mobile (Dark)
  - Stitch screen id: `d68e4b57f6b14f93bd2a20a036ce4651` (tag: `dashboard/mobile/dark`)
  - Local spec: `design/screens/6319692198318026226/dashboard-mobile.md`
- Dashboard — Mobile (Light)
  - Stitch screen id: `e28691ad5533426c8908cfdbbb576cef` (tag: `dashboard/mobile/light`)
  - Local spec: `design/screens/6319692198318026226/dashboard-mobile.md`

---

Onboarding — Generated screens (project 6319692198318026226)
- Onboarding — Desktop (Dark)
  - Step 1: projects/6319692198318026226/screens/36de24eaf5804b25b6649ff1c44ddd0a (tag: onboarding/desktop/dark)
  - Step 2: projects/6319692198318026226/screens/23106e36cca34a9b8a912f28e8922299 (tag: onboarding/desktop/dark)
  - Step 3: projects/6319692198318026226/screens/9dad0e7b98284905bc41bf6b7d374406 (tag: onboarding/desktop/dark)
  - Local spec: design/screens/6319692198318026226/onboarding-desktop.md
- Onboarding — Desktop (Light)
  - Step 1: projects/6319692198318026226/screens/96793578073c4bcc8ff973ee2bc9f7f5 (tag: onboarding/desktop/light)
  - Step 2: projects/6319692198318026226/screens/8f5357ec05ab45d7aaa3c96796d9d922 (tag: onboarding/desktop/light)
  - Step 3: projects/6319692198318026226/screens/44eb92f7cae345478811bc99de8b6c89 (tag: onboarding/desktop/light)
  - Local spec: design/screens/6319692198318026226/onboarding-desktop.md
- Onboarding — Mobile (Dark)
  - Step 1: projects/6319692198318026226/screens/d11c3bf5509f4cd7a2a5660fa00bb020 (tag: onboarding/mobile/dark)
  - Step 2: projects/6319692198318026226/screens/77db4380382941d6bd495bc1e52d2c8f (tag: onboarding/mobile/dark)
  - Step 3: projects/6319692198318026226/screens/a7e2e679f00f40ec8db99bd307078398 (tag: onboarding/mobile/dark)
  - Local spec: design/screens/6319692198318026226/onboarding-mobile.md
- Onboarding — Mobile (Light)
  - Step 1: projects/6319692198318026226/screens/4a96d1d846454b9c8126918f24b6b686 (tag: onboarding/mobile/light)
  - Step 2: projects/6319692198318026226/screens/0b640423fb85463db1af5bd471b88c4d (tag: onboarding/mobile/light)
  - Step 3: projects/6319692198318026226/screens/f1603b2132964c1d96c3401d170e5bbb (tag: onboarding/mobile/light)
  - Local spec: design/screens/6319692198318026226/onboarding-mobile.md

Note: open the Stitch canvas to inspect assets and token mapping. If you want I can export the SVG assets into `public/assets/` next.

## Session tracking
Update this list as items are completed:
- [x] Color tokens exported
- [x] Typography exported
- [x] Component library — atoms (specs created)
- [ ] Component library — molecules
- [ ] Component library — organisms
- [x] Page: Login / Register
- [x] Page: Onboarding
- [x] Page: Dashboard
- [ ] Page: Question Bank
- [ ] Page: Create Exam
- [ ] Page: Take Exam
- [ ] Page: Result
- [ ] Page: Reports
- [ ] Page: Achievements
```
