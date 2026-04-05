# Claude Code Team Setup

Production-grade Claude Code configuration for engineering teams. Enforces Spec-Driven Development (SDD), automated linting, testing, security scanning, and code review workflows.

## Quick Install

```bash
git clone <this-repo> ~/claude-code-setup
cd ~/claude-code-setup
bash install.sh
```

Then restart Claude Code.

---

## Prerequisites

Install these BEFORE running `install.sh`:

| Tool | Install Command | Purpose |
|---|---|---|
| **Claude Code** | `npm i -g @anthropic-ai/claude-code` or `brew install claude-code` | CLI |
| **jq** | `brew install jq` | JSON parsing in hooks |
| **code-review-graph** | `pipx install code-review-graph` | Code analysis MCP server |
| **Node.js 18+** | `brew install node` | Required for claude-flow |
| **Prettier** (optional) | `npm i -g prettier` | Auto-formatting JS/TS |
| **Black** (optional) | `pip install black isort` | Auto-formatting Python |

---

## What Gets Installed

```
~/.claude/
├── CLAUDE.md                    # Global rules (42 lines)
├── settings.json                # Permissions + hooks + env
├── keybindings.json             # Vim-style shortcuts
├── rules/
│   ├── security.md              # Loaded when editing source files
│   ├── testing.md               # Loaded when editing test files
│   ├── api-design.md            # Loaded when editing routes/handlers
│   └── docker.md                # Loaded when editing Dockerfiles/compose
├── skills/
│   ├── review-pr/SKILL.md       # /review-pr command
│   └── new-service/SKILL.md     # /new-service command
├── agents/
│   ├── code-reviewer.md         # Parallel code review subagent
│   └── security-auditor.md      # Security scanning subagent
├── hooks/
│   ├── session-start.sh         # Git/Docker/env warnings on session start
│   ├── secret-guard.sh          # Blocks accidental secret paste in prompts
│   ├── guard-destructive.sh     # Blocks rm -rf /, sudo, fork bombs
│   ├── auto-lint.sh             # Auto-formats files after edits
│   ├── auto-graph-update.sh     # Keeps code-review-graph in sync
│   └── auto-test.sh             # Runs tests if source files changed
└── templates/
    └── PROJECT_CLAUDE_MD.md     # Template for new project CLAUDE.md

~/.mcp.json                      # Global MCP: claude-flow + code-review-graph
```

---

## Post-Install Steps

### 1. Restart Claude Code
```bash
# Exit current session, then:
claude
```

### 2. Verify setup
```bash
# Inside Claude Code:
/doctor
```

Expected: no errors, no keybinding conflicts.

### 3. Enable Codex plugin (optional but recommended)
```bash
# Inside Claude Code:
/plugins
# Enable: codex@openai-codex
```

### 4. Set up code-review-graph for each project
```bash
cd ~/Developer/<your-project>
code-review-graph build
code-review-graph status   # verify: should show node/edge counts
```

---

## How the Workflow Works

### Development Methodology: Spec-Driven Development (SDD)

Every task MUST follow this exact sequence — no exceptions, no skipping:

```
 1. UNDERSTAND    Claude reads your request

 2. QUESTIONS     Claude asks clarifying questions until ≥95% certainty

 3. SPEC          Claude generates a detailed SPEC.md

 4. APPROVAL      You review → "approved" or request changes
                  Spec is frozen after approval

 5. CODE          Claude implements ONLY after approval
                  auto-lint + auto-graph-update fire on every edit

 6. TESTS         Claude writes COMPLETE test suite
                  (unit + integration + E2E, 100% coverage)
                  auto-test fires when Claude stops

 7. ADVERSARIAL   Claude AUTOMATICALLY runs /codex:adversarial-review
   REVIEW         This is NOT optional — Claude runs it without being asked

 8. FIX           Claude fixes all issues found by adversarial review

 9. REPEAT        Steps 7-8 loop until NO critical issues remain

10. COMMIT        Claude commits (prompts you before git push)
```

**Steps 7-9 are mandatory.** Claude runs `/codex:adversarial-review` automatically after
implementation + tests. It loops until the system is stable. You do NOT need to ask for it.

### What Happens Automatically

| Event | Hook | What It Does |
|---|---|---|
| Session starts | `session-start.sh` | Warns: uncommitted changes, Docker not running, .env missing |
| You type a prompt | `secret-guard.sh` | Blocks if you paste AWS keys, GitHub tokens, JWTs, DB URIs, etc. |
| Claude runs Bash | `guard-destructive.sh` | Blocks `rm -rf /`, `sudo`, fork bombs, `dd` |
| Claude edits a file | `auto-lint.sh` | Auto-formats: Prettier (JS/TS), Black+isort (Python), gofmt (Go), rustfmt (Rust) |
| Claude edits a file | `auto-graph-update.sh` | Incrementally updates code-review-graph |
| Claude finishes | `auto-test.sh` | Runs tests only if source files have uncommitted changes |

### Permission Tiers

| Tier | What Happens | Examples |
|---|---|---|
| **Allow** (auto) | Runs without prompting | npm, python, go, cargo, git status/log/diff, docker compose, gh |
| **Ask** (prompt) | Claude asks you first | git push, rm, mv, cp, docker stop, kill |
| **Deny** (blocked) | Permanently blocked | rm -rf /, sudo, git push --force, pipe-to-bash |

### Keybindings

| Key | Action |
|---|---|
| `Enter` | Submit prompt |
| `Alt+Enter` | New line in prompt |
| `Escape` | Cancel |
| `Ctrl+Shift+P` | Switch model |
| `Ctrl+Shift+T` | Toggle thinking |
| `Meta+O` | Fast mode |
| `Ctrl+E` | Open in external editor |
| `Ctrl+S` | Stash prompt |
| `Ctrl+T` | Toggle tasks |
| `Ctrl+O` | Toggle transcript |
| `Ctrl+R` | Search history |
| `j/k` | Navigate lists, diffs, messages |
| `y/n` | Confirm/deny |

---

## Setting Up a New Project

```bash
# 1. Create project
mkdir ~/Developer/my-project && cd ~/Developer/my-project
git init

# 2. Create CLAUDE.md (copy template, fill in details)
cp ~/.claude/templates/PROJECT_CLAUDE_MD.md CLAUDE.md
# Edit: tech stack, commands, architecture, domain rules
# Keep under 80 lines — only project-specific info

# 3. Add project rules (optional)
mkdir -p .claude/rules
# Create .claude/rules/domain.md with project-specific conventions
# Use globs to control when rules load:
# ---
# description: My domain rules
# globs: ["src/**/*.ts"]
# ---

# 4. Build code graph (once you have code)
code-review-graph build

# 5. Start working
claude
```

### Example Project CLAUDE.md (keep it lean)

```markdown
# My API Service

## Tech Stack
Go 1.22 + Fiber v2, PostgreSQL 16, Redis 7

## Commands
go run ./cmd/server          # Start server
go test ./...                # Run tests
docker compose up -d         # Start dependencies

## API Endpoints
POST /api/v1/users           # Create user
GET  /api/v1/users/:id       # Get user

## Domain Rules
- User emails must be unique (enforced at DB level)
- Soft delete only — never hard delete user records
```

---

## Setting Up an Existing Project

```bash
cd ~/Developer/existing-project

# 1. Add CLAUDE.md if missing
# Write: tech stack, commands, key files, domain rules (under 80 lines)

# 2. Build code graph
code-review-graph build
code-review-graph status

# 3. Add project rules (optional)
mkdir -p .claude/rules
# Add domain-specific rules

# 4. Start working
claude
```

---

## Available Skills

### /review-pr
Full PR review pipeline:
1. `detect_changes` — risk-scored diff analysis
2. `get_impact_radius` — blast radius
3. `get_affected_flows` — impacted user-facing paths
4. `query_graph(tests_for)` — test coverage gaps
5. `get_review_context` — token-efficient source snippets
6. Architecture boundary check
7. Large function detection
8. Security scan
9. Adversarial review
10. Risk-level report (LOW/MEDIUM/HIGH/CRITICAL)

### /new-service
Scaffold a new microservice:
- Asks for name, purpose, tech stack
- Generates SPEC.md first (SDD compliance)
- Creates DDD structure (domain/application/infrastructure/interface)
- Adds Dockerfile, .env.example, test scaffolding
- Generates OpenAPI spec

---

## Available Agents

### code-reviewer
Spawned for parallel code review on large changesets. Reviews for: correctness, security, performance, testing, architecture, style. Reports findings as CRITICAL/WARNING/INFO.

### security-auditor
Spawned for security-focused review. Checks for: injection, auth issues, secrets, input validation, dependency vulnerabilities, data exposure. Reports as CRITICAL/HIGH/MEDIUM/LOW.

---

## MCP Servers — The Power Layer

This setup uses two MCP (Model Context Protocol) servers that give Claude superpowers beyond basic file editing. They're configured globally in `~/.mcp.json` — every project gets them automatically.

### What is MCP?
MCP servers are external tools that Claude Code can call during conversations. They run as background processes and expose tools via JSON-RPC. Think of them as plugins that give Claude abilities it doesn't have natively.

---

### claude-flow — Multi-Agent Orchestration

**What it is:** An AI agent orchestration framework that lets Claude spawn, coordinate, and manage multiple parallel AI agents. Think of it as a "team manager" for Claude — instead of doing everything sequentially, Claude can delegate tasks to specialist agents that work in parallel.

**Install:**
```bash
# Already handled by ~/.mcp.json — auto-starts when needed
# Manual check:
npx -y @claude-flow/cli@latest --version
npx -y @claude-flow/cli@latest doctor --fix
```

**Why we use it:**
- **Parallel execution** — spawn 5-15 agents working simultaneously on different parts of a task
- **Persistent memory** — agents can store/retrieve knowledge across sessions (patterns, decisions, context)
- **Swarm coordination** — hierarchical-mesh topology ensures agents don't conflict or duplicate work
- **3-tier model routing** — simple tasks go to fast/cheap models, complex tasks go to Opus
- **Task management** — break work into trackable units with status tracking

**How it's configured (`~/.mcp.json`):**
```json
{
  "mcpServers": {
    "claude-flow": {
      "command": "npx",
      "args": ["-y", "@claude-flow/cli@latest", "mcp", "start"],
      "env": {
        "CLAUDE_FLOW_MODE": "v3",
        "CLAUDE_FLOW_TOPOLOGY": "hierarchical-mesh",
        "CLAUDE_FLOW_MAX_AGENTS": "15",
        "CLAUDE_FLOW_MEMORY_BACKEND": "hybrid"
      },
      "autoStart": false
    }
  }
}
```

**Key settings explained:**
| Setting | Value | Why |
|---|---|---|
| `CLAUDE_FLOW_MODE` | v3 | Latest version with best orchestration |
| `CLAUDE_FLOW_TOPOLOGY` | hierarchical-mesh | Leader coordinates, agents can communicate peer-to-peer |
| `CLAUDE_FLOW_MAX_AGENTS` | 15 | Cap to prevent runaway spawning |
| `CLAUDE_FLOW_MEMORY_BACKEND` | hybrid | Uses both in-memory (fast) and persistent (durable) storage |
| `autoStart` | false | Only starts when Claude actually needs it (saves resources) |

**Context optimization:**
claude-flow exposes 254 tools but we set `ENABLE_TOOL_SEARCH=auto:0` in settings.json. This means:
- Only tool **names** load at startup (minimal tokens)
- Full tool **schemas** load on-demand when Claude needs them
- No wasted context on tools you never use in a session

**Essential tools (daily use):**

| Tool Group | Tools | When to Use |
|---|---|---|
| **Agent** | `agent_spawn`, `agent_status`, `agent_list`, `agent_terminate` | Spawn parallel workers for large tasks |
| **Memory** | `memory_store`, `memory_search`, `memory_retrieve`, `memory_list` | Persist knowledge across agents and sessions |
| **Task** | `task_create`, `task_assign`, `task_status`, `task_complete` | Break work into trackable units |
| **Swarm** | `swarm_init`, `swarm_status`, `swarm_health`, `swarm_shutdown` | Coordinate multi-agent teams |
| **Hooks** | `hooks_route`, `hooks_model-route` | Route tasks to the right model tier |
| **System** | `system_status`, `system_health` | Diagnostics |

**Useful tools (weekly):**

| Tool Group | When to Use |
|---|---|
| `analyze_diff*` | Pre-commit code review with risk scoring |
| `github_*` | PR management, issue tracking, CI workflow automation |
| `workflow_*` | Complex multi-step automation pipelines |
| `hive-mind_*` | Multi-agent consensus for architectural decisions |
| `session_*` | Save/restore agent state across conversations |
| `embeddings_*` | Semantic similarity search across codebase |

**Skip (rarely needed):**
`agentdb_*`, `autopilot_*`, `wasm_*`, `ruvllm_*`, `transfer_*`, `claims_*`, `neural_*`, `daa_*`

**Usage patterns:**
```
# Claude automatically uses claude-flow when you give it complex tasks:

"Build a user authentication service with JWT, password hashing, and email verification"
→ Claude runs swarm_init
→ Spawns agents: coder (implementation), tester (tests), reviewer (quality)
→ All work in parallel
→ Results merged and reviewed

"Review this PR for security issues"
→ Claude spawns security-auditor agent
→ Uses analyze_diff for risk scoring
→ Parallel security + code review
```

**Orchestration rules (enforced by CLAUDE.md):**
1. Always `swarm_init` before spawning multiple agents
2. Spawn ALL agents in ONE message (parallel, not sequential)
3. After spawning, STOP — don't poll status, wait for results
4. Use `hooks_model-route` for 3-tier routing (fast model for simple tasks)

---

### code-review-graph — Structural Code Analysis

**What it is:** A code intelligence tool that builds a knowledge graph of your codebase — every function, class, import, call relationship, and execution flow. Claude uses this graph instead of grep/read to understand code structurally.

**Install:**
```bash
pipx install code-review-graph
# Verify:
code-review-graph --version
```

**Why we use it:**
- **Faster than grep** — structured queries vs text search
- **Cheaper** — fewer tokens than reading entire files
- **Structural context** — callers, callees, test coverage, module boundaries
- **Risk scoring** — automatically scores changes by blast radius and test gaps
- **Architecture detection** — identifies code clusters and community boundaries

**How it's configured (`~/.mcp.json`):**
```json
{
  "mcpServers": {
    "code-review-graph": {
      "command": "code-review-graph",
      "args": ["serve"],
      "type": "stdio"
    }
  }
}
```

**Setup per project (one-time):**
```bash
cd ~/Developer/your-project
code-review-graph build          # Full graph build (parses all files)
code-review-graph status         # Verify: shows node/edge counts
```

After initial build, the `auto-graph-update.sh` hook keeps it fresh — incremental updates on every file edit.

**22 tools, organized by frequency:**

**Every PR (daily):**

| Tool | What It Does | Replaces |
|---|---|---|
| `detect_changes` | Risk-scored diff analysis with blast radius | Manual diff reading |
| `get_review_context` | Token-efficient source snippets for review | Reading entire files |
| `get_impact_radius` | What else breaks when you change something | Manually tracing imports |
| `query_graph` | Trace callers, callees, tests, imports | Grep + manual tracing |
| `semantic_search_nodes` | Find code by intent, not just name | Grep for keywords |

**Architecture (weekly):**

| Tool | What It Does |
|---|---|
| `get_architecture_overview` | High-level codebase structure from detected communities |
| `list_communities` | Auto-detected code clusters (Leiden algorithm) |
| `get_affected_flows` | Which user-facing execution paths break from a change |
| `find_large_functions` | Flag oversized functions for refactoring |

**Refactoring (on-demand):**

| Tool | What It Does |
|---|---|
| `refactor_tool` | Preview renames, find dead code, get suggestions |
| `apply_refactor_tool` | Apply previewed refactoring edits |
| `build_or_update_graph` | Rebuild graph (after major changes) |
| `embed_graph` | Compute vector embeddings for semantic search (one-time) |

**Usage patterns:**
```
# Instead of: grep -r "functionName" src/
Claude uses: semantic_search_nodes("functionName")
→ Gets: function location + callers + callees + test coverage

# Instead of: manually reading 20 files to understand a change
Claude uses: detect_changes → get_impact_radius → get_affected_flows
→ Gets: risk score, blast radius, affected user flows, test gaps

# Instead of: "what does this codebase do?"
Claude uses: get_architecture_overview → list_communities
→ Gets: module boundaries, coupling metrics, architectural layers
```

**CLI commands (for manual use):**
```bash
code-review-graph build           # Full rebuild
code-review-graph update          # Incremental update (fast)
code-review-graph status          # Graph health check
code-review-graph detect-changes  # CLI version of detect_changes
code-review-graph visualize       # D3 interactive visualization
```

---

### How Both Tools Work Together

```
You describe a task
        │
        ▼
Claude uses code-review-graph to UNDERSTAND the codebase
  ├── semantic_search_nodes → find relevant code
  ├── query_graph → understand dependencies
  ├── get_architecture_overview → see the big picture
        │
        ▼
Claude uses claude-flow to EXECUTE the work
  ├── swarm_init → set up coordination
  ├── agent_spawn (coder) → implement changes
  ├── agent_spawn (tester) → write tests in parallel
  ├── memory_store → persist decisions for other agents
        │
        ▼
Claude uses code-review-graph to VERIFY the changes
  ├── detect_changes → risk-scored analysis
  ├── get_impact_radius → blast radius check
  ├── query_graph(tests_for) → test coverage verification
        │
        ▼
Claude runs /codex:adversarial-review to VALIDATE
  └── Loops until no critical issues remain
```

---

## Contextual Rules

Rules load automatically based on which files you're editing:

| Rule File | Loads When Editing | Key Rules |
|---|---|---|
| `security.md` | *.ts, *.js, *.py, *.go, *.rs | No secrets, validate inputs, least privilege, no eval() |
| `testing.md` | tests/**, *.test.*, *.spec.* | 100% coverage, deterministic, unit+integration+E2E |
| `api-design.md` | routes/**, handlers/**, api/** | OpenAPI docs, versioned APIs, strict contracts |
| `docker.md` | Dockerfile*, docker-compose*, .env* | Multi-stage builds, health checks, pinned versions |

---

## Customizing for Your Team

### Add team-specific rules
```bash
# Create new rule file in ~/.claude/rules/
cat > ~/.claude/rules/my-team.md << 'EOF'
---
description: Team-specific conventions
globs: ["**/*.ts", "**/*.py"]
---

- All PRs require at least 2 approvals
- Use conventional commits (feat:, fix:, chore:)
- Branch naming: feature/<ticket-id>-<description>
EOF
```

### Add team-specific skills
```bash
mkdir -p ~/.claude/skills/my-skill
cat > ~/.claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does
user-invocable: true
---

# My Skill
Steps for Claude to follow when /my-skill is invoked...
EOF
```

### Modify permissions
Edit `~/.claude/settings.json` → `permissions` section:
- `allow`: Auto-approved commands
- `ask`: Prompts before running
- `deny`: Permanently blocked

### Add project-level overrides
Create `.claude/settings.json` inside any project for project-specific hooks, permissions, or env vars. These merge with (and override) global settings.

---

## Troubleshooting

### Hooks not firing
```bash
# Verify hooks are executable
ls -la ~/.claude/hooks/
# All should show rwxr-xr-x

# Check hook syntax
bash -n ~/.claude/hooks/auto-lint.sh
```

### code-review-graph not working
```bash
# Rebuild graph
cd <project> && code-review-graph build

# Check status
code-review-graph status
```

### Too many permission prompts
Add the command pattern to `settings.json` → `permissions.allow`:
```json
"Bash(my-command *)"
```

### claude-flow using too much context
Already mitigated: `ENABLE_TOOL_SEARCH=auto:0` defers all tool schemas. Only names load at startup.

### Keybinding conflicts
```bash
# Inside Claude Code:
/doctor
# Shows any keybinding warnings
```

---

## File Sizes (Anthropic Best Practices)

| File | Lines | Recommendation |
|---|---|---|
| Global CLAUDE.md | 42 | Under 200 (ideally under 100) |
| Project CLAUDE.md | 50-80 | Under 200 (project-specific only) |
| settings.json | ~200 | Keep permissions concise with wildcards |
| Each rule file | 10-15 | Short, focused, contextual |

---

## Uninstall

```bash
# Restore backups (created during install)
ls ~/.claude/*.backup.*
# Manually restore whichever you need

# Or remove everything
rm ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/keybindings.json
rm -rf ~/.claude/hooks ~/.claude/rules ~/.claude/skills ~/.claude/agents ~/.claude/templates
rm ~/.mcp.json
```
