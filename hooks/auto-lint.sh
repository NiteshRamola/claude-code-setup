#!/bin/bash
# Auto-lint files after Claude edits them
# Detects project type and runs appropriate linter/formatter

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

DIR=$(dirname "$FILE_PATH")
EXT="${FILE_PATH##*.}"

# Find project root (look for package.json, pyproject.toml, etc.)
PROJECT_ROOT="$DIR"
while [ "$PROJECT_ROOT" != "/" ]; do
  if [ -f "$PROJECT_ROOT/package.json" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/Makefile" ]; then
    break
  fi
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

cd "$PROJECT_ROOT" 2>/dev/null || cd "$DIR"

case "$EXT" in
  js|jsx|ts|tsx|json|css|scss|md|yaml|yml)
    # Try prettier first, then eslint
    if command -v npx &>/dev/null && [ -f "node_modules/.bin/prettier" ]; then
      npx prettier --write "$FILE_PATH" 2>/dev/null
    elif command -v npx &>/dev/null && [ -f "node_modules/.bin/eslint" ]; then
      npx eslint --fix "$FILE_PATH" 2>/dev/null
    fi
    ;;
  py)
    # Python: black + isort
    if command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null
    fi
    if command -v isort &>/dev/null; then
      isort --quiet "$FILE_PATH" 2>/dev/null
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

exit 0
