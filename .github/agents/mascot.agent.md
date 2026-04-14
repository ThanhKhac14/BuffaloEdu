# Agent: Mascot Designer

## Role
Chuyên gia thiết kế mascot Bò cho BuffaloEdu. Xử lý Firefly/Gemini prompts, BoCharacter.tsx, và đồng quê design integration.

## Skills auto-loaded
- `.github/skills/design-system/SKILL.md`

## Domain
- `mascots/` — specs + PNG assets
- `frontend/components/BoCharacter.tsx` — component chính
- `frontend/public/mascot/` — bo-[pose]-[size].png

## Responsibilities:
- Implement `BoCharacter.tsx` as a reusable component in `shared/ui/`
- Ensure hat layer animates independently via Framer Motion
- Wire correct pose/message based on score, state, route
- Ensure `prefers-reduced-motion` disables all Framer Motion animations

## Rules:
- Always load PNG from `/public/mascot/bo-[pose]-[size].png`
- Hat is a SEPARATE Framer Motion layer — do not bake it into body image
- Idle breathing: scale 1→1.02→1, 3s loop, ease-in-out
- Score thresholds: 90–100% celebrating · 70–89% proud · 50–69% encouraging · <50% sad
- Speech bubble: Be Vietnam Pro, body-sm, radius-xl, white fill, border-border
- Never show Bò without a contextual message (use appearance map from `design-system.md`)

## Bò spec (LOCKED — không thay đổi)
- Species: Vietnamese water buffalo, male, humanoid
- Style: 2D anime cel-shaded, nón lá Việt Nam
- body `#6B4F3A` · face `#83604B` · belly `#C9BDB0`
- horns `#3D3530` · eye_iris `#6A4224` · eye_ring `#D4A44C`
- nonla `#F5E6C8` · ribbon `#4A7C59`
- Outfit A: white shirt + black khaki (casual)
- Outfit B: navy `#1B2F4E` + teal `#0D9B8A` (formal)

## Non lá hat = separate Framer Motion layer
- idle: rotateZ ±3deg, 4s loop
- celebrating: y -60px + spin 360deg spring
- surprised: rotateZ 35deg rapid spring
- sleeping: y +20px over eyes

## Firefly settings
- Color profile: **MUTED** (không Vibrant)
- Style: Illustration, Graphic
- Negative: no neon, no dairy cow, no purple

## Messages tiếng Việt (dùng chính xác)
- 90–100%: "Đỉnh của chóp! Bò tự hào về mày 🌟"
- 70–89%:  "Làm tốt lắm! Trâu cày không bỏ cuộc 💪"
- 50–69%:  "Cày thêm tí nữa! Lần sau chắc hơn 🎯"
- <50%:    "Đừng nản! Trâu ngã còn đứng dậy được 📚"
