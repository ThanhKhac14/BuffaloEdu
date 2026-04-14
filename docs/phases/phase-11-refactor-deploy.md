# Phase 11 — Refactor + Docs + Deploy

## 11.1 — Frontend Code Audit

```bash
# Tìm unused imports
npx eslint "frontend/**/*.{ts,tsx}" --rule '{"no-unused-vars": "error"}'

# Tìm any types
grep -rn ": any\|as any" frontend/src --include="*.ts" --include="*.tsx"

# Tìm hardcoded hex
grep -rE "#[0-9a-fA-F]{3,6}" frontend/src --include="*.tsx" --include="*.ts"

# Files > 150 lines
find frontend/src -name "*.tsx" | xargs wc -l | awk '$1 > 150 {print}'
```

**Rules:**
- File > 150 lines → split thành smaller components
- Pattern dùng 3+ lần → extract thành `shared/ui/` component
- Consistent naming: `kebab-case.tsx` files, `PascalCase` components

## 11.2 — Backend Code Audit

```bash
go vet ./...            # 0 warnings
go build ./...          # 0 errors

# Tìm debug logs
grep -rn 'fmt.Println\|log.Printf\|fmt.Printf' services/ --include="*.go"

# Verify migrations có down.sql
for f in services/*/migrations/*.up.sql; do
  down="${f/.up.sql/.down.sql}"
  [ -f "$down" ] || echo "MISSING: $down"
done
```

## 11.3 — Final Builds

```bash
# Backend
go build ./...          # 0 errors
go vet ./...            # 0 warnings
buf lint                # 0 errors

# Frontend (tất cả 6 apps)
for app in shell-app mfe-auth mfe-dashboard mfe-exam mfe-question mfe-reports; do
  echo "Building $app..."
  cd frontend/$app && next build && cd ../..
done

# Docker
docker-compose build    # 0 failures
docker-compose config   # valid YAML
```

## 11.4 — Root README.md

Sections bắt buộc:

1. **Project overview** — BuffaloEdu là gì, Bò mascot, tech stack badges
2. **Architecture diagram** (Mermaid) — all services + Traefik + MFEs + RabbitMQ + Redis
3. **Prerequisites** — Go 1.22+ · Node 20+ · Docker · buf CLI · k6
4. **Quick start** — 4 commands: clone → buf generate → cp .env → docker-compose up
5. **Service catalogue** — service · port · gRPC port · chức năng
6. **MFE catalogue** — app · port · routes · owns
7. **How to add new backend service** — 7 steps
8. **How to add new MFE** — 5 steps
9. **Environment variables** — full table với description
10. **Monitoring** — Grafana URL, dashboards list, credentials

## 11.5 — Deploy Checklist

```
[ ] All builds pass (0 errors)
[ ] Dark mode tested on all screens
[ ] Mobile layout tested at 375px
[ ] New env variables added to .env.example
[ ] New services added to prometheus.yml scrape config
[ ] New public routes added to Traefik labels
[ ] Migration files exist for all DB changes (.up + .down)
[ ] k6 thresholds pass against staging
[ ] Security scan passes (Trivy CVE check)
[ ] Production manual approval configured in GitHub Environments
```

## 11.6 — Final Summary (print sau khi xong)

```
Total Go services:   9
Total MFE apps:      6 (+ shell)
Total API routes:    ~45
Total components:    ~60
Proto services:      8
k6 scripts:          4
GitHub Actions:      7
```
