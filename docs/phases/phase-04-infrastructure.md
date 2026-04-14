# Phase 4 — Infrastructure (Traefik + CI/CD)

> Refs: `docs/shared/architecture.md`

## Mục tiêu

Config Traefik v3, Prometheus/Grafana provisioning, GitHub Actions CI/CD workflows.

---

## Traefik v3

### File structure
```
infra/traefik/
├── traefik.yml           ← static config
└── dynamic/
    ├── middlewares.yml   ← auth, rate-limit, CORS, security headers
    └── tls.yml           ← TLS options
```

### traefik.yml (static)
```yaml
global:
  checkNewVersion: false
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: false   # secured via basicAuth middleware

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint: { to: websecure, scheme: https, permanent: true }
  websecure:
    address: ":443"
    http:
      tls:
        certResolver: letsencrypt
      middlewares: [security-headers@file, rate-limit@file]
  traefik:
    address: ":8080"    # dashboard — firewall restrict in prod
  metrics:
    address: ":9090"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false    # BẮTBUỘC
    network: buffaloedu_public
  file:
    directory: /etc/traefik/dynamic
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: "admin@buffaloedu.app"
      storage: /acme/acme.json   # named volume — KHÔNG bind mount
      httpChallenge:
        entryPoint: web
```

### Rules (BẮTBUỘC)
- `exposedByDefault: false`
- Docker socket mount `:ro`
- `acme.json` trong named volume
- KHÔNG expose gRPC ports 9001–9009
- KHÔNG expose PostgreSQL/Redis
- MFE remotes: internal network only

### Docker Labels pattern

**Gateway (public API):**
```yaml
- "traefik.enable=true"
- "traefik.http.routers.gateway.rule=Host(`api.buffaloedu.app`)"
- "traefik.http.routers.gateway.entrypoints=websecure"
- "traefik.http.routers.gateway.tls.certresolver=letsencrypt"
- "traefik.http.routers.gateway.middlewares=cors@file,rate-limit@file,circuit-breaker@file"
- "traefik.http.services.gateway.loadbalancer.server.port=8000"
- "traefik.http.services.gateway.loadbalancer.healthcheck.path=/healthz"
- "traefik.docker.network=buffaloedu_public"
```

**MFE remote (internal only):**
```yaml
- "traefik.enable=true"
- "traefik.http.routers.mfe-auth.rule=Host(`mfe-auth.buffaloedu.internal`)"
- "traefik.http.routers.mfe-auth.entrypoints=web"
- "traefik.http.services.mfe-auth.loadbalancer.server.port=3001"
- "traefik.docker.network=buffaloedu_internal"
```

---

## Prometheus

```yaml
# infra/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: traefik
    static_configs:
      - targets: ['traefik:9090']
  - job_name: gateway
    static_configs:
      - targets: ['gateway:9090']
        labels: { service: gateway }
  # Repeat for: auth, user, profile, question-bank, exam, submission, result
```

---

## GitHub Actions Workflows

### proto-validate.yml
- Trigger: PR → changes in `proto/**`
- Steps: `buf lint` + `buf breaking --against main`

### backend-ci.yml
- Trigger: PR/push → `services/**`
- Matrix: `[gateway, auth, user, profile, question-bank, exam, submission, result, notification]`
- Steps: go vet + go test -race + docker build/push

### frontend-ci.yml
- Trigger: PR/push → `frontend/**`
- Matrix: `[shell-app, mfe-auth, mfe-dashboard, mfe-exam, mfe-question, mfe-reports]`
- Steps: tsc --noEmit + eslint + next build + docker build/push

### deploy-staging.yml
- Trigger: push to `main` (after CI pass)
- Steps: SSH → docker-compose pull → up → healthcheck retry 5×

### deploy-production.yml
- Trigger: manual `workflow_dispatch` hoặc tag `v*.*.*`
- **BẮTBUỘC:** manual approval (GitHub Environment protection)

### performance-test.yml
- Trigger: weekly schedule (Sunday 2am UTC)
- Steps: k6 scripts against staging
- Fail nếu p95 > 500ms hoặc error rate > 1%

---

## Quality Gate

```bash
# Traefik dry-run
docker run --rm -v $(pwd)/infra/traefik:/etc/traefik \
  traefik:v3.0 traefik --configFile=/etc/traefik/traefik.yml --dry-run

# Actions YAML syntax check
actionlint .github/workflows/*.yml
```
