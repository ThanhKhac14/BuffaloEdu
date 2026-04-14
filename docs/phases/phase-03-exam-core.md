# Phase 3 — Exam Core Services (Backend)

> Refs: `docs/shared/backend-conventions.md` · `docs/shared/architecture.md`

## Mục tiêu

Build 5 services: `question-bank`, `exam`, `submission`, `result`, `notification`.

---

## question-bank service (:8004 / gRPC :9004)

**gRPC methods:** `CreateQuestion`, `GetQuestion`, `UpdateQuestion`, `DeleteQuestion`, `ListQuestions`, `SearchQuestions`, `BulkImport`, `Healthz`

**Question types:** `multiple_choice` · `true_false` · `short_answer`

**Fields:**
```
id, content, options (JSONB), correct_answer,
difficulty (1-5), subject, tags[], created_by,
created_at, updated_at, deleted_at
```

**SearchQuestions:** full-text search trên `content`, filter theo `subject`, `difficulty`, `tags`, `type`.

**BulkImport:** nhận CSV, parse, validate, insert nhiều questions trong 1 transaction.

---

## exam service (:8005 / gRPC :9005)

**gRPC methods:** `CreateExam`, `PublishExam`, `GetExam`, `ListExams`, `UpdateExam`, `DeleteExam`, `RandomizeQuestions`, `Healthz`

**RandomizeQuestions:**
- Input: `subject`, `difficulty`, `tags`, `count`
- Output: N questions ngẫu nhiên từ question-bank khớp filters

**Redis caching:**
```go
// Cache published exam
key := fmt.Sprintf("exam:published:%s", examID)
// TTL: 10 minutes
// Invalidate khi exam được update hoặc unpublish
```

**Fields:** `title`, `description`, `duration_minutes`, `max_attempts`, `show_result_immediately`, `access_code` (optional), `status` (draft/published/archived)

---

## submission service (:8006 / gRPC :9006)

**gRPC methods:** `StartSubmission`, `SubmitAnswer`, `FinalizeSubmission`, `GetSubmission`, `Healthz`

**Auto-grading logic (trong FinalizeSubmission):**
```go
// So sánh submitted_answers với correct_answers từ exam
// score = (correct_count / total_questions) * 100
// passed = score >= exam.pass_threshold (default 50%)
```

**RabbitMQ publish (sau khi FinalizeSubmission):**
```go
// Exchange: buffaloedu.events
// Routing key: submission.completed
// Payload:
type SubmissionEvent struct {
    SubmissionID string  `json:"submission_id"`
    StudentID    string  `json:"student_id"`
    ExamID       string  `json:"exam_id"`
    Score        float64 `json:"score"`
    Passed       bool    `json:"passed"`
}
```

---

## result service (:8007 / gRPC :9007)

**gRPC methods:** `GetResult`, `ListResultsByStudent`, `ListResultsByExam`, `GenerateReport`, `GetClassPerformance`, `Healthz`

**Stores:**
```
score (float), percentage (float), passed (bool),
time_taken_seconds (int), per_question (JSONB),
student_id, exam_id, submission_id
```

**GetClassPerformance:** aggregate stats — avg score, pass rate, score distribution (histogram).

---

## notification service (:8008 — NO gRPC)

**Role:** RabbitMQ consumer only — KHÔNG có gRPC server.

**Queue config:**
```go
// Exchange: buffaloedu.events (type: direct)
// Queue: buffaloedu.notification.queue
// Binding: routing key submission.completed
```

**Current behavior (stub):** Structured log khi nhận event.
**Future:** Email · WebSocket · Push notification.

**KHÔNG có REST endpoint hoặc gRPC server.**

---

## Quality Gate

```bash
go build ./...
docker-compose build question-bank exam submission result notification
```
