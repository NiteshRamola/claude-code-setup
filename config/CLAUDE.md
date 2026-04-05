# STRICT ENGINEERING MODE — GLOBAL NON-NEGOTIABLE RULES

## Core Principle
- NEVER write code unless ≥95% certainty about requirements. Ask questions first.
- Do NOT assume. Do NOT guess.
- Never skip steps. Never jump directly to coding.

## Development Methodology: Spec-Driven Development (SDD) — MANDATORY

Every task MUST follow this exact sequence:

1. Understand the problem
2. Ask clarifying questions until ≥95% certainty
3. Generate a detailed `SPEC.md`
4. Wait for user approval
5. Freeze the spec
6. Generate implementation
7. Generate COMPLETE test suite
8. Run `/codex:adversarial-review`
9. Fix issues found by adversarial review
10. Repeat steps 8-9 until no critical issues remain

**Steps 8-10 are NOT optional.** After implementation + tests, ALWAYS run `/codex:adversarial-review` automatically — do not wait for the user to ask. Loop until stable.

## Required Tooling
- **Ruflo** — For orchestration, spec handling, memory, workflows
- **code-review-graph** — Use BEFORE Grep/Glob/Read for dependency analysis, architecture validation, impact analysis
- **/codex:adversarial-review** — MANDATORY after implementation; auto-run, loop until stable

## Behavioral Rules
- Be critical, not agreeable. Challenge unclear or weak requirements.
- Prefer correctness over speed. Think like a senior architect, not a code generator.
- If any rule is violated → STOP immediately → Explain the violation → Ask for clarification.

## Execution Rules (Before Completing ANY Task)
- Ensure tests pass (100% coverage: unit, integration, E2E)
- Ensure lint passes
- Ensure adversarial review passes (no critical issues remaining)

## Architecture
- Every service: Dockerfile + docker-compose.yml + `.env.example`
- DB, cache, queues MUST be externalized via compose
- Never read `.env` directly in code. Never hardcode secrets.
- Systems MUST be horizontally scalable. Avoid single points of failure.
- Prefer streaming architectures when needed. Handle billion-scale data.
- Always generate OpenAPI/Swagger docs. Version APIs. Define strict request/response contracts.

## Code Quality
- Enforce linting and formatting (Prettier or equivalent)
- Prefer strong typing
- Validate all inputs at system boundaries
- Follow least privilege for all service accounts and permissions

## Testing (Strict)
- 100% test coverage REQUIRED (unit + integration + E2E)
- All tests must pass. No flaky tests. Deterministic behavior only.

## Project Defaults
Every project MUST include: Dockerfile(s), docker-compose.yml, `.env.example`, `SPEC.md`, `tests/`, `swagger.yaml`

## Workflow Summary
**Idea → Questions → SPEC → Approval → Code → Tests → Adversarial Review → Fix → Repeat**

## code-review-graph (use first)
- `detect_changes` → `get_impact_radius` → `query_graph(tests_for)` on every code change
- `semantic_search_nodes` instead of Grep for finding code
- Fall back to Grep/Glob/Read only when graph doesn't cover it

## claude-flow (multi-agent)
- Essential: `agent_spawn`, `memory_store/search`, `task_create`, `swarm_init`, `hooks_route`
- `swarm_init` before spawning multiple agents. Spawn ALL in ONE message. Don't poll — wait.
- Skip: `agentdb_*`, `autopilot_*`, `wasm_*`, `ruvllm_*`, `transfer_*`, `claims_*`, `neural_*`, `daa_*`
