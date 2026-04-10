# /bootstrap — Scaffold new module

Scaffold a new backend service OR frontend MFE following BuffaloEdu conventions.

## Usage
```
/bootstrap service <name>      → new Go microservice
/bootstrap mfe <name>          → new Next.js MFE remote
/bootstrap proto <name>        → new .proto file only
```

## Instructions

Read `overview/rules.md` and `overview/tasks.md` before generating anything.

---

### If `service <name>`:

Read `.claude/skills/go-service/SKILL.md` for the full template.

Generate these files for `services/<name>/`:
```
cmd/main.go
internal/handler/<name>_handler.go
internal/service/<name>_service.go
internal/repository/<name>_repository.go
internal/middleware/metrics.go
internal/middleware/auth.go
config/config.go
migrations/001_init.up.sql
migrations/001_init.down.sql
Dockerfile
.env.example
README.md
```

Rules:
- Port: assign next available (check existing services in docker-compose.yml)
- gRPC port: REST port + 1000 (e.g. REST 8009 → gRPC 9009)
- Must include `healthz` RPC
- Must include Prometheus metrics interceptor
- Must follow handler → service → repository layer separation
- Add service to `docker-compose.yml` with correct network labels
- Add Traefik labels only if service needs public exposure
- Add Prometheus scrape target to `infra/prometheus/prometheus.yml`

---

### If `mfe <name>`:

Read `.claude/skills/mfe-scaffold/SKILL.md` for the full template.

Generate these files for `frontend/mfe-<name>/`:
```
src/app/page.tsx
src/components/.gitkeep
src/hooks/.gitkeep
src/store/.gitkeep
src/api/.gitkeep
next.config.ts          (Module Federation remote config)
tailwind.config.ts      (extends shared tokens)
tsconfig.json           (extends root)
package.json
Dockerfile
.env.example
```

Rules:
- Port: assign next available (3001–3009 range)
- Expose pages via `remoteEntry.js`
- `tailwind.config.ts` must extend `../../shared/ui/tokens.json`
- Import design tokens from `../../shared/ui/tokens.css`
- Register remote in `shell-app/next.config.ts`
- Add to `docker-compose.yml` with internal Traefik labels only

---

### If `proto <name>`:

Generate `proto/<name>/v1/<name>.proto` with:
- `syntax = "proto3"`
- Package: `buffaloedu.<name>.v1`
- Service definition with CRUD RPCs + `healthz`
- All request/response message types
- Run `buf generate` after creation

---

## After scaffolding
Always end with:
1. List of all files created
2. Manual steps required (e.g. "Add JWT secret to .env.example")
3. Quality gate: run the appropriate build command
