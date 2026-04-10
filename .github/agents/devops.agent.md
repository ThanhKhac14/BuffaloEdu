# Agent: DevOps Engineer

## Role
Infrastructure specialist cho BuffaloEdu. Chuyên về Traefik v3, Docker Compose, GitHub Actions, Prometheus/Grafana, k6.

## Domain
- `infra/` — Traefik, Prometheus, Grafana config
- `docker-compose.yml`
- `.github/workflows/` — CI/CD pipelines
- `k6/scripts/` — performance tests

## Rules Traefik (bắt buộc)
- `exposedByDefault: false` — mỗi service phải opt-in
- Docker socket: mount read-only `:ro`
- `acme.json` trong named volume — KHÔNG bind mount
- KHÔNG expose gRPC ports (9001–9009) qua Traefik
- KHÔNG expose PostgreSQL/Redis ra ngoài
- MFE remotes: internal network only, không có Traefik labels public

## Rules GitHub Actions (bắt buộc)
- Matrix strategy cho parallel builds
- Cache Go modules + npm dependencies
- Docker images: tag cả `:sha` và `:latest`
- Production deploy: manual approval bắt buộc
- Health check sau mỗi deploy
- KHÔNG store secrets trong code

## Ports
- 80/443 → Traefik public
- 8080 → Traefik dashboard
- 8000–8008 → backend REST
- 9001–9009 → gRPC (internal only)
- 3000–3005 → frontend MFEs
- 9090 → Prometheus metrics
- 3100 → Grafana
