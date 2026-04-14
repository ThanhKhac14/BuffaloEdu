#!/bin/bash
# BuffaloEdu — Pre Tool Use Hook
# Block: protected files | dangerous commands | ORM usage | convention violations
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // ""' 2>/dev/null || echo "")
TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs // "{}"' 2>/dev/null || echo "{}")

# ─── 1. Block dangerous shell commands ───────────────────────────────────────
if [[ "$TOOL_NAME" == "run_terminal_cmd" || "$TOOL_NAME" == "bash" || "$TOOL_NAME" == "shell" ]]; then
  CMD=$(echo "$TOOL_ARGS" | jq -r '.command // .cmd // ""' 2>/dev/null || echo "")
  DANGER_CMDS=(
    "DROP TABLE" "DROP DATABASE"
    "DELETE FROM"
    "prisma migrate reset"
    "prisma db push --force-reset"
    "rm -rf /"
    "git push --force"
    "git push -f"
  )
  for danger in "${DANGER_CMDS[@]}"; do
    if echo "$CMD" | grep -qi "$danger"; then
      echo "🚫 [BuffaloEdu] BLOCKED dangerous command: $(echo "$CMD" | head -c 100)" >&2
      echo "   → This command requires human confirmation. Run it manually if intended." >&2
      echo '{"decision":"block","reason":"Dangerous command — requires human confirmation"}'
      exit 0
    fi
  done
fi

# ─── 2. File write hooks ─────────────────────────────────────────────────────
if [[ "$TOOL_NAME" == "write_file" || "$TOOL_NAME" == "str_replace_based_edit_tool" || \
      "$TOOL_NAME" == "create_file" || "$TOOL_NAME" == "edit_file" ]]; then

  FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.path // .file_path // .filename // ""' 2>/dev/null || echo "")

  # ─── 2a. Block protected paths ─────────────────────────────────────────────
  PROTECTED=(
    ".env"
    ".env.local"
    ".env.production"
    ".env.staging"
    "go.mod"
    "go.sum"
    "buf.yaml"
    "buf.gen.yaml"
    "package-lock.json"
    "docker-compose.yml"
    "prisma/migrations"
  )
  for protected in "${PROTECTED[@]}"; do
    if [[ "$FILE_PATH" == *"$protected"* ]]; then
      echo "🚫 [BuffaloEdu] BLOCKED: Protected path → $FILE_PATH" >&2
      echo "   → '$protected' requires manual review. Edit this file yourself." >&2
      echo '{"decision":"block","reason":"Protected file — requires human review","file":"'"$FILE_PATH"'"}'
      exit 0
    fi
  done

  FILE_CONTENT=$(echo "$TOOL_ARGS" | jq -r '.new_contents // .content // .new_str // ""' 2>/dev/null || echo "")

  # ─── 2b. Go: block ORM usage ───────────────────────────────────────────────
  if [[ "$FILE_PATH" == *.go ]]; then
    if echo "$FILE_CONTENT" | grep -qE 'gorm\.Open|\.Create\(&|\.Find\(&|\.Save\(&|\.Delete\(&|\.First\(&|\.Where\(.*\)\..*\(&'; then
      echo "🚫 [BuffaloEdu] BLOCKED: ORM usage detected in $FILE_PATH" >&2
      echo "   → Use pgx/v5 raw SQL only. See docs/shared/backend-conventions.md" >&2
      echo '{"decision":"block","reason":"ORM forbidden — use pgx/v5 raw SQL only","file":"'"$FILE_PATH"'"}'
      exit 0
    fi

    # Warn: Go files outside Clean Architecture paths (in services/)
    if [[ "$FILE_PATH" == *"services/"* ]] && [[ "$FILE_PATH" != *"_test.go" ]]; then
      VALID_PATHS=("/handler/" "/service/" "/repository/" "/middleware/" "/model/" "/config/" "/cmd/" "/gen/" "/migrations/")
      IN_VALID=false
      for vp in "${VALID_PATHS[@]}"; do
        [[ "$FILE_PATH" == *"$vp"* ]] && IN_VALID=true && break
      done
      if [ "$IN_VALID" = false ]; then
        echo "⚠️  [BuffaloEdu] Go file outside Clean Architecture paths: $FILE_PATH" >&2
        echo "   → Expected: /handler/ /service/ /repository/ /middleware/ /model/ /config/ /cmd/" >&2
      fi
    fi
  fi

  # ─── 2c. TSX/JSX: block hardcoded hex + missing 'use client' ──────────────
  if [[ "$FILE_PATH" == *.tsx || "$FILE_PATH" == *.jsx ]]; then
    # Block hardcoded hex colors in style props or className arbitrary values
    if echo "$FILE_CONTENT" | grep -qE "style=\{[^}]*(color|background|border)[^}]*'#[0-9a-fA-F]|className=\"[^\"]*\[#[0-9a-fA-F]"; then
      echo "⚠️  [BuffaloEdu] Hardcoded hex color detected in $FILE_PATH" >&2
      echo "   → Use CSS token classes: text-primary, bg-surface-1, border-border, etc." >&2
      echo "   → See docs/shared/design-system.md for full token reference." >&2
    fi

    # Warn: hooks without 'use client'
    if echo "$FILE_CONTENT" | grep -qE "useState|useEffect|useRef|useCallback|useReducer|useMemo"; then
      if ! echo "$FILE_CONTENT" | grep -q '"use client"'; then
        echo "⚠️  [BuffaloEdu] React hooks detected but missing '\"use client\"' in $FILE_PATH" >&2
        echo "   → Add '\"use client\";' as the first line of the file." >&2
      fi
    fi

    # Warn: inline style for spacing/color
    if echo "$FILE_CONTENT" | grep -qE "style=\{\{[^}]*(padding|margin|color|background|fontSize)[^}]*\}\}"; then
      echo "⚠️  [BuffaloEdu] Inline style for layout/color detected in $FILE_PATH" >&2
      echo "   → Use Tailwind utility classes instead." >&2
    fi
  fi

  # ─── 2d. .proto: remind to regenerate ─────────────────────────────────────
  if [[ "$FILE_PATH" == *.proto ]]; then
    echo "⚙️  [BuffaloEdu] .proto file modified: $FILE_PATH" >&2
    echo "   → After saving: run 'cd proto && buf lint && buf generate'" >&2
  fi

fi

exit 0
