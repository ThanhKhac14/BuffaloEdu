#!/bin/bash
# BuffaloEdu — Validate Prompt Hook
# Log prompt + cảnh báo vùng nhạy cảm + nhắc i18n
set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || echo "")
LOG_DIR="${LOG_DIR:-logs/copilot}"
mkdir -p "$LOG_DIR"

# Log prompt (truncated)
echo "[$(date -u +"%H:%M:%S")] $(echo "$PROMPT" | head -c 150)..." >> "$LOG_DIR/prompts-$(date +%Y%m%d).log"

# Cảnh báo vùng nhạy cảm
SENSITIVE_KW=("payment" "billing" "stripe" "vnpay" "subscription" "password" "secret" "migration" "seed" "drop table" "delete from")
for kw in "${SENSITIVE_KW[@]}"; do
  if echo "$PROMPT" | grep -qi "$kw"; then
    echo "⚠️  [BuffaloEdu] Sensitive area detected: '$kw'" >&2
    echo "   → Double-check business rules before modifying this area." >&2
    case "$kw" in
      payment|billing|stripe|vnpay)
        echo "   → Payments: follow VNPay checksum spec + Stripe webhook idempotency." >&2 ;;
      password|secret)
        echo "   → Secrets must be in env vars — NEVER commit to code." >&2 ;;
      migration)
        echo "   → Migrations: BOTH .up.sql and .down.sql required." >&2 ;;
    esac
    break
  fi
done

# Nhắc i18n nếu thay đổi UI
if echo "$PROMPT" | grep -qiE "(component|page|ui|form|button|text|label|message|screen|modal|toast)"; then
  echo "🌐 [BuffaloEdu] UI change detected — remember i18n keys (vi + en) via next-intl." >&2
fi

# Nhắc quality gate nếu đề cập service/feature lớn
if echo "$PROMPT" | grep -qiE "(service|microservice|proto|protobuf)"; then
  echo "⚙️  [BuffaloEdu] Proto/service work → run 'buf lint && buf generate' after changes." >&2
fi

exit 0
