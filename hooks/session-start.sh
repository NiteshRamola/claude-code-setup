#!/bin/bash
# SessionStart hook — runs when a new Claude Code session begins
# Performs quick health checks and sets up the environment

PROJECT_ROOT="$(pwd)"

# Initialize the test-run marker for auto-test.sh
touch /tmp/.claude-last-test-run

# Check if we're in a git repo
if git rev-parse --is-inside-work-tree &>/dev/null; then
  # Check for uncommitted changes
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$DIRTY" -gt 0 ]; then
    echo "[session-start] Warning: $DIRTY uncommitted changes in working tree" >&2
  fi

  # Check if branch is behind remote
  BEHIND=$(git rev-list HEAD..@{upstream} --count 2>/dev/null)
  if [ -n "$BEHIND" ] && [ "$BEHIND" -gt 0 ]; then
    echo "[session-start] Warning: Branch is $BEHIND commits behind remote" >&2
  fi
fi

# Check if docker is running (if docker-compose.yml exists)
if [ -f "$PROJECT_ROOT/docker-compose.yml" ] || [ -f "$PROJECT_ROOT/infrastructure/docker/docker-compose.yml" ]; then
  if ! docker info &>/dev/null 2>&1; then
    echo "[session-start] Warning: Docker is not running — containers won't start" >&2
  fi
fi

# Check for .env file (remind if missing)
if [ -f "$PROJECT_ROOT/.env.example" ] && [ ! -f "$PROJECT_ROOT/.env" ]; then
  echo "[session-start] Warning: .env.example exists but .env is missing — run: cp .env.example .env" >&2
fi

exit 0
