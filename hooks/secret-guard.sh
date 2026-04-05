#!/bin/bash
# UserPromptSubmit hook — detect secrets accidentally pasted into prompts
# Returns exit code 2 to block submission with warning

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Common secret patterns (regex)
SECRET_PATTERNS=(
  # AWS
  'AKIA[0-9A-Z]{16}'
  'aws_secret_access_key\s*=\s*\S+'
  # GitHub/GitLab tokens
  'gh[pousr]_[A-Za-z0-9_]{36,}'
  'glpat-[A-Za-z0-9\-]{20,}'
  # Generic API keys
  'sk-[A-Za-z0-9]{32,}'
  'sk-ant-[A-Za-z0-9\-]{40,}'
  'api[_-]?key\s*[:=]\s*["\x27][A-Za-z0-9\-_]{20,}["\x27]'
  'api[_-]?secret\s*[:=]\s*["\x27][A-Za-z0-9\-_]{20,}["\x27]'
  # Private keys
  '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'
  # JWT tokens
  'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+'
  # Database connection strings with passwords
  '(mysql|postgres|postgresql|mongodb|redis):\/\/[^:]+:[^@]+@'
  # Stripe
  'sk_live_[A-Za-z0-9]{24,}'
  'rk_live_[A-Za-z0-9]{24,}'
  # Slack
  'xoxb-[0-9]{10,}-[A-Za-z0-9]{24,}'
  'xoxp-[0-9]{10,}-[A-Za-z0-9]{24,}'
  # Google
  'AIza[0-9A-Za-z\-_]{35}'
  # Generic password in env format
  '(PASSWORD|SECRET|TOKEN|CREDENTIAL)\s*=\s*[^\s]{8,}'
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qEi "$pattern" 2>/dev/null; then
    MATCHED=$(echo "$PROMPT" | grep -oEi "$pattern" 2>/dev/null | head -1 | cut -c1-20)
    echo "WARNING: Possible secret detected in your prompt (matched: ${MATCHED}...)" >&2
    echo "If this is intentional (e.g., asking about a format), re-submit. Otherwise, remove the secret." >&2
    exit 2
  fi
done

exit 0
