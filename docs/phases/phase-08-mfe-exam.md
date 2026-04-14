# Phase 8 — mfe-exam (port 3003)

> Refs: `docs/shared/frontend-conventions.md` · `docs/shared/design-system.md` · `docs/shared/mascot.md`

## Pages

### CreateExamPage — 5-step stepper

**Step 1: Basic Info**
- title (required), subject, description
- duration_minutes (number input), max_attempts (1/2/3/Unlimited)
- React Hook Form + Zod validation

**Step 2: Select Questions**
- DataTable from question bank
- Filter sidebar: subject, difficulty (1-5 stars), type
- Checkbox select rows
- Hiển thị: tổng số selected / gợi ý count

**Step 3: Settings**
- `show_result_immediately` toggle
- `randomize_order` toggle
- `access_code` optional text input (auto-generate button)
- `pass_threshold` slider (default 50%)

**Step 4: Preview**
- Read-only student view của exam
- Hiển thị 1 question mẫu với options

**Step 5: Publish**
- Summary: tổng số câu, thời gian, settings
- "Xuất bản ngay" → POST /exams + POST /exams/{id}/publish
- Toast success → redirect /dashboard

**Stepper UI:** Animated slide indicator, step titles, progress bar.

---

### TakeExamPage — Layout

```tsx
<div className="flex h-screen overflow-hidden bg-background">
  {/* Left: question panel */}
  <div className="flex-1 overflow-y-auto p-6">
    <TimerWidget />
    <QuestionCard question={current} onSelect={handleAnswer} />
    <div className="flex justify-between mt-6">
      <Button variant="outline">← Câu trước</Button>
      <Button>Câu tiếp →</Button>
    </div>
  </div>
  {/* Right: navigator (hidden on mobile) */}
  <div className="w-64 border-l border-border p-4 hidden lg:block overflow-y-auto">
    <QuestionNavigator />
    <Button variant="danger" className="w-full mt-4" onClick={openSubmitModal}>
      Nộp bài
    </Button>
  </div>
</div>
```

**QuestionNavigator:**
- Grid của question numbers
- `unanswered` → `bg-muted text-muted-foreground`
- `answered` → `bg-primary text-primary-foreground`
- `flagged` → `bg-warning/20 text-warning border border-warning`
- `current` → `ring-2 ring-primary font-bold`

**TimerWidget:**
```typescript
// useTimer hook — countdown từ duration_minutes
// normal (> 5min): text-foreground
// warning (≤ 5min): text-warning + pulse animation + Bò micro appears
// critical (≤ 1min): text-danger bg-danger/10 rounded-lg + flash animation
// Auto-submit khi = 0
```

**Auto-save:**
```typescript
// localStorage key: exam_progress_{submissionId}
// Save mỗi 30 giây + khi change answer
// Restore on page reload
```

**Submit Modal:**
- Tổng: answered / total / flagged
- Confirm button → POST /submissions/finalize → redirect /exams/{id}/result

---

### ResultPage

**Score Circle (SVG):**
```tsx
// 120×120px SVG ring
// Background ring: stroke-muted strokeWidth=8
// Progress ring: animated dashoffset 0→final, 1200ms ease-out
// Color theo score: success/primary/warning/danger
```

**Bò (score-based, xem mascot.md):**
```typescript
// 90–100%: celebrating, variant-b, "Đỉnh của chóp! Bò tự hào về mày 🌟"
// 70–89%:  proud,       variant-b, "Làm tốt lắm! Trâu cày không bỏ cuộc 💪"
// 50–69%:  encouraging, variant-a, "Cày thêm tí nữa! Lần sau chắc hơn 🎯"
// <50%:    sad,         variant-a, "Đừng nản! Trâu ngã còn đứng dậy được 📚"
```

**Stats row:** time taken · correct / total · score %

**Per-question Accordion:**
- ✓ correct (border-success bg-success/10)
- ✗ wrong (border-danger bg-danger/10) + hiện correct answer
- — skipped (border-muted)

**Export PDF button:** stub → toast "Đang chuẩn bị bản in..."

---

## Quality Gate

```bash
cd frontend/mfe-exam && next build   # 0 errors
# Verify: timer countdown + warning/critical states
# Verify: auto-save to localStorage every 30s
# Verify: score ring animates on mount
# Verify: Bò shows correct pose for all 4 score ranges
# Verify: dark mode correct
# Verify: 375px mobile layout (navigator as bottom drawer)
```
