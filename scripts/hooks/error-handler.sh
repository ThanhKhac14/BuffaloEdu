#!/bin/bash
# BuffaloEdu — Error Handler Hook
# Log errors + context-aware hints specific to this project
set -euo pipefail

INPUT=$(cat)
ERROR_MSG=$(echo "$INPUT" | jq -r '.error // .message // "unknown error"' 2>/dev/null || echo "unknown")
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // "unknown"' 2>/dev/null || echo "unknown")
LOG_DIR="${LOG_DIR:-logs/copilot}"
mkdir -p "$LOG_DIR"

echo "[$(date -u +"%H:%M:%S")] ERROR [$TOOL_NAME]: $ERROR_MSG" >> "$LOG_DIR/errors-$(date +%Y%m%d).log"
echo "🔴 [BuffaloEdu] Error in '$TOOL_NAME'" >&2
echo "   $ERROR_MSG" >&2

# ─── Context-aware hints ──────────────────────────────────────────────────────

# PostgreSQL / pgx errors
if echo "$ERROR_MSG" | grep -qiE "pgx|postgres|pq:|connection refused.*5432"; then
  echo "" >&2
  echo "💡 PostgreSQL hint:" >&2
  echo "   → Check DATABASE_URL format: postgres://user:pass@localhost:5432/dbname?sslmode=disable" >&2
  echo "   → Check docker compose is running: docker compose ps" >&2
  echo "   → Each service needs its own DB — auth_db, user_db, exam_db, etc." >&2
fi

# buf / protobuf errors
if echo "$ERROR_MSG" | grep -qiE "buf|proto|grpc|protobuf|rpc"; then
  echo "" >&2
  echo "💡 Proto hint:" >&2
  echo "   → Run: cd proto && buf lint" >&2
  echo "   → Run: cd proto && buf generate  (updates stubs in services/*/gen/)" >&2
  echo "   → Check go.mod replace directive for proto package" >&2
fi

# Go build/module errors
if echo "$ERROR_MSG" | grep -qiE "module not found|go build|cannot find|undefined:"; then
  echo "" >&2
  echo "💡 Go build hint:" >&2
  echo "   → Run: go mod download" >&2
  echo "   → Run: go mod tidy" >&2
  echo "   → Check import path matches go.mod module name" >&2
fi

# npm/node errors
if echo "$ERROR_MSG" | grep -qiE "cannot find module|module not found|npm|pnpm|node_modules"; then
  echo "" >&2
  echo "💡 Node hint:" >&2
  echo "   → Run: pnpm install (from frontend/ or specific MFE directory)" >&2
  echo "   → Check next.config.ts Module Federation remote URLs" >&2
fi

# TypeScript errors
if echo "$ERROR_MSG" | grep -qiE "type error|typescript|ts2\d{3}|cannot find name"; then
  echo "" >&2
  echo "💡 TypeScript hint:" >&2
  echo "   → Run: npx tsc --noEmit  (full error list)" >&2
  echo "   → Check shared/types/index.ts for missing interface" >&2
  echo "   → Avoid 'any' type — define proper interface" >&2
fi

# JWT / auth errors
if echo "$ERROR_MSG" | grep -qiE "unauthorized|401|403|jwt|token|invalid.*signature"; then
  echo "" >&2
  echo "💡 Auth hint:" >&2
  echo "   → Check JWT_SECRET in .env (must match across services)" >&2
  echo "   → Access token TTL: 15min · Refresh token TTL: 7 days" >&2
  echo "   → Redis session key: session:{user_id}:{token_id}" >&2
fi

# Docker / container errors
if echo "$ERROR_MSG" | grep -qiE "docker|container|connection refused|dial tcp|network"; then
  echo "" >&2
  echo "💡 Docker hint:" >&2
  echo "   → Run: docker compose up -d postgres redis rabbitmq" >&2
  echo "   → Check docker compose ps — all services healthy?" >&2
  echo "   → gRPC ports (9001-9009) are internal only — don't expose via Traefik" >&2
fi

# RabbitMQ errors
if echo "$ERROR_MSG" | grep -qiE "amqp|rabbitmq|exchange|queue|routing"; then
  echo "" >&2
  echo "💡 RabbitMQ hint:" >&2
  echo "   → Exchange: buffaloedu.events (type: direct)" >&2
  echo "   → Routing key: submission.completed" >&2
  echo "   → Check RABBITMQ_URL in .env" >&2
  echo "   → Management UI: http://localhost:15672 (guest/guest)" >&2
fi

echo "" >&2
exit 0
