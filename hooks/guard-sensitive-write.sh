#!/bin/bash
# PreToolUse(Write|Edit) hook — warn before writing to sensitive file paths
# Returns exit code 2 to block, 0 to allow

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
EXT="${BASENAME##*.}"

# Sensitive file patterns
case "$BASENAME" in
  .env|.env.local|.env.production|.env.staging)
    echo "BLOCKED: Refusing to write to $BASENAME — use .env.example instead" >&2
    exit 2
    ;;
  credentials.*|secrets.*|id_rsa|id_ed25519|*.pem|*.key|*.p12|*.pfx|*.jks)
    echo "BLOCKED: Refusing to write to sensitive file: $BASENAME" >&2
    exit 2
    ;;
  .npmrc|.pypirc|.netrc|.docker/config.json)
    echo "BLOCKED: Refusing to write to credential config: $BASENAME" >&2
    exit 2
    ;;
esac

# Catch .env.* variants not covered above (but allow .env.example)
if echo "$BASENAME" | grep -qE '^\.env\.' && ! echo "$BASENAME" | grep -qE '\.example$'; then
  echo "BLOCKED: Refusing to write to $BASENAME — use .env.example instead" >&2
  exit 2
fi

exit 0
