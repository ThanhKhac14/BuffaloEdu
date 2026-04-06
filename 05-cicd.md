# Learnify — CI/CD Prompt (GitHub Actions)
> Dùng trong GitHub Copilot Agent mode (@workspace).
> Scaffold toàn bộ GitHub Actions workflows cho monorepo Learnify.

---

```
# CI/CD SCAFFOLD — Learnify GitHub Actions

## Role
You are a senior DevOps engineer. Scaffold complete GitHub Actions CI/CD pipelines
for the Learnify monorepo. Follow every constraint exactly.

---

## Repository Structure (monorepo)
```
learnify/
├── services/
│   ├── gateway/
│   ├── auth/
│   ├── user/
│   ├── profile/
│   ├── question-bank/
│   ├── exam/
│   ├── submission/
│   ├── result/
│   └── notification/
├── frontend/
│   ├── shell-app/
│   ├── mfe-auth/
│   ├── mfe-dashboard/
│   ├── mfe-exam/
│   ├── mfe-question/
│   └── mfe-reports/
├── proto/
├── infra/
└── .github/workflows/
```

---

## Workflows to Generate

### 1. proto-validate.yml
Trigger: PR → any change in proto/**
Steps:
- Checkout
- Install buf CLI
- buf lint
- buf breaking (against main branch)
- Comment on PR if breaking changes detected

### 2. backend-ci.yml
Trigger: PR + push to main → changes in services/**

Jobs (run in parallel per service, use matrix strategy):
```yaml
strategy:
  matrix:
    service: [gateway, auth, user, profile, question-bank, exam, submission, result, notification]
```

Steps per service:
- Checkout
- Setup Go 1.22
- Cache Go modules
- go mod download
- go vet ./...
- golangci-lint run
- go test ./... -race -coverprofile=coverage.out
- Upload coverage to Codecov (optional)
- If tests pass → docker/build-push-action (build only on PR, build+push on main)

Docker image naming:
```
ghcr.io/{org}/learnify-{service}:{sha}
ghcr.io/{org}/learnify-{service}:latest (main only)
```

### 3. frontend-ci.yml
Trigger: PR + push to main → changes in frontend/**

Jobs (parallel matrix):
```yaml
matrix:
  app: [shell-app, mfe-auth, mfe-dashboard, mfe-exam, mfe-question, mfe-reports]
```

Steps per app:
- Checkout
- Setup Node 20
- Cache node_modules (key: ${{ hashFiles('**/package-lock.json') }})
- npm ci
- npm run type-check (tsc --noEmit)
- npm run lint (ESLint)
- npm run test (Jest + React Testing Library)
- npm run build
- If build passes → docker/build-push-action

Docker image naming:
```
ghcr.io/{org}/learnify-{app}:{sha}
ghcr.io/{org}/learnify-{app}:latest (main only)
```

### 4. deploy-staging.yml
Trigger: push to main (after backend-ci + frontend-ci pass)

Steps:
- Checkout
- SSH to staging server (using secrets.STAGING_SSH_KEY, secrets.STAGING_HOST)
- docker compose pull (pull new images)
- docker compose up -d --no-deps {changed services}
- Health check: curl https://staging.learnify.app/healthz (retry 5x, 10s interval)
- Post result to Slack (optional, use secrets.SLACK_WEBHOOK)

### 5. deploy-production.yml
Trigger: manual workflow_dispatch OR push to tag v*.*.*

Inputs (workflow_dispatch):
- environment: staging | production
- services: all | comma-separated list

Steps:
- Require approval (GitHub Environment protection rules)
- Checkout
- SSH to production server
- docker compose pull
- docker compose up -d (rolling — one service at a time)
- Health check per service
- Rollback on failure: docker compose up -d --no-deps {service}:previous-tag

### 6. performance-test.yml
Trigger: schedule (weekly, Sunday 2am UTC) OR manual dispatch

Steps:
- Checkout
- Setup k6
- Run k6 scripts against staging:
  - k6/scripts/login.js
  - k6/scripts/submit_exam.js
  - k6/scripts/fetch_result.js
  - k6/scripts/question_bank.js
- Upload k6 HTML report as artifact
- Fail workflow if p95 > 500ms or error_rate > 1%

### 7. security-scan.yml
Trigger: push to main + weekly schedule

Steps:
- Checkout
- Trivy: scan all Docker images for CRITICAL/HIGH CVEs
- Gosec: static security analysis for Go code
- npm audit: for all frontend apps
- Upload SARIF results to GitHub Security tab
- Fail on CRITICAL CVEs

---

## Shared GitHub Actions Config

### .github/workflows/reusable-docker-build.yml (reusable workflow)
```yaml
on:
  workflow_call:
    inputs:
      context: string          # Docker build context path
      image-name: string       # ghcr.io/org/learnify-{name}
      dockerfile: string       # Path to Dockerfile
    secrets:
      GHCR_TOKEN: required
```
Steps:
- Login to GitHub Container Registry (ghcr.io)
- docker/metadata-action (tags: sha, latest, semver)
- docker/build-push-action (cache from ghcr.io, push on main only)

---

## Secrets Required (document in README)
```
STAGING_SSH_KEY         Private key for staging server SSH
STAGING_HOST            staging.learnify.app
PRODUCTION_SSH_KEY      Private key for production server SSH
PRODUCTION_HOST         learnify.app
GHCR_TOKEN              GitHub token (auto: secrets.GITHUB_TOKEN)
SLACK_WEBHOOK           Slack webhook URL for deploy notifications (optional)
CODECOV_TOKEN           Codecov upload token (optional)
```

---

## GitHub Environments (set up in repo settings)
```
staging:
  - No approval required
  - Auto-deploy from main branch

production:
  - Required reviewers: 1 (team lead)
  - Deployment branches: main + v*.*.* tags
  - Environment secrets: PRODUCTION_SSH_KEY, PRODUCTION_HOST
```

---

## Branch Strategy
```
main        → auto-deploy to staging
v*.*.*      → manual-approve deploy to production
feature/*   → CI only (no deploy)
fix/*       → CI only
```

---

## Caching Strategy
```yaml
# Go modules
- uses: actions/cache@v4
  with:
    path: ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}

# Node modules
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

# Docker layers
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

---

## Constraints
- MUST use matrix strategy for parallel service builds (do not run sequentially)
- MUST cache dependencies in every workflow (Go modules, npm, Docker layers)
- MUST tag Docker images with both :sha and :latest
- MUST require manual approval for production deploy
- MUST run health check after every deploy before marking success
- MUST upload test artifacts (coverage, k6 report) even on failure
- NEVER store secrets in code — only via GitHub Secrets
- NEVER deploy to production from feature branches

---

## Execution Order
Phase 1: proto-validate.yml
Phase 2: backend-ci.yml + reusable-docker-build.yml
Phase 3: frontend-ci.yml
Phase 4: deploy-staging.yml
Phase 5: deploy-production.yml
Phase 6: performance-test.yml
Phase 7: security-scan.yml

Generate Phase 1 first, confirm, then proceed.
```
