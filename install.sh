#!/bin/bash
# Claude Code Team Setup — Automated Installer
# Run: bash install.sh
# This sets up the complete Claude Code workflow for your machine.

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
RULES_DIR="$CLAUDE_DIR/rules"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"
TEMPLATES_DIR="$CLAUDE_DIR/templates"
SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "  Claude Code Team Setup Installer"
echo "========================================"
echo ""

# ── Step 1: Prerequisites ──────────────────────────────────────────
echo "[1/8] Checking prerequisites..."

if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude Code CLI not found. Install it first:"
  echo "  npm install -g @anthropic-ai/claude-code"
  echo "  OR: brew install claude-code"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "WARNING: jq not found. Hooks need it. Installing..."
  if command -v brew &>/dev/null; then
    brew install jq
  else
    echo "ERROR: Install jq manually: https://jqlang.github.io/jq/download/"
    exit 1
  fi
fi

if ! command -v code-review-graph &>/dev/null; then
  echo "Installing code-review-graph..."
  pipx install code-review-graph 2>/dev/null || pip install code-review-graph
fi

echo "  Claude Code: $(claude --version 2>/dev/null || echo 'installed')"
echo "  jq: $(jq --version 2>/dev/null)"
echo "  code-review-graph: $(code-review-graph --version 2>/dev/null || echo 'installed')"
echo ""

# ── Step 2: Create directories ─────────────────────────────────────
echo "[2/8] Creating directory structure..."
mkdir -p "$HOOKS_DIR" "$RULES_DIR" "$TEMPLATES_DIR"
mkdir -p "$SKILLS_DIR/review-pr" "$SKILLS_DIR/new-service"
mkdir -p "$AGENTS_DIR"
echo "  Created: hooks/, rules/, skills/, agents/, templates/"
echo ""

# ── Step 3: Copy CLAUDE.md ─────────────────────────────────────────
echo "[3/8] Installing global CLAUDE.md..."
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup.$(date +%s)"
  echo "  Backed up existing CLAUDE.md"
fi
cp "$SETUP_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  Installed: ~/.claude/CLAUDE.md (~25 lines)"
echo ""

# ── Step 4: Install settings.json ──────────────────────────────────
echo "[4/8] Installing settings.json..."
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.backup.$(date +%s)"
  echo "  Backed up existing settings.json"
fi

# Read the template and replace HOME_DIR placeholder
sed "s|__HOME_DIR__|$HOME|g" "$SETUP_DIR/config/settings.json" > "$CLAUDE_DIR/settings.json"
echo "  Installed: ~/.claude/settings.json (permissions + hooks + env)"
echo ""

# ── Step 5: Install keybindings ────────────────────────────────────
echo "[5/8] Installing keybindings.json..."
cp "$SETUP_DIR/config/keybindings.json" "$CLAUDE_DIR/keybindings.json"
echo "  Installed: ~/.claude/keybindings.json (vim-style navigation)"
echo ""

# ── Step 6: Install global MCP servers ─────────────────────────────
echo "[6/8] Installing global MCP servers..."
if [ -f "$HOME/.mcp.json" ]; then
  cp "$HOME/.mcp.json" "$HOME/.mcp.json.backup.$(date +%s)"
  echo "  Backed up existing ~/.mcp.json"
fi
cp "$SETUP_DIR/config/mcp.json" "$HOME/.mcp.json"
echo "  Installed: ~/.mcp.json (claude-flow + code-review-graph)"
echo ""

# ── Step 7: Install hooks, rules, skills, agents, templates ───────
echo "[7/8] Installing hooks, rules, skills, agents..."

# Hooks
for hook in auto-lint.sh auto-test.sh auto-graph-update.sh guard-destructive.sh secret-guard.sh session-start.sh; do
  cp "$SETUP_DIR/hooks/$hook" "$HOOKS_DIR/$hook"
  chmod +x "$HOOKS_DIR/$hook"
done
echo "  Installed: 6 hook scripts (executable)"

# Rules
for rule in security.md testing.md api-design.md docker.md git.md; do
  cp "$SETUP_DIR/rules/$rule" "$RULES_DIR/$rule"
done
echo "  Installed: 5 contextual rules"

# Skills
cp "$SETUP_DIR/skills/review-pr/SKILL.md" "$SKILLS_DIR/review-pr/SKILL.md"
cp "$SETUP_DIR/skills/new-service/SKILL.md" "$SKILLS_DIR/new-service/SKILL.md"
echo "  Installed: 2 skills (/review-pr, /new-service)"

# Agents
cp "$SETUP_DIR/agents/code-reviewer.md" "$AGENTS_DIR/code-reviewer.md"
cp "$SETUP_DIR/agents/security-auditor.md" "$AGENTS_DIR/security-auditor.md"
echo "  Installed: 2 subagent templates"

# Templates
cp "$SETUP_DIR/templates/PROJECT_CLAUDE_MD.md" "$TEMPLATES_DIR/PROJECT_CLAUDE_MD.md"
echo "  Installed: 1 project template"
echo ""

# ── Step 8: Install Codex plugin ───────────────────────────────────
echo "[8/8] Setting up Codex plugin..."
if ! claude plugin list 2>/dev/null | grep -q "codex"; then
  echo "  NOTE: Enable Codex plugin manually in Claude Code: /plugins"
fi
echo ""

# ── Done ───────────────────────────────────────────────────────────
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "What was installed:"
echo "  ~/.claude/CLAUDE.md          Global rules (SDD, 95% certainty)"
echo "  ~/.claude/settings.json      Permissions, hooks, env"
echo "  ~/.claude/keybindings.json   Vim-style shortcuts"
echo "  ~/.mcp.json                  claude-flow + code-review-graph"
echo "  ~/.claude/hooks/             6 automation scripts"
echo "  ~/.claude/rules/             5 contextual rules"
echo "  ~/.claude/skills/            2 skills (/review-pr, /new-service)"
echo "  ~/.claude/agents/            2 subagent templates"
echo "  ~/.claude/templates/         1 project template"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code (exit and relaunch)"
echo "  2. Run /doctor to verify no issues"
echo "  3. For each project: cd <project> && code-review-graph build"
echo "  4. Read the full docs: cat $(dirname "$0")/README.md"
echo ""
