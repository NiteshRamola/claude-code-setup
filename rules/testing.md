---
description: Testing standards for all projects
globs: ["**/tests/**", "**/*.test.*", "**/*.spec.*", "**/test_*"]
---

- High test coverage required on business logic, edge cases, and error paths (unit + integration + E2E). Skip trivial accessors and framework boilerplate.
- All tests must be deterministic — no flaky tests, no timing dependencies
- Unit tests: mock external dependencies, test business logic in isolation
- Integration tests: use real databases via docker-compose or testcontainers
- E2E tests: test full user flows through API endpoints
- Test file naming: `*.test.ts`, `*.spec.ts`, `test_*.py`, `*_test.go`
- Always run tests after code changes before considering task complete
