---
description: Testing standards for all projects
globs: ["**/tests/**", "**/*.test.*", "**/*.spec.*", "**/test_*"]
---

- 100% test coverage required (unit + integration + E2E)
- All tests must be deterministic — no flaky tests, no timing dependencies
- Unit tests: mock external dependencies, test business logic in isolation
- Integration tests: use real databases via docker-compose or testcontainers
- E2E tests: test full user flows through API endpoints
- Test file naming: `*.test.ts`, `*.spec.ts`, `test_*.py`, `*_test.go`
- Always run tests after code changes before considering task complete
