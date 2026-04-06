# Learnify — Load Balancer Prompt (Traefik v3)
> Dùng trong GitHub Copilot Agent mode (@workspace).
> Traefik được chọn vì: free, auto-discovery Docker labels, HTTPS tự động (Let's Encrypt),
> built-in dashboard, tích hợp Prometheus sẵn — hoàn hảo cho Docker Compose + microservices.

---

## Tại sao Traefik (không phải Nginx)?

| | Traefik v3 | Nginx |
|---|---|---|
| Cost | Free & OSS | Free (Plus = paid) |
| Docker integration | Auto-discovery qua labels | Manual config mỗi service |
| HTTPS / Let's Encrypt | Tự động, zero config | Cần cài certbot riêng |
| New service routing | Thêm 3 Docker labels | Sửa nginx.conf + reload |
| Dashboard | Built-in (:8080) | Cần cài thêm |
| Prometheus metrics | Built-in | Cần nginx-prometheus-exporter |
| Microservices fit | ✅ Born for this | ⚠️ Works but more effort |

---

```
# LOAD BALANCER SCAFFOLD — Traefik v3 + Docker Compose

## Role
You are a senior DevOps/infrastructure engineer.
Scaffold complete Traefik v3 configuration for Learnify microservices.
All config must be version-controlled (no manual UI clicks).
Follow every constraint exactly.

---

## Folder Structure (generate exactly this)
```
infra/
├── traefik/
│   ├── traefik.yml          # Static config (entrypoints, providers, dashboard)
│   ├── dynamic/
│   │   ├── middlewares.yml  # Auth, rate-limit, CORS, security headers
│   │   └── tls.yml          # TLS options
│   └── acme/
│       └── .gitkeep         # Let's Encrypt certs stored here (git-ignored)
├── prometheus/
│   └── prometheus.yml
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/prometheus.yml
│   │   └── dashboards/dashboard.yml
│   └── dashboards/
│       ├── learnify-overview.json
│       ├── traefik.json
│       └── golang-services.json
└── docker-compose.yml       # Full compose (or extend root compose)
```

---

## Traefik Static Config (infra/traefik/traefik.yml)
```yaml
# traefik.yml — Static configuration
global:
  checkNewVersion: false
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: false   # Dashboard secured via middleware

log:
  level: INFO
  format: json

accessLog:
  format: json
  fields:
    headers:
      defaultMode: keep

metrics:
  prometheus:
    entryPoint: metrics
    addEntryPointsLabels: true
    addServicesLabels: true
    addRoutersLabels: true

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true

  websecure:
    address: ":443"
    http:
      tls:
        certResolver: letsencrypt
        domains:
          - main: "learnify.app"
            sans:
              - "*.learnify.app"
      middlewares:
        - security-headers@file
        - rate-limit@file

  traefik:
    address: ":8080"    # Dashboard (internal only)

  metrics:
    address: ":9090"    # Prometheus scrape endpoint (internal only)

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false   # Services must opt-in with traefik.enable=true
    network: learnify_public
  file:
    directory: /etc/traefik/dynamic
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: "admin@learnify.app"      # Replace with real email
      storage: /acme/acme.json
      httpChallenge:
        entryPoint: web
      # For wildcard certs, switch to dnsChallenge:
      # dnsChallenge:
      #   provider: cloudflare          # or route53, etc.
```

---

## Dynamic Middlewares (infra/traefik/dynamic/middlewares.yml)
```yaml
http:
  middlewares:

    # Security headers
    security-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000
        customResponseHeaders:
          X-Powered-By: ""
          Server: ""

    # Rate limiting (global)
    rate-limit:
      rateLimit:
        average: 100
        burst: 200
        period: 1s

    # Stricter rate limit for auth endpoints
    auth-rate-limit:
      rateLimit:
        average: 10
        burst: 20
        period: 1m

    # CORS for API
    cors:
      headers:
        accessControlAllowMethods:
          - GET
          - POST
          - PUT
          - DELETE
          - OPTIONS
        accessControlAllowHeaders:
          - Content-Type
          - Authorization
          - X-Request-ID
        accessControlAllowOriginList:
          - "https://learnify.app"
          - "https://*.learnify.app"
          - "http://localhost:3000"   # dev only
        accessControlMaxAge: 86400
        addVaryHeader: true

    # Strip prefix for API versioning
    api-strip-prefix:
      stripPrefix:
        prefixes:
          - "/api/v1"

    # Dashboard auth (basic auth — generate with htpasswd)
    dashboard-auth:
      basicAuth:
        users:
          - "admin:$apr1$..."   # htpasswd generated hash

    # Circuit breaker
    circuit-breaker:
      circuitBreaker:
        expression: "NetworkErrorRatio() > 0.30 || ResponseCodeRatio(500, 600, 0, 600) > 0.30"

    # Retry
    retry:
      retry:
        attempts: 3
        initialInterval: 100ms

    # Compress
    compress:
      compress:
        excludedContentTypes:
          - text/event-stream
```

---

## TLS Options (infra/traefik/dynamic/tls.yml)
```yaml
tls:
  options:
    default:
      minVersion: VersionTLS12
      cipherSuites:
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
        - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
      sniStrict: true
```

---

## Docker Compose — Traefik Service
```yaml
services:

  traefik:
    image: traefik:v3.0
    container_name: learnify-traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"     # Dashboard (restrict in production with firewall)
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./infra/traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - ./infra/traefik/dynamic:/etc/traefik/dynamic:ro
      - traefik_acme:/acme
    networks:
      - learnify_public
    labels:
      - "traefik.enable=true"
      # Dashboard route
      - "traefik.http.routers.dashboard.rule=Host(`traefik.learnify.app`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.middlewares=dashboard-auth@file"
      - "traefik.http.routers.dashboard.tls=true"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
    healthcheck:
      test: ["CMD", "traefik", "healthcheck"]
      interval: 30s
      timeout: 5s
      retries: 3
```

---

## Docker Labels — Per Service (add to each service in docker-compose)

### gateway service (main API entry)
```yaml
  gateway:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.gateway.rule=Host(`api.learnify.app`)"
      - "traefik.http.routers.gateway.entrypoints=websecure"
      - "traefik.http.routers.gateway.tls.certresolver=letsencrypt"
      - "traefik.http.routers.gateway.middlewares=cors@file,rate-limit@file,compress@file,circuit-breaker@file,retry@file"
      - "traefik.http.services.gateway.loadbalancer.server.port=8000"
      - "traefik.http.services.gateway.loadbalancer.healthcheck.path=/healthz"
      - "traefik.http.services.gateway.loadbalancer.healthcheck.interval=10s"
      - "traefik.docker.network=learnify_public"

      # Stricter rate limit for auth routes
      - "traefik.http.routers.gateway-auth.rule=Host(`api.learnify.app`) && PathPrefix(`/auth`)"
      - "traefik.http.routers.gateway-auth.middlewares=auth-rate-limit@file,cors@file"
      - "traefik.http.routers.gateway-auth.priority=10"
```

### shell-app (main frontend)
```yaml
  shell-app:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.shell.rule=Host(`learnify.app`) || Host(`www.learnify.app`)"
      - "traefik.http.routers.shell.entrypoints=websecure"
      - "traefik.http.routers.shell.tls.certresolver=letsencrypt"
      - "traefik.http.routers.shell.middlewares=security-headers@file,compress@file"
      - "traefik.http.services.shell.loadbalancer.server.port=3000"
      - "traefik.http.services.shell.loadbalancer.healthcheck.path=/api/health"
```

### MFE remote apps (internal, not public)
```yaml
  mfe-auth:
    labels:
      - "traefik.enable=true"
      # Internal route only — accessed by shell-app via Module Federation
      - "traefik.http.routers.mfe-auth.rule=Host(`mfe-auth.learnify.internal`)"
      - "traefik.http.routers.mfe-auth.entrypoints=web"
      - "traefik.http.services.mfe-auth.loadbalancer.server.port=3001"
      - "traefik.docker.network=learnify_internal"
    # Repeat pattern for mfe-dashboard(3002), mfe-exam(3003),
    # mfe-question(3004), mfe-reports(3005)
```

### Grafana
```yaml
  grafana:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana.learnify.app`)"
      - "traefik.http.routers.grafana.entrypoints=websecure"
      - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
      - "traefik.http.routers.grafana.middlewares=security-headers@file"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"
```

---

## Prometheus Config (infra/prometheus/prometheus.yml)
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: traefik
    static_configs:
      - targets: ['traefik:9090']

  - job_name: gateway
    static_configs:
      - targets: ['gateway:9090']
        labels: { service: gateway }

  - job_name: auth
    static_configs:
      - targets: ['auth:9090']
        labels: { service: auth }

  - job_name: user
    static_configs:
      - targets: ['user:9090']
        labels: { service: user }

  - job_name: exam
    static_configs:
      - targets: ['exam:9090']
        labels: { service: exam }

  - job_name: submission
    static_configs:
      - targets: ['submission:9090']
        labels: { service: submission }

  - job_name: result
    static_configs:
      - targets: ['result:9090']
        labels: { service: result }

  # Add remaining services: profile, question-bank, notification
```

---

## Networks (docker-compose)
```yaml
networks:
  learnify_public:
    driver: bridge
    # Traefik + gateway + frontend MFEs connect here

  learnify_internal:
    driver: bridge
    internal: true
    # Backend gRPC communication — NOT accessible from outside
    # All Go services connect here
```

---

## Volumes (docker-compose)
```yaml
volumes:
  traefik_acme:      # Let's Encrypt certificates (persist across restarts)
  prometheus_data:
  grafana_data:
  postgres_auth:
  postgres_user:
  postgres_profile:
  postgres_question:
  postgres_exam:
  postgres_submission:
  postgres_result:
  redis_data:
  rabbitmq_data:
```

---

## Domain Routing Summary
| Domain | Service | Notes |
|---|---|---|
| learnify.app | shell-app :3000 | Main frontend |
| www.learnify.app | shell-app :3000 | Redirects to learnify.app |
| api.learnify.app | gateway :8000 | Public REST API |
| api.learnify.app/auth/* | gateway :8000 | Stricter rate limit |
| traefik.learnify.app | Traefik dashboard | Basic auth protected |
| grafana.learnify.app | Grafana :3000 | Monitoring UI |
| mfe-*.learnify.internal | MFE apps | Internal only, Module Federation |

---

## Local Development (.env)
```bash
# For local dev, use localhost with /etc/hosts entries
DOMAIN=localhost
ACME_EMAIL=dev@localhost

# Add to /etc/hosts:
# 127.0.0.1 learnify.local
# 127.0.0.1 api.learnify.local
# 127.0.0.1 traefik.learnify.local
# 127.0.0.1 grafana.learnify.local

# For local HTTPS: use Traefik with mkcert or set insecure=true
```

---

## Constraints
- MUST set exposedByDefault: false — services opt-in explicitly
- MUST use read-only Docker socket mount (:ro)
- MUST enable health checks on all service routers
- MUST separate public and internal networks
- MUST secure dashboard with basicAuth middleware (never insecure: true in production)
- MUST store acme.json in named volume (not bind mount — permissions issues)
- NEVER expose gRPC ports (9001-9009) through Traefik
- NEVER expose PostgreSQL or Redis ports publicly
- NEVER use HTTP in production — redirect all to HTTPS

---

## Execution Order
Phase 1: infra/ folder structure + traefik.yml + dynamic/*.yml
Phase 2: docker-compose.yml — Traefik service + networks + volumes
Phase 3: Docker labels for all backend services
Phase 4: Docker labels for all frontend services
Phase 5: prometheus.yml + grafana provisioning
Phase 6: Grafana dashboard JSONs (Traefik overview, Go services, Learnify business metrics)

Generate Phase 1. List all files, then generate. Confirm before Phase 2.
```
