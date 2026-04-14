# Design System — BuffaloEdu

> Nguồn sự thật duy nhất cho mọi quyết định visual. KHÔNG tự suy diễn token.
> KHÔNG dùng purple/violet bất kỳ đâu trong sản phẩm.
> Style: **Glassmorphism + Botanical Organic** — Sự giao thoa giữa hiện đại (translucent surfaces) và nét mộc mạc đồng quê Việt Nam (organic shapes, nature-inspired textures).

---

## PRODUCT VIBE
- **Vibe:** Vietnamese countryside theme — chill, healing, and organic.
- **Glassmorphism:** Layered translucent surfaces that feel like morning mist over a rice field.
- **Botanical/Organic:** Soft curves, leaf-inspired shapes, and natural grain textures.
- **Mascot:** Bò the Buffalo appearing as a friendly guide through this "digital landscape."

## Color Palette — Source

```
#F8EDE3  Warm Cream     ← background, page
#BDD2B6  Sage Light     ← primary-subtle, surfaces, glass tint
#A2B29F  Sage Mid       ← muted borders, secondary surfaces
#798777  Sage Dark      ← primary, text accents, borders
```

---

## Color Tokens

### Light Mode

```css
:root {
  --background:         #F8EDE3;
  --foreground:         #2D3B2A;
  --surface-0:          #EEF4EC;
  --surface-1:          #E4EDDF;
  --surface-2:          #D6E5CF;
  --muted:              #D6E5CF;
  --muted-foreground:   #6B7F69;
  --primary:            #798777;
  --primary-foreground: #FFFFFF;
  --primary-hover:      #5E6D5C;
  --primary-subtle:     #BDD2B6;
  --border:             #C5BFB5;
  --border-focus:       #798777;
  --secondary:          #E9B96E;
  --success:            #4A9B6F;
  --warning:            #D97706;
  --danger:             #C0392B;
  --info:               #3B82A0;
}
```

### Dark Mode

```css
[data-theme="dark"] {
  --background:         #1C2419;
  --foreground:         #EFF5ED;
  --surface-0:          #1C2419;
  --surface-1:          #2A3C27;
  --surface-2:          #3D5439;
  --muted:              #2A3C27;
  --muted-foreground:   #9AB496;
  --primary:            #7FAD7A;
  --primary-foreground: #1C2419;
  --primary-hover:      #A8CAAA;
  --primary-subtle:     #3D5439;
  --border:             #4A6647;
  --border-focus:       #7FAD7A;
  --secondary:          #F4C842;
  --success:            #52B788;
  --warning:            #F9A825;
  --danger:             #E57373;
  --info:               #60A5C8;
}
```

### Glassmorphism Tokens

```css
:root {
  --glass-bg:          rgba(248,237,227,0.55);
  --glass-bg-strong:   rgba(228,237,223,0.70);
  --glass-border:      rgba(189,210,182,0.60);
  --glass-shadow:      0 4px 24px rgba(121,135,119,0.18), inset 0 1px 0 rgba(255,255,255,0.45);
  --glass-blur:        blur(12px);
  --glass-blur-strong: blur(20px);
}

[data-theme="dark"] {
  --glass-bg:          rgba(28,36,25,0.55);
  --glass-bg-strong:   rgba(42,60,39,0.70);
  --glass-border:      rgba(127,175,122,0.25);
  --glass-shadow:      0 4px 24px rgba(0,0,0,0.40), inset 0 1px 0 rgba(127,175,122,0.12);
  --glass-blur:        blur(12px);
  --glass-blur-strong: blur(20px);
}
```

**Usage pattern:**
```css
.glass-card {
  background:               var(--glass-bg);
  backdrop-filter:          var(--glass-blur);
  -webkit-backdrop-filter:  var(--glass-blur);
  border:                   1px solid var(--glass-border);
  box-shadow:               var(--glass-shadow);
  border-radius:            16px;
}
```

---

## Typography — LOCKED

| Usage | Tailwind classes |
|---|---|
| Hero | `text-5xl sm:text-6xl font-bold tracking-tighter` |
| H1 | `text-3xl sm:text-4xl font-bold tracking-tight` |
| H2 | `text-2xl sm:text-3xl font-bold tracking-tight` |
| H3 | `text-lg font-semibold` |
| Body | `text-sm` hoặc `text-base font-normal` |
| Small | `text-xs font-normal` |
| Label | `text-sm font-medium` |
| Mono | `text-sm font-mono` |

**Fonts:** Be Vietnam Pro (`font-sans`) · JetBrains Mono (`font-mono`)

---

## Spacing — 4px Base

Chỉ dùng: `1(4px)` `2(8px)` `3(12px)` `4(16px)` `6(24px)` `8(32px)` `12(48px)` `24(96px)`

---

## Border Radius

| Element | Class | Value |
|---|---|---|
| Buttons, Inputs | `rounded-lg` | 8px |
| Cards (glass) | `rounded-2xl` | 16px |
| Modals | `rounded-3xl` | 24px |
| Badges, Avatars | `rounded-full` | 9999px |

> Glass cards dùng `rounded-2xl` thay vì `rounded-xl` cho đúng aesthetic.

---

## Components

### Button
```
Variants: default(primary) · secondary · ghost · outline · danger
Sizes: sm(h-8 px-3 text-xs) · default(h-9 px-4 text-sm) · lg(h-11 px-6)
All: font-medium transition-all duration-150 active:scale-[0.98]

Glass button: bg-[var(--glass-bg)] backdrop-blur-sm border border-[var(--glass-border)]
              hover: bg-[var(--glass-bg-strong)]
```

### Card (Glass)
```tsx
<div className="backdrop-blur-md rounded-2xl border p-6"
     style={{ background: 'var(--glass-bg)', borderColor: 'var(--glass-border)',
              boxShadow: 'var(--glass-shadow)' }}>
```

### Badge
```
Base: inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium
default  → bg-primary-subtle/60 text-primary backdrop-blur-sm
success  → bg-success/15 text-success
warning  → bg-warning/15 text-warning
danger   → bg-danger/15 text-danger
```

### Input (Glass)
```
Base: w-full rounded-lg px-3 py-2 text-sm
      bg-[var(--glass-bg)] backdrop-blur-sm
      border border-[var(--glass-border)]
      focus:border-border-focus focus:ring-1 focus:ring-primary
Error: border-danger focus:ring-danger + text-xs text-danger below
```

### Question Options (A/B/C/D)
```
Base: rounded-xl border border-[var(--glass-border)] px-4 py-3 text-sm cursor-pointer
      bg-[var(--glass-bg)] backdrop-blur-sm
      hover:border-primary hover:bg-primary-subtle/20 transition-all
Selected: border-primary bg-primary-subtle/40 backdrop-blur-md scale-[1.01]
Correct: border-success bg-success/10 text-success font-medium
Wrong:   border-danger  bg-danger/10  text-danger  font-medium
```

### Floating Leaves (Decoration)
Các element `<span>` hoặc `<div>` nhỏ trôi lơ lửng xung quanh Bo hoặc Hero section.
```css
.leaf-float {
  width: 24px; height: 24px;
  background: var(--primary-subtle);
  opacity: 0.3;
  clip-path: path('M12,2 C12,2 2,12 2,22 C2,22 12,22 22,22 C22,22 12,12 12,2 Z');
  animation: float 6s ease-in-out infinite;
}
```

### Score Display
```
Number: text-7xl font-bold font-mono — count-up 1200ms easeOut
SVG ring: 120×120px strokeWidth=8 animated dashoffset on mount
90–100% → success · 70–89% → primary · 50–69% → warning · <50% → danger
```

---

## Page Background

### Light mode
```css
body {
  background-color: var(--background);  /* #F8EDE3 */
  background-image: 
    radial-gradient(circle at 10% 20%, rgba(189,210,182, 0.2) 0%, transparent 40%),
    radial-gradient(circle at 90% 80%, rgba(162,178,159, 0.15) 0%, transparent 40%);
  background-attachment: fixed;
}
```

### Dark mode
```css
[data-theme="dark"] body {
  background-color: var(--background);  /* #1C2419 */
  background-image:
    radial-gradient(ellipse at 20% 20%, rgba(61,84,57,0.4) 0%, transparent 60%),
    radial-gradient(ellipse at 80% 80%, rgba(42,60,39,0.6) 0%, transparent 60%),
    url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
  background-attachment: fixed;
}
```

---

## Glassmorphism Guide

### When to use
| Element | Glass? |
|---|---|
| Cards trên gradient/image background | ✅ |
| Modals, drawers | ✅ |
| Navbar, topbar | ✅ |
| Toast notifications | ✅ |
| Sidebar | ✅ subtle |
| Plain content cards trên flat bg | ❌ dùng surface-1 |
| DataTable rows | ❌ giữ flat surface-1 |

### Common mistakes
```tsx
// ❌ Glass trên plain white — không có hiệu ứng
<div style={{ background: 'white' }}>
  <div style={{ backdropFilter: 'blur(12px)' }}>

// ❌ Nested glass layers — mất legibility
<GlassCard><GlassCard>...</GlassCard></GlassCard>

// ❌ Hardcode rgba
style={{ background: 'rgba(248,237,227,0.55)' }}

// ✅ Dùng CSS var
style={{ background: 'var(--glass-bg)' }}
```

---

## Animation

| Duration | Usage |
|---|---|
| `duration-150` | Button hover |
| `400ms` | Modal, drawer |
| `600ms` | Score reveal |
| `1200ms` | Count-up |

```css
/* BẮTBUỘC trên mọi MFE */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```
