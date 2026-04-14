---
title: Dashboard — Mobile (Dark & Light)
project: 6319692198318026226
created: 2026-04-14
---

## Overview
- Purpose: Mobile Dashboard skeleton for BuffaloEdu (Dark & Light variants).
- Visual: Mobile-first layout; KPI scroll, quick actions, feed, bottom nav.

## Stitch Screens (generated)
- Dark: `projects/6319692198318026226/screens/d68e4b57f6b14f93bd2a20a036ce4651` (tag: `dashboard/mobile/dark`)
- Light: `projects/6319692198318026226/screens/e28691ad5533426c8908cfdbbb576cef` (tag: `dashboard/mobile/light`)

## Layout
- Canvas: Mobile 375×812.
- TopBar: hamburger left, logo center (36px badge + wordmark), avatar right.
- KPI: horizontally scrollable glass cards (snap points).
- Quick Actions: pill buttons row (New Exam, Scan QR, Ask AI).
- Feed: stacked cards (Ongoing Courses, Upcoming Exams).
- BottomNav: Home, Exams, Inbox, Profile — tappable >=44px.

## Tokens & Tailwind snippets
- TopBar: `h-14 px-4 flex items-center justify-between bg-transparent`
- KPI card: `min-w-[160px] rounded-2xl p-3 bg-[var(--glass-bg)] border-[var(--glass-border)]`
- Quick action pill: `px-3 py-2 rounded-full bg-[var(--glass-bg-strong)]`

## Assets
- same as desktop: `logo.svg`, `mascot-bo.svg`, `leaf-pattern.svg` (mobile-optimized exports)

## Accessibility
- All tap targets >=44px, aria-labels, focus states using `--border-focus`.
- Color contrast verification for small text.

## Motion
- KPI scroll momentum; subtle entrance animations; reduced-motion alternatives.

## Handoff
- [ ] Export mobile asset sizes and attach to Stitch.
- [ ] Provide React/Next components or Storybook stories if needed.

Notes: Use `docs/shared/design-system.md` for token mapping and glass rules.
