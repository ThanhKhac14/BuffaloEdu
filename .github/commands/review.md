# /review — Code Review

Run a thorough code review on the current diff or specified files.

## Instructions

Read `overview/rules.md` before reviewing. Check against ALL rules there.

Review the following (in order):

### 1. Architecture violations
- Go services: business logic in handler layer? (must be in service layer)
- SQL in service layer? (must be in repository layer)
- Shared DB between services? (forbidden)
- gRPC ports exposed publicly in docker-compose? (forbidden)

### 2. Code quality
- Any `any` type in Go or TypeScript?
- Unused imports or variables?
- Hardcoded hex colors in frontend components?
- Inline `style={{}}` for colors/spacing?
- Missing `"use client"` on components that need it?
- Server components incorrectly using hooks or event handlers?

### 3. Security
- Secrets in code (not in env)?
- JWT validation missing on protected routes?
- SQL injection risk (string concatenation in queries)?
- Missing input validation (Zod schemas on frontend, validation in Go handlers)?

### 4. Performance
- Missing Redis cache where specified in tasks.md?
- Missing Prometheus metrics interceptor on new gRPC service?
- `useEffect` without cleanup for intervals/subscriptions?
- Missing loading states (skeleton shown within 150ms)?

### 5. Consistency
- File naming: kebab-case.tsx for frontend, snake_case.go for backend?
- Component naming: PascalCase?
- Import order correct (React/Next → external → components → lib → types)?

### 6. Quality gate
- Run `go build ./...` if Go files changed
- Run `next build` if frontend files changed
- Run `buf lint` if .proto files changed

## Output format
List issues as:
- 🔴 CRITICAL — must fix before merge
- 🟡 WARNING — should fix
- 🟢 SUGGESTION — optional improvement

End with: "Ready to merge" or "Needs fixes: N critical, N warnings"
