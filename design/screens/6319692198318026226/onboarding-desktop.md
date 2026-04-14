Project: 6319692198318026226
Flow: Onboarding — Desktop (3 steps)

Stitch screens (desktop):
- onboarding/desktop/dark — Step 1: projects/6319692198318026226/screens/36de24eaf5804b25b6649ff1c44ddd0a
- onboarding/desktop/dark — Step 2: projects/6319692198318026226/screens/23106e36cca34a9b8a912f28e8922299
- onboarding/desktop/dark — Step 3: projects/6319692198318026226/screens/9dad0e7b98284905bc41bf6b7d374406
- onboarding/desktop/light — Step 1: projects/6319692198318026226/screens/96793578073c4bcc8ff973ee2bc9f7f5
- onboarding/desktop/light — Step 2: projects/6319692198318026226/screens/8f5357ec05ab45d7aaa3c96796d9d922
- onboarding/desktop/light — Step 3: projects/6319692198318026226/screens/44eb92f7cae345478811bc99de8b6c89

Overview:
- Layout: Centered glass panel (max-width 720px) with left decorative illustration and right content.
- Steps: Welcome (Bo hero) → Role selection (Teacher / Student cards) → Profile setup (name, school/class, avatar upload).
- Interaction: Progress dots, keyboard accessible form, reduced-motion support.

Developer notes:
- Tokens: use `design/design-system/tokens.css` variables (glass tokens, spacing, radii).
- Assets: mascot-bo.svg, role-teacher.svg, role-student.svg, avatar-placeholder.svg (place in `public/assets/`). Mark decorative SVGs with `aria-hidden="true"` unless providing semantic info.

Accessibility & Interaction Requirements (apply to desktop + mobile variants):

- Role selection (Critical):
	- Implement role cards as a single-choice **radio group** (`role="radiogroup"`) with each card a `role="radio"` button that covers the full card area.
	- Each radio must expose `aria-checked` and be keyboard operable (Space / Enter to toggle).
	- Visual selected state must be obvious (glass border + subtle inner glow) and focus state must use `--color-border-focus` (3px ring) from tokens.
	- Example HTML pattern:

```
<div role="radiogroup" aria-label="Chọn vai trò">
	<button role="radio" aria-checked="false" class="role-card">Giáo viên</button>
	<button role="radio" aria-checked="true" class="role-card is-selected">Học sinh</button>
</div>
```

- Modal & Keyboard Focus Management:
	- Treat the centered panel as `role="dialog"` with `aria-modal="true"` when opened from the app shell.
	- Trap focus inside the dialog while open; `Esc` closes the dialog and focus is restored to the opener.
	- First focus lands on the primary control (e.g., first form field or primary CTA).

- Progress indicator (High priority):
	- Do not rely on dots only. Include a textual step label visible to everyone (e.g., "Bước 1 của 3 — Chào mừng").
	- Provide programmatic state: use `aria-current="step"` on the current step marker and expose a visually-hidden summary for screen readers.

- Tap targets & spacing (Mobile-first requirement):
	- Enforce minimum interactive size 44×44px for all buttons and selectable cards.
	- Maintain vertical spacing >= 12px between stacked tappables to avoid mis-taps.

- Motion & Reduced Motion (High priority):
	- All animations/transitions must respect `prefers-reduced-motion: reduce` by disabling non-essential motion.
	- Example CSS:

```
@media (prefers-reduced-motion: reduce) {
	.animate { animation: none !important; transition: none !important; }
}
```

- Avatar upload & form behavior:
	- Provide both `file` input and camera capture fallback where supported (`accept="image/*" capture="user"`).
	- Show immediate preview after selection and inline validation messages (with `role="alert"` for errors).
	- Provide keyboard-accessible remove/edit controls for the avatar.

- Decorative assets & alt text:
	- Mark purely decorative SVGs `aria-hidden="true"` and omit alt text.
	- If an illustration conveys meaning (e.g., progress preview), provide descriptive alt text or an adjacent textual caption.

Component examples / CSS tokens (copyable):

```
.glass-panel {
	background: var(--glass-bg, rgba(255,248,244,0.62));
	backdrop-filter: blur(12px);
	border-radius: var(--radius-xl);
	border: 1px solid var(--glass-border, rgba(121,135,119,0.12));
	box-shadow: 0 12px 32px rgba(84,98,83,0.06);
}

.role-card { padding: 16px; min-height: 56px; display:flex; align-items:center; border-radius:var(--radius-lg); }
.role-card:focus { outline: 3px solid var(--color-border-focus); outline-offset: 2px; }
.role-card.is-selected { box-shadow: 0 6px 18px rgba(0,0,0,0.06); border: 1px solid var(--glass-border); }
```

Testing checklist (must pass before handoff):
- Keyboard: Tab order, Enter/Space activate role cards, Esc closes dialog, focus restore.
- Screen reader: Role group announces, current step announced, form errors announced.
- Mobile: Tap targets >=44px, no horizontal overflow, avatar upload works (file + camera).
- Reduced motion: Animations disabled under `prefers-reduced-motion`.

