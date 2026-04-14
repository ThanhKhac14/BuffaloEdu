#!/bin/bash
# BuffaloEdu — Session Start Hook
set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // "unknown"' 2>/dev/null || echo "unknown")
LOG_DIR="${LOG_DIR:-logs/copilot}"
PROJECT="${PROJECT:-buffalo-edu}"
mkdir -p "$LOG_DIR"

LOG="$LOG_DIR/session-$(date +%Y%m%d).log"
echo "════════════════════════════════════════" >> "$LOG"
echo "SESSION START : $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$LOG"
echo "Session ID    : $SESSION_ID" >> "$LOG"
echo "Branch        : $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')" >> "$LOG"
echo "Commit        : $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" >> "$LOG"

cat >&2 <<'BANNER'
╔══════════════════════════════════════════════════════════╗
║           🐃 BUFFALOEDU — Copilot Agent Context          ║
╠══════════════════════════════════════════════════════════╣
║  Stack : Next.js 16.2.3 (App Router) + Go 1.26.2+             ║
║  DB    : PostgreSQL per service + pgx/v5 raw SQL         ║
║  Queue : RabbitMQ  ·  Cache: Redis                       ║
║  Proto : gRPC + buf CLI                                  ║
╠══════════════════════════════════════════════════════════╣
║  HARD RULES (pre-tool hook sẽ block nếu vi phạm):       ║
║  ✗ ORM (GORM) — dùng pgx/v5 raw SQL                     ║
║  ✗ Share PostgreSQL giữa services                        ║
║  ✗ Hardcode hex trong components                         ║
║  ✗ Expose gRPC ports (9001-9009) công khai               ║
║  ✓ Layering: handler → service → repository              ║
╠══════════════════════════════════════════════════════════╣
║  Docs : .github/copilot-instructions.md                  ║
║  Phases: docs/phases/phase-NN-*.md                       ║
║  Cmds : /review /bootstrap /deploy /test-all /compact    ║
╚══════════════════════════════════════════════════════════╝
BANNER

exit 0
