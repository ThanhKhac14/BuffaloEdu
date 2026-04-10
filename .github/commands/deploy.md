# /deploy — Build & Deploy to staging

Build, verify, and prepare deployment for BuffaloEdu services.

## Usage
```
/deploy all              → build + verify all services
/deploy backend          → build all Go services
/deploy frontend         → build all MFE apps
/deploy <service-name>   → build specific service
```

## Instructions

### Step 1: Pre-deploy checks
- Verify no uncommitted changes in critical config files (docker-compose.yml, traefik.yml)
- Check `.env.example` has all required variables (no missing keys vs `.env`)
- Verify `CLAUDE.md` context is under 500 lines

### Step 2: Backend build (if applicable)
```bash
# Proto validation
cd proto && buf lint && buf generate

# Build all services
go build ./services/...

# Verify 0 errors
go vet ./services/...
```

### Step 3: Frontend build (if applicable)
```bash
# Build each MFE
cd frontend/shell-app && next build
cd frontend/mfe-auth && next build
cd frontend/mfe-dashboard && next build
cd frontend/mfe-exam && next build
cd frontend/mfe-question && next build
cd frontend/mfe-reports && next build
```

### Step 4: Docker build
```bash
docker-compose build
docker-compose config  # validate YAML
```

### Step 5: Deploy checklist
Print this checklist and verify each item:
- [ ] All builds pass (0 errors)
- [ ] Dark mode tested on changed screens
- [ ] Mobile layout tested at 375px
- [ ] New env variables added to `.env.example`
- [ ] New services added to `prometheus.yml` scrape config
- [ ] New public routes added to Traefik labels
- [ ] Migration files exist for DB changes

### Step 6: Output
Print deployment summary:
- Services built: N
- MFEs built: N
- Docker images ready: Y/N
- Blockers: (list any failed checks)
- Deploy command: `docker-compose up -d --build`
