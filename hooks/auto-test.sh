#!/bin/bash
# Auto-run tests after Claude finishes — ONLY if source files were modified by Claude

# Find project root
PROJECT_ROOT="$(pwd)"
while [ "$PROJECT_ROOT" != "/" ]; do
  if [ -f "$PROJECT_ROOT/package.json" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/go.mod" ] || [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
    break
  fi
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

[ "$PROJECT_ROOT" = "/" ] && exit 0
cd "$PROJECT_ROOT"

# Create marker on first run
[ ! -f /tmp/.claude-last-test-run ] && touch /tmp/.claude-last-test-run && exit 0

# Only run if source files were modified since last test run
MODIFIED=$(find . \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
     -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -not -path "*/dist/*" -not -path "*/build/*" \
  -newer /tmp/.claude-last-test-run 2>/dev/null | head -1)

[ -z "$MODIFIED" ] && exit 0

# Also check git — only run if there are uncommitted changes to source files
DIRTY=$(git diff --name-only 2>/dev/null | grep -E '\.(ts|tsx|js|jsx|py|go|rs)$' | head -1)
STAGED=$(git diff --cached --name-only 2>/dev/null | grep -E '\.(ts|tsx|js|jsx|py|go|rs)$' | head -1)

[ -z "$DIRTY" ] && [ -z "$STAGED" ] && exit 0

touch /tmp/.claude-last-test-run

# Collect changed directories for scoped test runs
CHANGED_DIRS=$(git diff --name-only 2>/dev/null; git diff --cached --name-only 2>/dev/null)
CHANGED_DIRS=$(echo "$CHANGED_DIRS" | grep -E '\.(ts|tsx|js|jsx|py|go|rs)$' | xargs -I{} dirname {} | sort -u)

# Detect and run (scoped to changed packages where possible)
if [ -f "pnpm-workspace.yaml" ] || [ -f "pnpm-lock.yaml" ]; then
  # Detect changed pnpm workspace packages
  CHANGED_PKGS=$(echo "$CHANGED_DIRS" | grep -oE '^(packages|services|apps)/[^/]+' | sort -u | sed 's/.*\///' | paste -sd',' -)
  if [ -n "$CHANGED_PKGS" ]; then
    echo "[auto-test] Running: pnpm test --filter={${CHANGED_PKGS}}" >&2
    timeout 50 pnpm test --filter="{${CHANGED_PKGS}}" --reporter=dot 2>&1 | tail -10 >&2
  else
    echo "[auto-test] Running: pnpm test" >&2
    timeout 50 pnpm test --reporter=dot 2>&1 | tail -10 >&2
  fi
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  echo "[auto-test] Running: npm test" >&2
  timeout 50 npm test --silent 2>&1 | tail -10 >&2
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  # Scope pytest to changed directories
  PYTEST_PATHS=$(echo "$CHANGED_DIRS" | head -5 | tr '\n' ' ')
  if [ -n "$PYTEST_PATHS" ]; then
    echo "[auto-test] Running: pytest (scoped to changed)" >&2
    timeout 50 python -m pytest --tb=line -q $PYTEST_PATHS 2>&1 | tail -10 >&2
  else
    echo "[auto-test] Running: pytest" >&2
    timeout 50 python -m pytest --tb=line -q 2>&1 | tail -10 >&2
  fi
elif [ -f "go.mod" ]; then
  # Scope go test to changed packages
  GO_PKGS=$(echo "$CHANGED_DIRS" | sed 's|^|./|' | paste -sd' ' -)
  if [ -n "$GO_PKGS" ]; then
    echo "[auto-test] Running: go test (scoped to changed)" >&2
    timeout 50 go test $GO_PKGS -count=1 -short 2>&1 | tail -10 >&2
  else
    echo "[auto-test] Running: go test" >&2
    timeout 50 go test ./... -count=1 -short 2>&1 | tail -10 >&2
  fi
elif [ -f "Cargo.toml" ]; then
  echo "[auto-test] Running: cargo test" >&2
  timeout 50 cargo test --quiet 2>&1 | tail -10 >&2
fi

exit 0
