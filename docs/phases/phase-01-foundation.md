# Phase 1 — Foundation (Backend)

> Refs: `docs/shared/architecture.md` · `docs/shared/backend-conventions.md`

## Mục tiêu

Scaffold monorepo skeleton + Protobuf + docker-compose. Không viết business logic ở phase này.

## Tasks

### 1.1 — Monorepo scaffold

```
BuffaloEdu/
├── proto/
│   ├── buf.yaml
│   ├── buf.gen.yaml
│   └── {service}/v1/{service}.proto   ← 8 services
├── services/
│   ├── gateway/ auth/ user/ profile/
│   ├── question-bank/ exam/ submission/ result/ notification/
├── frontend/
│   ├── shell-app/ mfe-auth/ mfe-dashboard/
│   ├── mfe-exam/ mfe-question/ mfe-reports/
│   └── shared/
├── infra/
│   ├── traefik/ prometheus/ grafana/
├── k6/scripts/
├── .github/workflows/
├── docker-compose.yml
├── .env.example
└── README.md
```

### 1.2 — Protobuf definitions

Tạo `.proto` cho 8 services: `auth`, `user`, `profile`, `question-bank`, `exam`, `submission`, `result`, `notification`.

Mỗi file phải có:
- `syntax = "proto3"`
- `package buffaloedu.{service}.v1`
- `option go_package = "github.com/buffaloedu/services/{service}/gen/{service}v1"`
- Service definition với CRUD RPCs
- **BẮTBUỘC:** `healthz` RPC trên mọi service

```protobuf
// Mẫu — proto/{service}/v1/{service}.proto
syntax = "proto3";
package buffaloedu.auth.v1;
option go_package = "github.com/buffaloedu/services/auth/gen/authv1";

service AuthService {
  rpc Healthz(HealthzRequest) returns (HealthzResponse);
  rpc Register(RegisterRequest) returns (RegisterResponse);
  rpc Login(LoginRequest) returns (LoginResponse);
  rpc Logout(LogoutRequest) returns (LogoutResponse);
  rpc RefreshToken(RefreshTokenRequest) returns (RefreshTokenResponse);
  rpc ValidateToken(ValidateTokenRequest) returns (ValidateTokenResponse);
}

message HealthzRequest {}
message HealthzResponse { string status = 1; }
```

**buf.yaml:**
```yaml
version: v2
lint:
  use: [DEFAULT]
  except: [PACKAGE_VERSION_SUFFIX]
breaking:
  use: [FILE]
```

**buf.gen.yaml:**
```yaml
version: v2
plugins:
  - plugin: buf.build/protocolbuffers/go
    out: ../services
    opt: [paths=source_relative]
  - plugin: buf.build/grpc/go
    out: ../services
    opt: [paths=source_relative, require_unimplemented_servers=false]
```

### 1.3 — Root docker-compose.yml

Services cần có:
- `traefik` + `gateway` + 8 backend services
- `postgres` × 8 (mỗi service DB riêng: auth_db, user_db, exam_db...)
- `redis` (shared)
- `rabbitmq` (với management UI :15672)
- `prometheus` + `grafana`

Networks:
```yaml
networks:
  buffaloedu_public:     # traefik + gateway + frontends
    driver: bridge
  buffaloedu_internal:   # gRPC only
    driver: bridge
    internal: true
```

### 1.4 — .env.example

Phải document đầy đủ: `DATABASE_URL`, `REDIS_URL`, `RABBITMQ_URL`, `JWT_SECRET`, `GRPC_ADDR`, service names.

## Quality Gate

```bash
buf lint                  # 0 errors
buf generate              # stubs generated thành công
docker-compose config     # valid YAML
```

## Output: Files cần tạo

- `proto/buf.yaml`
- `proto/buf.gen.yaml`
- `proto/{service}/v1/{service}.proto` × 8
- `docker-compose.yml`
- `.env.example`
- Folder skeleton cho tất cả services + MFEs
