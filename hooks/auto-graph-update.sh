#!/bin/bash
# PostToolUse hook — auto-update code-review-graph after file edits
# Only runs if code-review-graph is installed and a graph exists for the project

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only trigger for source code files
EXT="${FILE_PATH##*.}"
case "$EXT" in
  ts|tsx|js|jsx|py|go|rs|java|rb|php|c|cpp|h|hpp) ;;
  *) exit 0 ;;
esac

# Check if code-review-graph is available
if ! command -v code-review-graph &>/dev/null; then
  exit 0
fi

# Find project root
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT="$DIR"
while [ "$PROJECT_ROOT" != "/" ]; do
  if [ -f "$PROJECT_ROOT/package.json" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/go.mod" ] || [ -d "$PROJECT_ROOT/.git" ]; then
    break
  fi
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

if [ "$PROJECT_ROOT" = "/" ]; then
  exit 0
fi

# Check if a graph exists for this project (look for .code-review-graph dir)
if [ ! -d "$PROJECT_ROOT/.code-review-graph" ]; then
  exit 0
fi

# Incremental update (only changed files — fast, ~1-2 seconds)
cd "$PROJECT_ROOT"
code-review-graph update --quiet 2>/dev/null &

exit 0
