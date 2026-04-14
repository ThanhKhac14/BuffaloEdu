Project: 6319692198318026226
Flow: Onboarding — Mobile (3 steps)

Stitch screens (mobile):
- onboarding/mobile/dark — Step 1: projects/6319692198318026226/screens/d11c3bf5509f4cd7a2a5660fa00bb020
- onboarding/mobile/dark — Step 2: projects/6319692198318026226/screens/77db4380382941d6bd495bc1e52d2c8f
- onboarding/mobile/dark — Step 3: projects/6319692198318026226/screens/a7e2e679f00f40ec8db99bd307078398
- onboarding/mobile/light — Step 1: projects/6319692198318026226/screens/4a96d1d846454b9c8126918f24b6b686
- onboarding/mobile/light — Step 2: projects/6319692198318026226/screens/0b640423fb85463db1af5bd471b88c4d
- onboarding/mobile/light — Step 3: projects/6319692198318026226/screens/f1603b2132964c1d96c3401d170e5bbb

Overview:
- Mobile-first, full-screen glass panels with swipeable steps and bottom primary CTA.
- Steps: Welcome (hero + CTA) → Role selection (stacked cards) → Profile setup (avatar + fields).
- Accessibility: large tap targets (>=44px), labels, focus rings, reduced-motion.

Developer notes:
- Provide SVGs sized for mobile (2x/3x) and ensure avatars are 72px default.
- Mark decorative SVGs with `aria-hidden="true"` unless semantic.

Accessibility & Interaction Requirements (mobile-specific):

- Role selection:
	- Use the same `radiogroup` pattern as desktop but stacked vertically.
	- Ensure each card is full-width with `min-height` to guarantee a 44×44px hit area.

- Swipeable steps & keyboard support:
	- Allow swipe gestures for step changes but also expose explicit Previous / Next buttons.
	- Ensure keyboard users can navigate steps via Left/Right arrows and Enter to confirm.

- Progress indicator:
	- Show textual step label ("Bước 2 của 3 — Chọn vai trò") above the controls; dots are supplementary.

- Motion & reduced-motion:
	- Reduce or disable step transition animation when `prefers-reduced-motion` is set.

- Avatar upload (mobile):
	- Offer `capture="user"` for camera on supported devices and fallback to file picker.
	- Provide clear preview, crop affordance and an accessible remove button.

CSS / component hints (mobile):

```
.role-card { padding: 18px 16px; min-height: 64px; border-radius: 12px; }
.cta-primary { width: 100%; padding: 14px 16px; border-radius: 12px; }
```

Testing checklist (mobile):
- Touch: all tappables >=44px and spaced vertically.
- Gestures: swipe to change steps + accessible buttons for non-gesture users.
- Camera: avatar capture works on iOS/Android with preview.
- Reduced motion: no non-essential animation when reduced-motion is requested.

