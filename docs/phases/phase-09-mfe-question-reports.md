# Phase 9 — mfe-question + mfe-reports

> Refs: `docs/shared/frontend-conventions.md` · `docs/shared/design-system.md` · `docs/shared/mascot.md`

## mfe-question (port 3004)

### QuestionBankPage

**Layout:** Left filter sidebar (w-64) + right data table (flex-1)

**Filter Sidebar:**
- Subject chips (multi-select)
- Difficulty: 1–5 star toggle buttons
- Type: segmented — Multiple Choice / True False / Short Answer
- Tags: text input with suggestion dropdown
- "Reset filters" link

**DataTable:**

| Column | Sortable | |
|---|---|---|
| # | — | Row number |
| Nội dung | — | Truncated content preview |
| Môn học | ✓ | Subject |
| Độ khó | ✓ | 1–5 stars display |
| Loại | — | Badge |
| Ngày tạo | ✓ | Relative date |
| Actions | — | Edit / Delete icons |

- Bulk select (checkbox column)
- Pagination (10/20/50 per page)
- Empty state: Bò thinking + CTA "Thêm câu hỏi đầu tiên"

**"+ Thêm câu hỏi" FAB:** Fixed bottom-right → opens right drawer

**CreateQuestionForm (right drawer):**
- Framer Motion: `translateX 100%→0`, 400ms ease-out
- Type segmented control (3 types)
- Content textarea (min 3 rows)
- Options A/B/C/D (chỉ hiện khi multiple_choice)
- Correct answer selector
- Difficulty stars (1-5, clickable)
- Subject input + Tags input (comma separated)
- Submit → POST /questions → toast success → close drawer → refetch table

---

## mfe-reports (port 3005)

### ReportsPage

**Filter Bar (React Hook Form):**
- Class selector (dropdown)
- Exam selector (dropdown)
- Date range picker (from/to)
- "Áp dụng" button

**Stat Cards (4 cards):**
- Điểm trung bình · Tỷ lệ pass · Tỷ lệ hoàn thành · Tổng bài nộp
- `useCountUp` trên tất cả numbers
- Skeleton 600ms trên mount

**Charts (Recharts):**
- Area chart: score trend over time (fill primary/20)
- Bar chart: score distribution by 10-point buckets

**DataTable — Per Student:**

| Column | |
|---|---|
| Học sinh | Avatar + name |
| Điểm | Numeric + color (success/warning/danger) |
| Thời gian làm | mm:ss |
| Kết quả | Pass/Fail badge |
| Ngày nộp | Relative |

- Export CSV button → stub toast
- Empty state: Bò thinking, message "Chưa có kết quả. Học sinh chưa làm bài."

---

### AchievementsPage

**StreakCard:**
```tsx
// amber background: bg-secondary/10 border border-secondary/30
// Bò: pose=streak-fire, outfit=variant-b, size=medium
// Message: "Bò đang giữ lửa! Đừng để tắt nhé."
// Streak count: text-4xl font-bold text-secondary
// Flame flicker: Framer Motion scale 1→1.05→1, 0.8s loop
```

**XP Progress Bar:**
```tsx
// Spring animation on mount: fill 0→current%, overshoot
// transition: { type: 'spring', stiffness: 50, damping: 15 }
// Color: bg-primary with gradient
// Label: current XP / next level XP
```

**Badge Grid:**
- Earned: full color + `shadow-md` on hover + scale 1.05
- Locked: `grayscale opacity-50` + lock icon overlay + tooltip "Cần X ngày streak"

**Milestone Timeline:**
```
○────●────●────○────○
1d  7d  30d  60d 100d
          ↑
     Bò celebrating appears at reached milestones
```

---

## Quality Gate

```bash
cd frontend/mfe-question && next build   # 0 errors
cd frontend/mfe-reports  && next build   # 0 errors
# Verify: drawer slide animation smooth
# Verify: charts render correctly in light + dark
# Verify: Bò empty states appear với correct messages
# Verify: XP bar spring animation
# Verify: 375px mobile layout
```
