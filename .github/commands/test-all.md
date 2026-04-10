# /test-all — Execute full test suite

Run all tests across backend and frontend for BuffaloEdu.

## Instructions

### Backend tests
```bash
# Unit tests with race detection
go test ./services/... -race -v -coverprofile=coverage.out

# Show coverage per service
go tool cover -func=coverage.out | grep -E "^(ok|FAIL|services)"

# Vet
go vet ./services/...
```

Expected: all services pass, coverage > 60% per service

### Proto validation
```bash
cd proto
buf lint
buf breaking --against '.git#branch=main'
```

### Frontend tests
```bash
# Type checking
cd frontend/shell-app && npx tsc --noEmit
cd frontend/mfe-auth && npx tsc --noEmit
cd frontend/mfe-dashboard && npx tsc --noEmit
cd frontend/mfe-exam && npx tsc --noEmit
cd frontend/mfe-question && npx tsc --noEmit
cd frontend/mfe-reports && npx tsc --noEmit

# Lint
cd frontend && npx eslint "**/*.{ts,tsx}" --max-warnings 0

# Build (catches all remaining errors)
for app in shell-app mfe-auth mfe-dashboard mfe-exam mfe-question mfe-reports; do
  cd frontend/$app && next build
done
```

### k6 dry-run
```bash
k6 run --dry-run k6/scripts/login.js
k6 run --dry-run k6/scripts/submit_exam.js
k6 run --dry-run k6/scripts/fetch_result.js
k6 run --dry-run k6/scripts/question_bank.js
```

### Docker validation
```bash
docker-compose config
buf generate  # ensure stubs are fresh
```

## Output format
```
Backend:  ✅ PASS / ❌ FAIL (N errors)
Proto:    ✅ PASS / ❌ FAIL
Frontend: ✅ PASS / ❌ FAIL (N warnings)
k6:       ✅ PASS / ❌ FAIL
Docker:   ✅ PASS / ❌ FAIL

Overall: READY TO DEPLOY / NEEDS FIXES
```

List all failures with file + line number.
