#!/bin/bash
# BuffaloEdu — Post Tool Use Hook
# Auto-run lint + tests sau khi agent ghi file
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // ""' 2>/dev/null || echo "")
TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs // "{}"' 2>/dev/null || echo "{}")
LOG_DIR="${LOG_DIR:-logs/copilot}"
RUN_LINT="${RUN_LINT:-true}"
RUN_TESTS="${RUN_TESTS:-true}"
mkdir -p "$LOG_DIR"

# Chỉ chạy sau file writes
if [[ "$TOOL_NAME" != "write_file" && "$TOOL_NAME" != "str_replace_based_edit_tool" && \
      "$TOOL_NAME" != "create_file" && "$TOOL_NAME" != "edit_file" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.path // .file_path // .filename // ""' 2>/dev/null || echo "")
[ -z "$FILE_PATH" ] && exit 0

echo "📝 [BuffaloEdu] File written: $FILE_PATH" >&2

# ─── Next.js / TypeScript files ──────────────────────────────────────────────
if [[ "$FILE_PATH" == *.tsx || "$FILE_PATH" == *.ts || "$FILE_PATH" == *.jsx || "$FILE_PATH" == *.js ]]; then

  # Detect which MFE/app this file belongs to
  APP_ROOT=""
  for app in shell-app mfe-auth mfe-dashboard mfe-exam mfe-question mfe-reports; do
    if [[ "$FILE_PATH" == *"frontend/$app/"* ]]; then
      APP_ROOT="frontend/$app"
      break
    fi
  done

  if [[ "$RUN_LINT" == "true" && -n "$APP_ROOT" && -f "$APP_ROOT/package.json" ]]; then
    echo "🔍 [BuffaloEdu] ESLint on $FILE_PATH" >&2
    RELATIVE="${FILE_PATH#$APP_ROOT/}"
    if (cd "$APP_ROOT" && npx eslint "$RELATIVE" --max-warnings 0 2>&1 | tee -a "../$LOG_DIR/lint-fe.log"); then
      echo "✅ ESLint passed" >&2
    else
      echo "❌ ESLint failed — see $LOG_DIR/lint-fe.log" >&2
    fi
  fi

  if [[ "$RUN_TESTS" == "true" && -n "$APP_ROOT" ]]; then
    # Look for matching test file
    for EXT in ".test.tsx" ".test.ts" ".spec.tsx" ".spec.ts"; do
      BASE="${FILE_PATH%.*}"
      TEST_FILE="${BASE}${EXT}"
      if [ -f "$TEST_FILE" ]; then
        echo "🧪 [BuffaloEdu] Vitest: $TEST_FILE" >&2
        (cd "$APP_ROOT" && npx vitest run "${TEST_FILE#$APP_ROOT/}" 2>&1 | tee -a "../$LOG_DIR/test-fe.log") \
          && echo "✅ Tests passed" >&2 \
          || echo "❌ Tests failed — see $LOG_DIR/test-fe.log" >&2
        break
      fi
    done
  fi
fi

# ─── Go files ─────────────────────────────────────────────────────────────────
if [[ "$FILE_PATH" == *.go ]]; then
  PKG_DIR=$(dirname "$FILE_PATH")

  if [[ "$RUN_LINT" == "true" ]]; then
    if command -v golangci-lint &>/dev/null; then
      echo "🔍 [BuffaloEdu] golangci-lint: ./$PKG_DIR/..." >&2
      golangci-lint run "./$PKG_DIR/..." 2>&1 | tee -a "$LOG_DIR/lint-go.log" \
        && echo "✅ golangci-lint passed" >&2 \
        || echo "❌ golangci-lint failed — see $LOG_DIR/lint-go.log" >&2
    elif command -v go &>/dev/null; then
      echo "🔍 [BuffaloEdu] go vet: ./$PKG_DIR/..." >&2
      go vet "./$PKG_DIR/..." 2>&1 | tee -a "$LOG_DIR/lint-go.log" \
        && echo "✅ go vet passed" >&2 \
        || echo "❌ go vet failed" >&2
    fi
  fi

  if [[ "$RUN_TESTS" == "true" ]] && command -v go &>/dev/null; then
    echo "🧪 [BuffaloEdu] go test: ./$PKG_DIR/..." >&2
    go test "./$PKG_DIR/..." -count=1 -timeout 30s 2>&1 | tee -a "$LOG_DIR/test-go.log" \
      && echo "✅ Go tests passed" >&2 \
      || echo "❌ Go tests failed — see $LOG_DIR/test-go.log" >&2
  fi
fi

# ─── Proto files ──────────────────────────────────────────────────────────────
if [[ "$FILE_PATH" == *.proto ]] && command -v buf &>/dev/null; then
  echo "⚙️  [BuffaloEdu] buf lint after .proto change..." >&2
  PROTO_DIR="proto"
  [ -d "$PROTO_DIR" ] && (cd "$PROTO_DIR" && buf lint 2>&1 | tee -a "../$LOG_DIR/proto.log") \
    && echo "✅ buf lint passed — run 'buf generate' to update stubs" >&2 \
    || echo "❌ buf lint failed — see $LOG_DIR/proto.log" >&2
fi

exit 0
