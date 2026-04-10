# BuffaloEdu — Mascot Prompt (Gemini Image Gen / Adobe Firefly)
> Mascot: **Bò** — Trâu Việt Nam đội nón lá, phong cách anime 2D cel-shaded, nam tính, đáng tin.
> Prompt đã được verify và approved bởi owner. Dùng nguyên xi, không tự ý chỉnh.

---

## Character Brief

| | |
|---|---|
| **Tên** | Bò |
| **Loài** | Asian water buffalo — Nam, mạnh mẽ, thân thiện |
| **Phong cách** | 2D anime cel-shaded, nón lá Việt Nam |
| **Outfit** | Áo sơ mi trắng tay ngắn + quần kaki đen (variant 1) · Navy jacket teal cuffs (variant 2) |
| **Tagline** | *"Cày thôi!"* |

---

## Color Tokens — LOCKED

```json
COLOR_TOKENS
{
  "body":       "#6B4F3A",
  "face":       "#83604B",
  "belly":      "#C9BDB0",
  "horns":      "#3D3530",
  "horn_tips":  "#DCD0B8",
  "nose":       "#2A1A0A",
  "eye_iris":   "#6A4224",
  "eye_ring":   "#D4A44C",
  "nonla":      "#F5E6C8",
  "ribbon":     "#4A7C59",
  "shirt":      "#FFFFFF",
  "pants":      "#101010",
  "patch":      "#0D9B8A",
  "jacket":     "#1B2F4E",
  "cuffs":      "#0D9B8A"
}
```

---

## ⚙️ Tool Settings

### Gemini Image Gen (AI Studio)
```
Model:   Imagen 3
Format:  PNG transparent
Style:   Illustration / Graphic
```

### Adobe Firefly (fallback)
```
Style:          Illustration
Content type:   Graphic
Color profile:  MUTED  ← BẮT BUỘC, KHÔNG chọn Vibrant
Lighting:       Flat
Aspect ratio:   2:3 cho hero · 1:1 cho medium
```

---

## BASE PROMPT — Paste trước, rồi thêm POSE block bên dưới

### Outfit Variant A — Sơ mi trắng + kaki đen (casual, thân thiện)

```
Create a single 2D anime cel-shaded mascot character named "Bò" (Vietnamese water buffalo) per EXACT constraints below.

MANDATORY CHARACTER:
- Species: Male Asian water buffalo (clearly NOT a dairy cow).
- Anatomy: humanoid proportions, exactly 2 arms and 2 legs, broad shoulders, slightly muscular yet cute/approachable.
- Face: large anime eyes, iris #6A4224, amber highlight ring #D4A44C, thick black pupils, two white catchlights top-right, minimal masculine top lashes.
- Nose: wide flat buffalo nose #2A1A0A with visible nostrils.
- Horns: short gently curved horns #3D3530 with ivory tips #DCD0B8.
- Hat: Vietnamese nón lá #F5E6C8 (woven bamboo texture) with ribbon #4A7C59, sits proportionally between horns (MANDATORY).
- Outfit: white short-sleeve button-up shirt, sleeves rolled once, small teal "B" patch on left chest (#0D9B8A), black khaki pants (kaki đen) clean straight fit; tail fits naturally with pants.
- Palette (use exactly):
  body #6B4F3A, face #83604B, belly #C9BDB0,
  horns #3D3530, horn_tips #DCD0B8, nose #2A1A0A,
  eye_iris #6A4224, eye_ring #D4A44C,
  nonla #F5E6C8, ribbon #4A7C59,
  shirt #FFFFFF, pants #101010, patch #0D9B8A.

RENDERING RULES:
- Style: 2D anime, cel-shaded, clean bold black outlines (variable weight).
- Colors: flat fills, max 2-tone shading per color zone.
- Lighting: Flat. Color profile: MUTED (NO neon).
- Format: transparent PNG, no ground shadow, no background scenery, single character per image.
- Forbidden: realistic fur, 3D/CGI, photorealistic, neon/oversaturated colors, purple/violet,
  dairy cow features, extra limbs, missing horns or nón lá, hat floating detached,
  chibi deform, text/watermark, multiple characters.

[APPEND POSE BLOCK HERE]
```

### Outfit Variant B — Navy jacket + teal cuffs (formal, dashboard/hero)

```
Create a single 2D anime cel-shaded mascot character named "Bò" (Vietnamese water buffalo) per EXACT constraints below.

MANDATORY CHARACTER:
- Species: Male Asian water buffalo (clearly NOT a dairy cow).
- Anatomy: humanoid proportions, exactly 2 arms and 2 legs, broad shoulders, slightly muscular yet cute/approachable.
- Face: large anime eyes, iris #6A4224, amber highlight ring #D4A44C, thick black pupils, two white catchlights top-right, minimal masculine top lashes.
- Nose: wide flat buffalo nose #2A1A0A with visible nostrils.
- Horns: short gently curved horns #3D3530 with ivory tips #DCD0B8.
- Hat: Vietnamese nón lá #F5E6C8 (woven bamboo texture) with ribbon #4A7C59, sits proportionally between horns (MANDATORY).
- Outfit: navy zip jacket #1B2F4E with teal cuffs #0D9B8A, small teal "B" patch on left chest, short stubby dark-grey tail visible when full-body.
- Palette (use exactly):
  body #6B4F3A, face #83604B, belly #C9BDB0,
  horns #3D3530, horn_tips #DCD0B8, nose #2A1A0A,
  eye_iris #6A4224, eye_ring #D4A44C,
  nonla #F5E6C8, ribbon #4A7C59,
  jacket #1B2F4E, cuffs #0D9B8A.

RENDERING RULES:
- Style: 2D anime, cel-shaded, clean bold black outlines (variable weight).
- Colors: flat fills, max 2-tone shading per color zone.
- Lighting: Flat. Color profile: MUTED (NO neon).
- Format: transparent PNG, no ground shadow, no background scenery, single character per image.
- Forbidden: realistic fur, 3D/CGI, photorealistic, neon/oversaturated colors, purple/violet,
  dairy cow features, extra limbs, missing horns or nón lá, hat floating detached,
  chibi deform, text/watermark, multiple characters.

[APPEND POSE BLOCK HERE]
```

---

## POSE BLOCKS — Append vào cuối Base Prompt

### HAPPY / IDLE
```
POSE — HAPPY / IDLE:
Standing upright, one hoof raised in casual friendly wave toward viewer,
gentle closed smile, nón lá sitting slightly tilted between horns.
Crop: upper-body to waist.
Orientation: 3/4 toward viewer.

OUTPUT:
- bo-happy-hero.png    (2:3 ratio, 240×360px)
- bo-happy-medium.png  (1:1 ratio, 120×120px)
- bo-happy-small.png   (64×64px simplified icon, clean readable at small size)
```

### CELEBRATING
```
POSE — CELEBRATING:
Full body jumping with both arms thrust upward in V-shape victory,
nón lá tossed above head floating in air,
eyes squinted shut with joy, open mouth huge grin showing teeth,
confetti in teal / navy / white / gold colors around body.

OUTPUT:
- bo-celebrating-hero.png    (2:3)
- bo-celebrating-medium.png  (1:1)
```

### THINKING
```
POSE — THINKING:
Sitting cross-legged, one hoof hand raised to chin in thinking gesture,
head tilted ~12 degrees left, eyes looking upward-right, single eyebrow raised,
small question mark floating near top of nón lá.
Crop: upper-body.

OUTPUT:
- bo-thinking-medium.png  (1:1)
- bo-thinking-small.png   (64×64px simplified icon)
```

### SAD
```
POSE — SAD:
Full body with heavily slumped posture, shoulders drooping forward,
arms hanging loose at sides, eyes half-closed looking down,
nón lá drooped forward partially covering upper face,
single small teardrop on left cheek, small downward frown.

OUTPUT:
- bo-sad-hero.png    (2:3)
- bo-sad-medium.png  (1:1)
```

### ENCOURAGING
```
POSE — ENCOURAGING:
Upper-body crop, strong forward lean toward viewer,
both thumbs-up pointing at viewer energetically,
wide bright eyes with raised eyebrows, big confident closed-mouth smile,
nón lá straight and proud on head.

OUTPUT:
- bo-encouraging-hero.png    (2:3)
- bo-encouraging-medium.png  (1:1)
```

### PROUD
```
POSE — PROUD:
Full body standing tall, chest puffed outward,
arms crossed confidently across chest,
confident closed-mouth smile with single eyebrow slightly raised,
nón lá perfectly straight and centered, worn with pride.

OUTPUT:
- bo-proud-hero.png    (2:3)
- bo-proud-medium.png  (1:1)
```

### STREAK FIRE
```
POSE — STREAK FIRE:
Full body leaning forward with excitement,
both cupped hoof hands cradling a small cartoon flame (amber #F59E0B with tiny happy face),
eyes reflecting warm amber glow from flame, excited closed grin,
nón lá glowing slightly from flame light.

OUTPUT:
- bo-streak-fire-medium.png  (1:1)
```

### PERFECT SCORE
```
POSE — PERFECT SCORE:
Full body maximum energy hero pose,
one fist punching straight upward powerfully,
other arm spread wide at shoulder height,
eyes squinted completely shut with peak joy, huge open grin,
nón lá launched spinning high above head,
gold star burst radiating from behind,
confetti explosion in teal / orange / white / gold.

OUTPUT:
- bo-perfect-score-hero.png  (2:3)
```

### ERROR / OFFLINE
```
POSE — ERROR / OFFLINE:
Sitting on ground, legs stretched out,
one horn used as chin rest in confused gesture,
both hoof hands holding a broken wifi signal icon,
nón lá tilted awkwardly to one side,
sympathetic confused expression.

OUTPUT:
- bo-error-medium.png  (1:1)
- bo-error-small.png   (64×64px simplified icon)
```

### SURPRISED
```
POSE — SURPRISED:
Upper-body crop, both hoof hands raised to cheeks (Home Alone style),
nón lá knocked sideways nearly falling off from shock,
eyes at extreme maximum wide size, mouth open in perfect O shape,
body recoiling slightly backward, eyebrows raised extremely high.

OUTPUT:
- bo-surprised-medium.png  (1:1)
- bo-surprised-micro.png   (32×32px simplified icon)
```

### SLEEPING
```
POSE — SLEEPING:
Full body curled up sitting, legs tucked under,
nón lá pulled completely down over eyes,
small ZZZ letters floating upward and fading above hat,
peaceful gentle smile visible below hat brim,
short tail curled around body.

OUTPUT:
- bo-sleeping-medium.png  (1:1)
```

---

## Output Contract — Required từ Gemini / Firefly

```
For EACH pose, produce:
1. Transparent PNG files — named exactly as specified above
2. Crisp clean edges suitable for use on any background
3. Correct aspect ratios (2:3 hero, 1:1 medium, 64×64 small, 32×32 micro)

After all images, output this JSON block exactly:

COLOR_TOKENS
{
  "body":      "#6B4F3A",
  "face":      "#83604B",
  "belly":     "#C9BDB0",
  "horns":     "#3D3530",
  "horn_tips": "#DCD0B8",
  "nose":      "#2A1A0A",
  "eye_iris":  "#6A4224",
  "eye_ring":  "#D4A44C",
  "nonla":     "#F5E6C8",
  "ribbon":    "#4A7C59",
  "shirt":     "#FFFFFF",
  "pants":     "#101010",
  "patch":     "#0D9B8A",
  "jacket":    "#1B2F4E",
  "cuffs":     "#0D9B8A"
}

Do not add extra commentary. Produce images and COLOR_TOKENS JSON only.
```

---

## Appearance Map — Dùng trong app

| Screen | Size | Pose | Outfit | Message |
|---|---|---|---|---|
| Onboarding bước 1 | Hero | happy | Variant A | *"Xin chào! Tao là Bò, cùng cày thôi! 🐃"* |
| Dashboard hero banner | Hero | happy | Variant B | Hiển thị cùng tagline |
| Result 90–100% | Hero | celebrating | Variant B | *"Đỉnh của chóp! Bò tự hào về mày 🌟"* |
| Result 70–89% | Hero | proud | Variant B | *"Làm tốt lắm! Trâu cày không bỏ cuộc 💪"* |
| Result 50–69% | Medium | encouraging | Variant A | *"Cày thêm tí nữa! Lần sau chắc hơn 🎯"* |
| Result < 50% | Medium | sad | Variant A | *"Đừng nản! Trâu ngã còn đứng dậy được 📚"* |
| Empty states | Medium | thinking | Variant A | (xem bảng empty states) |
| Streak active | Medium | streak-fire | Variant B | *"Bò đang giữ lửa! Đừng để tắt nhé."* |
| Perfect score | Hero | perfect-score | Variant B | *"100 điểm! Bò bái phục! 🏆"* |
| 404 | Medium | sleeping | Variant A | *"Trang này đang nghỉ trưa... 😴"* |
| Server error | Small | sad | Variant A | *"Bò đang sửa máy cày, thử lại sau!"* |
| Offline | Small | error | Variant A | *"Mất kết nối rồi. Kiểm tra mạng đi!"* |
| Timer 5 min | Micro | thinking | — | Amber, pulse animation |
| Timer 1 min | Micro | surprised | — | Red flash animation |

### Empty state messages
| Screen | Message |
|---|---|
| No questions | *"Chưa có câu hỏi. Tạo câu hỏi đầu tiên đi!"* |
| No exams | *"Chưa có đề thi. Bắt đầu tạo đề thôi!"* |
| No results | *"Chưa có kết quả. Học sinh chưa làm bài."* |
| No students | *"Lớp học trống. Mời học sinh tham gia nhé!"* |
| Search empty | *"Bò tìm mãi không thấy 🔍 Thử từ khác đi!"* |

---

## File Naming Convention

```
bo-happy-hero.png             bo-happy-medium.png         bo-happy-small.png
bo-celebrating-hero.png       bo-celebrating-medium.png
bo-thinking-medium.png        bo-thinking-small.png
bo-sad-hero.png               bo-sad-medium.png
bo-encouraging-hero.png       bo-encouraging-medium.png
bo-proud-hero.png             bo-proud-medium.png
bo-streak-fire-medium.png
bo-perfect-score-hero.png
bo-error-medium.png           bo-error-small.png
bo-surprised-medium.png       bo-surprised-micro.png
bo-sleeping-medium.png
```

---

## Đặt file vào project

```
frontend/public/mascot/
└── bo-[pose]-[size].png
```

Sau đó thêm vào đầu session Stitch / AI Studio:
```
MASCOT: Bò — Vietnamese Water Buffalo. App: BuffaloEdu.
Assets in /public/mascot/bo-[pose]-[size].png — DO NOT regenerate.
Two outfit variants:
  Variant A (casual): white shirt + black khaki pants
  Variant B (formal): navy jacket #1B2F4E + teal cuffs #0D9B8A
Color tokens: body #6B4F3A, face #83604B, nonla #F5E6C8, jacket #1B2F4E, cuffs #0D9B8A.
```

---

## Cập nhật các file liên quan

### 02-design.md
```diff
- Flexi the Fox 🦊
+ Bò the Buffalo 🐃 (Vietnamese water buffalo, non la hat, anime 2D)
- body: #C94E0A (orange fox)
+ body: #6B4F3A (brown buffalo)
- flexi-[pose]-[size].png
+ bo-[pose]-[size].png
```

### 03-frontend.md
```diff
- FlexiCharacter.tsx
+ BoCharacter.tsx

interface BoProps {
  pose: 'happy' | 'celebrating' | 'thinking' | 'sad' | 'encouraging' |
        'proud' | 'streak-fire' | 'perfect-score' | 'error' | 'surprised' | 'sleeping'
  size: 'hero' | 'medium' | 'small' | 'micro'
  outfit?: 'variant-a' | 'variant-b'  // ← NEW: 2 outfit variants
  message?: string
  animate?: boolean
}

// Non la hat = separate Framer Motion layer:
// celebrating  → hat launches Y -60px, spins 360deg, falls back
// surprised    → hat tilts 35deg rapidly spring
// sleeping     → hat slides down Y +20px over eyes
// idle         → hat sways ±3deg loop 4s ease-in-out
```

---

## Troubleshooting

| Vấn đề | Fix |
|---|---|
| Màu fur quá sáng / không đúng | Dùng exact hex `#6B4F3A`, Color profile: **Muted** |
| Trông như bò sữa | Thêm: "Asian water buffalo NOT dairy cow, curved short horns" |
| Thiếu nón lá | Thêm: "Vietnamese non la conical hat MANDATORY between horns" |
| Nón lá lơ lửng / không đội | Thêm: "hat sits firmly on head proportionally between the two horns" |
| Outfit sai | Chỉ rõ: Variant A = "white shirt black khaki pants" / Variant B = "navy jacket teal cuffs" |
| Trông hung hăng | Thêm: "friendly approachable anime expression, NOT fierce or aggressive" |
| Sừng quá dài / sai | Thêm: "short gently curved buffalo horns NOT long straight horns" |
| Màu bị neon | Firefly: Color profile **Muted** · Gemini: thêm "MUTED colors no neon" |
| Ra nhiều nhân vật | Thêm: "single character only, one buffalo, no duplicates" |
