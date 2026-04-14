---
title: Login — Desktop (Light & Dark)
project: 6319692198318026226
created: 2026-04-14
---

## Overview
- Purpose: Desktop login screen for BuffaloEdu using the project Stitch design systems (Light & Dark).
- Visual: Glassmorphism + Botanical/Organic — centered glass card, Bò mascot accent, floating leaves, subtle grain texture.

## Stitch Screens
- Light: `projects/6319692198318026226/screens/59429d3ec1ee49cab617a61ddf5294bf` (tag: `login/desktop/light`)
- Dark:  `projects/6319692198318026226/screens/91ed76bb9c2b47609129e57fa00ce735` (tag: `login/desktop/dark`)

## Key Tokens (map to `docs/shared/design-system.md`)
- Glass background: `--glass-bg` / `--glass-bg-strong`
- Border: `--glass-border`
- Shadow: `--glass-shadow`
- Primary: `--primary` / `--primary-subtle`
- Text on light glass: `--foreground` ; on dark glass: `--primary-foreground` or `--foreground` from dark tokens

## Layout & Spacing
- Canvas: Desktop (1280–1440px). Card max-width: 520px; centered with generous side gutters.
- Card padding: 24px (desktop) — inside two-column grid: left (40%): illustration, right (60%): form.
- Form spacing: vertical rhythm 12–16px between inputs; CTA top margin 18px.

## Components & Tailwind snippets
- Card (glass): `backdrop-blur-md rounded-2xl border p-6` + inline style `background:var(--glass-bg); border-color:var(--glass-border); box-shadow:var(--glass-shadow)`
- Title: `text-3xl font-bold` — "Chào mừng trở lại"
- Subtitle: `text-sm text-muted-foreground` — "Đăng nhập để tiếp tục học cùng Bò"
- Input: `w-full rounded-lg px-3 py-2 text-sm bg-[var(--glass-bg)] border border-[var(--glass-border)] focus:outline-none focus:ring-1 focus:ring-[var(--border-focus)]`
- Primary CTA: `h-11 px-6 rounded-lg bg-[var(--primary)] text-[var(--primary-foreground)] font-medium transition duration-150` (use gradient subtle if desired)
- Secondary link: `text-sm text-[var(--primary)] hover:underline` 

## Illustration & Assets
- `mascot-bo.svg` — hero export 480×480, medium 240×240, icon 48×48 (layers: body, hat, ribbon named for easy recolor)
- `leaf-pattern.svg` — tileable vector for background grain; export at 2× for crispness
- `logo.svg` — header, 120×40 and 240×80 variants

## Accessibility
- All inputs must have `<label for="...">` and `aria-describedby` for errors.
- Focus states: visible 3px ring (use `--border-focus` or `--primary`) and not only outline.
- Color contrast: verify text on glass meets 4.5:1.
- Respect `prefers-reduced-motion` and provide reduced animations.

## Motion
- Card entrance: fade + translateY(12px) 400ms ease-out.
- Floating leaves: slow vertical float loop (6–9s) with reduced-motion alternative.

## Handoff checklist
- [ ] Export `mascot-bo.svg` (3 sizes) and `leaf-pattern.svg` tiles.
- [ ] Confirm Stitch screens above and link to assets in design system.
- [ ] Provide developer CSS variables (see tokens) and Tailwind utility examples.

## Notes
- Use `docs/shared/design-system.md` for exact token values and glass rules.
- If you want tweaks (e.g., single-column layout, different mascot pose, or an extra social-login row), say which variant to produce next.
