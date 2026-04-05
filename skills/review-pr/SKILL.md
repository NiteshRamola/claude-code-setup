---
name: review-pr
description: Run a comprehensive PR review using code-review-graph and adversarial review
user-invocable: true
---

# PR Review Skill

Run a thorough code review on the current branch's changes using parallel subagents to minimize main context pollution.

## Phase 1 — Parallel Analysis (use subagents)

Spawn BOTH agents in a SINGLE message to run in parallel:

### code-reviewer agent (steps 1-7):
1. `detect_changes` — risk-scored diff analysis
2. `get_impact_radius` — blast radius
3. `get_affected_flows` — impacted user-facing paths
4. `query_graph(tests_for)` — test coverage gaps
5. `get_review_context` — token-efficient source snippets
6. `list_communities` — architecture boundary check
7. `find_large_functions` — flag oversized functions

Output: summarized findings under 5000 tokens (CRITICAL/WARNING/INFO with file:line).

### security-auditor agent (step 8):
8. Security scan — secrets, injection vectors, input validation gaps

Output: summarized findings under 5000 tokens (CRITICAL/HIGH/MEDIUM/LOW with file:line).

## Phase 2 — Main Context (steps 9-12)

After both agents return their summaries (NOT raw graph data):

9. **Adversarial review**: Run `/codex:adversarial-review` scoped to changed files only
10. **Fix issues**: Fix all CRITICAL and HIGH issues found
11. **Repeat**: Re-run adversarial review on diffs only — loop until no CRITICAL/HIGH remain
12. **Report**: Summarize with risk level

## Output format:
```
## PR Review: [branch name]
### Risk: [LOW/MEDIUM/HIGH/CRITICAL]
### Changes: [N files, N functions]
### Impact radius: [N affected files]
### Code Review Findings: [from code-reviewer agent]
### Security Findings: [from security-auditor agent]
### Test coverage gaps: [list]
### Adversarial review: [PASS/FAIL + remaining issues]
### Recommendations: [list]
```
