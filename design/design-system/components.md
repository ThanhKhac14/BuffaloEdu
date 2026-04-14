# Components — BuffaloEdu (Lotus & Sage)

This file captures component specs, states, accessibility notes and Tailwind snippets.

General rules
- Always use tokens from `design/design-system/tokens.json` or `design/design-system/tokens.css`.
- Do not hardcode colors; use CSS vars.
- Use `Be Vietnam Pro` for headings and `JetBrains Mono` for microcopy.

1) Button — Primary
- Purpose: primary actions like `Đăng nhập`, `Lưu`, `Bắt đầu`.
- Anatomy: 44px height, rounded-lg (8–12px), gradient background (primary → primary-subtle), icon optional left.
- States: default, hover (translateY -1px, shadow stronger), active (scale 0.98), disabled (opacity 0.5, no pointer-events).
- Tailwind example: `h-11 px-6 rounded-lg bg-gradient-to-br from-[var(--primary)] to-[var(--primary-subtle)] text-[var(--primary-foreground)] font-medium`.
- Accessibility: text contrast >= 4.5:1.

2) Button — Ghost / Secondary
- Purpose: less prominent actions / social login.
- Style: glass background, 1px ghost border, subtle backdrop-blur.
- Tailwind: `h-9 px-4 rounded-lg bg-[var(--glass-bg)] border border-[var(--glass-border)]`.

3) Card — Glass
- Use for KPI, feature cards, feeds.
- Size: variable. Radius: 16px. Padding: 16–24px.
- States: hover (scale 1.01, lift), selected (border-primary + subtle tint overlay).
- Markup: `<article class="glass-card" role="group" aria-labelledby="card-title">`.

4) Input — Glass
- Anatomy: label (Be Vietnam Pro), input (glass style), helper/error below.
- Focus: 1px outline using `--border-focus` and 3px ring.
- Error: border color `--danger`, error text `--danger`.
- Tailwind: `w-full rounded-lg px-3 py-2 bg-[var(--glass-bg)] border border-[var(--glass-border)] focus:ring-1 focus:ring-[var(--border-focus)]`.

5) Navbar / Sidebar
- Sidebar collapsed width 72px; expanded 240px.
- Items: icon + label; active state uses `--primary` accent and glass hover background.
- Use `<nav aria-label="Main navigation">`.

6) KPI Card
- Displays number (font-mono large), label, sparkline placeholder.
- Color: use `--primary` or `--success` depending on metric.
- Animation: number count-up 1200ms easeOut.

7) Modal / Drawer
- Modal background: semi-transparent overlay `rgba(0,0,0,0.36)` in dark mode or `rgba(0,0,0,0.08)` in light mode.
- Modal card: `rounded-3xl` (24px), `backdrop-filter: var(--glass-blur-strong)`.

8) Badge
- Small rounded-full, text-xs, background `--primary-subtle/60` and text `--primary`.

9) Icons & Illustrations
- Stroke icons: 1.5pt stroke, rounded caps/joints.
- Illustrations: vector layers named for recolor: `body`, `hat`, `ribbon`, `accent`.

Accessibility notes
- Use semantic HTML landmarks; provide `aria-label` for interactive controls.
- Keyboard: All actionable elements must be keyboard reachable; focus visible and meets contrast.
- Motion: Provide reduced-motion alternatives.

Developer Handoff checklist
- tokens.json + tokens.css included in repo (done)
- component specs in `components.md` (this file)
- export SVG assets: `mascot-bo.svg`, `leaf-pattern.svg`, `logo.svg` (request export)
- examples: Tailwind snippets above; provide React components on request

