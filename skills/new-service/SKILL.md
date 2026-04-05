---
name: new-service
description: Scaffold a new microservice following SDD and project conventions
user-invocable: true
---

# New Service Scaffolding

Create a new microservice following Spec-Driven Development using parallel subagents.

## Before scaffolding:
1. Ask for service name, purpose, and domain
2. Confirm tech stack (default: TypeScript/Express or Go/Fiber)
3. Generate SPEC.md and get approval before writing any code

## Phase 1 — Parallel Scaffolding (use subagents)

Spawn BOTH agents in a SINGLE message after spec approval:

### code-reviewer agent (as scaffolder):
- Create DDD directory structure (domain/application/infrastructure/interface)
- Generate Dockerfile (multi-stage build, pinned base image)
- Generate docker-compose.yml entry
- Create .env.example with all required variables
- Generate OpenAPI spec at docs/api/<name>.openapi.yaml
- Write entry point and core boilerplate

Output: list of files created with brief description of each.

### security-auditor agent (as test scaffolder):
- Create test directory structure (unit/integration/api)
- Write initial unit test stubs for domain entities
- Write integration test setup (testcontainers/docker-compose)
- Write API test stubs for each endpoint in the OpenAPI spec

Output: list of test files created with coverage targets.

## Phase 2 — Main Context (verification)

After both agents return:
1. Verify all files are consistent (imports resolve, configs match)
2. Add service to root docker-compose.yml if it exists
3. Update root README if it exists
4. Run `/codex:adversarial-review` scoped to the new service directory
5. Fix any CRITICAL/HIGH issues, loop until clean

## Scaffold structure (TypeScript):
```
services/<name>/
├── src/
│   ├── domain/           # Entities, value objects, business logic
│   ├── application/      # Use cases, DTOs
│   ├── infrastructure/   # Database, external APIs, repositories
│   └── interface/        # Express routes, HTTP contracts
├── tests/
│   ├── unit/
│   ├── integration/
│   └── api/
├── Dockerfile
├── package.json
├── tsconfig.json
├── .env.example
└── SPEC.md
```

## Scaffold structure (Go):
```
services/<name>/
├── cmd/
├── internal/
│   ├── domain/
│   ├── handler/
│   ├── repository/
│   └── service/
├── tests/
├── Dockerfile
├── go.mod
├── .env.example
└── SPEC.md
```
