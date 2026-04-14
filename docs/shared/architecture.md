# System Architecture — BuffaloEdu

## Overview

```
Client (Browser/Mobile)
        │  HTTPS
        ▼
┌───────────────┐
│  Traefik v3   │  Load Balancer · Auto SSL · Rate limiting
└───────┬───────┘
        │  REST
┌───────▼───────┐
│   API Gateway │  REST → gRPC fan-out · JWT validation · CORS
│   :8000       │
└───────┬───────┘
        │  gRPC (internal Docker network only)
   ┌────┴────┬─────────┬──────────┬────────────┐
   ▼         ▼         ▼          ▼            ▼
 auth      user      exam     question     result
 :9001    :9002     :9005      -bank       :9007
   │         │         │       :9004          │
 auth_db  user_db  exam_db  question_db  result_db
   │                  │
 Redis           submission
 sessions         :9006
                     │
                 submission_db
                     │
                 RabbitMQ ──► notification
                              (consumer)
```

## Frontend (Module Federation)

```
shell-app (HOST :3000)
├── mfe-auth      (REMOTE :3001) /login /register /onboarding
├── mfe-dashboard (REMOTE :3002) /dashboard
├── mfe-exam      (REMOTE :3003) /exams/* /result
├── mfe-question  (REMOTE :3004) /question-bank
└── mfe-reports   (REMOTE :3005) /reports /achievements
```

## Port Reference

| Range | Usage |
|---|---|
| 80/443 | Traefik public |
| 8080 | Traefik dashboard |
| 8000–8008 | Backend REST |
| 9001–9009 | gRPC **internal only** |
| 3000–3005 | Frontend MFEs |
| 9090 | Prometheus metrics per service |
| 3100 | Grafana |
| 15672 | RabbitMQ management UI |

## Go Service Layering (STRICT)

```
handler/      Validate input → call service → return response
              KHÔNG business logic · KHÔNG DB calls

service/      Business logic only
              KHÔNG SQL · Calls repository layer

repository/   ALL SQL queries (pgx/v5 raw) + Redis
              KHÔNG business logic

middleware/   gRPC interceptors: auth · logging · metrics · recovery

model/        Domain structs (NOT proto-generated types)
config/       Viper env loading → typed Config struct
```

## RabbitMQ Events

| Exchange | Routing Key | Producer | Consumer |
|---|---|---|---|
| `buffaloedu.events` | `submission.completed` | submission | notification |

Payload: `{ submission_id, student_id, exam_id, score, passed }`

## Redis Keys

| Service | Pattern | TTL | Purpose |
|---|---|---|---|
| auth | `session:{user_id}:{token_id}` | 7 days | Refresh tokens |
| exam | `exam:published:{exam_id}` | 10 min | Published exam cache |
