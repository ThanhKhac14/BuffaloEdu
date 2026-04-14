---
title: Dashboard — Desktop (Dark & Light)
project: 6319692198318026226
created: 2026-04-14
---

## Overview
- Purpose: Desktop Dashboard skeleton for BuffaloEdu (Dark first, then Light).
- Visual: Glassmorphism + Botanical/Organic — left side nav, topbar, KPI hero row, activity feed, progress column.

## Stitch Screens (generated)
- Dark: `projects/6319692198318026226/screens/648100ec659c4edbbc33c7516a57a682` (tag: `dashboard/desktop/dark`)
- Light: `projects/6319692198318026226/screens/0f2f84e517a94a0ca905da4df48f27a8` (tag: `dashboard/desktop/light`)

## Layout
- Canvas: Desktop (1280–1440px). Card grid: 12 columns.
- SideNav: collapsible, icons + labels, width 72px collapsed / 240px expanded.
- Topbar: search, notifications, avatar, compact breadcrumbs.
- Hero KPI: 4 glass cards (equal width) with 16px gap.
- Main: two columns — left (8 cols): Recent Activity feed; right (4 cols): Course Progress, small charts.

## Tokens & Tailwind snippets
- Glass card: `backdrop-blur-md rounded-2xl border p-6` + `style="background:var(--glass-bg); border-color:var(--glass-border); box-shadow:var(--glass-shadow)"`
- KPI card: `w-full rounded-2xl p-4 bg-[var(--glass-bg)] border-[var(--glass-border)]`
- Sidebar item: `h-10 px-3 flex items-center gap-3 rounded-lg hover:bg-[var(--glass-bg-strong)]`

## Assets
- `buffaloedu-logo.svg` (horizontal) — 240×80 and 120×40
- `mascot-bo.svg` — hero 480×480, medium 240×240, icon 48×48 (layers: body, hat, ribbon)
- `leaf-pattern.svg` — tileable vector for background grain

## Accessibility
- Landmarks: `<nav>`, `<header>`, `<main>`, `<aside>`, `<footer>` used.
- Focus: visible 3px ring using `--border-focus`.
- Contrast: ensure text meets 4.5:1 on glass backgrounds.

## Motion
- Page entrance: fade + translateY(12px) 400ms ease-out.
- Card hover: scale(1.01) with shadow change.
- Respect `prefers-reduced-motion`.

## Handoff
- [ ] Export assets and attach to Stitch screens.
- [ ] Provide React/Next components from the skeleton if required.

Notes: See `docs/shared/design-system.md` for exact token values and glass rules.
