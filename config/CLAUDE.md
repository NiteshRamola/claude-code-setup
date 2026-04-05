# STRICT ENGINEERING MODE — GLOBAL RULES

## Core Principle
- NEVER write code unless ≥95% certainty about requirements. Ask questions first.
- Do NOT assume. Do NOT guess.
- Be critical, not agreeable. Challenge unclear or weak requirements.
- Prefer correctness over speed. Think like a senior architect, not a code generator.
- If any rule is violated → STOP → Explain the violation → Ask for clarification.

## Spec-Driven Development (SDD)

**Full SDD** (>3 files or new functionality):
Understand → Questions → SPEC.md → User Approval → Code → Tests → `/codex:adversarial-review` → Fix → Loop until stable

**Quick path** (≤3 files, no new behavior — typos, renames, config, log lines):
Understand → Implement → Verify (lint + tests pass)

Steps 8-10 of full SDD are NOT optional. After implementation + tests, ALWAYS auto-run `/codex:adversarial-review`.

## Tooling Priority
1. **code-review-graph** — Use BEFORE Grep/Glob/Read: `detect_changes` → `get_impact_radius` → `query_graph(tests_for)`. Use `semantic_search_nodes` instead of Grep. Fall back to Grep/Glob/Read only when graph doesn't cover it.
2. **Ruflo / claude-flow** — Essential: `agent_spawn`, `memory_store/search`, `task_create`, `swarm_init`, `hooks_route`, `hive-mind_*` (consensus, broadcast, shared memory for multi-agent decisions). `swarm_init` before spawning multiple agents. Spawn ALL in ONE message. Don't poll — wait.
3. **/codex:adversarial-review** — MANDATORY after full SDD implementation. On re-runs, scope review to changed files only — do NOT re-review unchanged code. Exit loop when no CRITICAL or HIGH issues remain (INFO/WARNING can be addressed separately).

## Execution Rules (Before Completing ANY Task)
- Ensure tests pass (high coverage on business logic, edge cases, error paths)
- Ensure lint passes
- Ensure adversarial review passes on full SDD tasks (no CRITICAL/HIGH issues remaining)
