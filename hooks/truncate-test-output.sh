#!/bin/bash
# PostToolUse(Bash) hook — truncate verbose test runner output
# Keeps only summary lines (pass/fail counts) to reduce context tokens

INPUT=$(cat)
STDOUT=$(echo "$INPUT" | jq -r '.tool_result.stdout // empty' 2>/dev/null)

if [ -z "$STDOUT" ]; then
  exit 0
fi

LINE_COUNT=$(echo "$STDOUT" | wc -l | tr -d ' ')

# Only truncate if output is large (>50 lines) AND looks like test output
[ "$LINE_COUNT" -lt 50 ] && exit 0

# Detect test runner output patterns
IS_TEST=""
echo "$STDOUT" | grep -qE '(PASS|FAIL|Tests?:|test result|passed|failed|✓|✗|✘|Error:|TOTAL)' && IS_TEST="1"
echo "$STDOUT" | grep -qE '(vitest|jest|mocha|pytest|go test|cargo test|rspec)' && IS_TEST="1"

[ -z "$IS_TEST" ] && exit 0

# Extract summary lines (last 10 lines usually contain pass/fail counts)
SUMMARY=$(echo "$STDOUT" | tail -10)

# Also grab any failure/error lines
ERRORS=$(echo "$STDOUT" | grep -E '(FAIL|ERROR|✗|✘|panic:|AssertionError|assert)' | head -10)

if [ -n "$ERRORS" ]; then
  echo "[truncate-test] Output was ${LINE_COUNT} lines — showing errors + summary:" >&2
  echo "$ERRORS" >&2
  echo "---" >&2
  echo "$SUMMARY" >&2
else
  echo "[truncate-test] Output was ${LINE_COUNT} lines — showing summary:" >&2
  echo "$SUMMARY" >&2
fi

exit 0
