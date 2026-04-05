---
name: review-pr
description: Run a comprehensive PR review using code-review-graph and adversarial review
user-invocable: true
---

# PR Review Skill

Run a thorough code review on the current branch's changes.

## Steps:

1. **Detect changes**: Use `detect_changes` from code-review-graph to get risk-scored diff analysis
2. **Impact analysis**: Use `get_impact_radius` to understand blast radius of changes
3. **Flow analysis**: Use `get_affected_flows` to identify which user-facing paths are impacted
4. **Test coverage check**: Use `query_graph` with pattern `tests_for` on changed functions
5. **Review context**: Use `get_review_context` to get token-efficient source snippets
6. **Architecture check**: Verify changes don't violate community/module boundaries via `list_communities`
7. **Large function check**: Use `find_large_functions` on changed files
8. **Security scan**: Check for secrets, injection vectors, input validation gaps
9. **Adversarial review**: Run `/codex:adversarial-review` — this is MANDATORY, not optional
10. **Fix issues**: Fix all CRITICAL and HIGH issues found
11. **Repeat**: Run `/codex:adversarial-review` again — loop until no critical issues remain
12. **Report**: Summarize findings with risk level (LOW/MEDIUM/HIGH/CRITICAL)

## Output format:
```
## PR Review: [branch name]
### Risk: [LOW/MEDIUM/HIGH/CRITICAL]
### Changes: [N files, N functions]
### Impact radius: [N affected files]
### Test coverage gaps: [list]
### Security issues: [list]
### Recommendations: [list]
```
