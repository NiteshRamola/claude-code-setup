#!/bin/bash
# Guard against destructive Bash commands
# Returns exit code 2 to block, 0 to allow

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Patterns that should be blocked
# Only patterns NOT already covered by settings.json deny rules
# rm -rf /, sudo, force-push, | sh/bash are handled by deny list
BLOCKED_PATTERNS=(
  "mkfs\."
  "dd if=.* of=/dev/"
  "> /dev/sd"
  ":(){ :|:& };:"
  "chmod -R 777 /"
  "chown -R .* /"
  "curl.*\| *(python|perl|ruby)"
  "wget.*-O-.*\| *(sh|bash)"
)

COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND_LOWER" | grep -qE "$pattern"; then
    echo "BLOCKED: Destructive command detected: $COMMAND" >&2
    echo "This command could cause irreversible damage. Aborting." >&2
    exit 2
  fi
done

# Warn about potentially risky git operations (but don't block)
if echo "$COMMAND" | grep -qE "git (push --force|push -f|reset --hard|clean -fdx)"; then
  echo "WARNING: Potentially destructive git operation detected: $COMMAND" >&2
  echo "Proceeding with caution..." >&2
fi

exit 0
