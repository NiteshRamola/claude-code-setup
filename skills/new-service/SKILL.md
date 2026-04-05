---
name: new-service
description: Scaffold a new microservice following SDD and project conventions
user-invocable: true
---

# New Service Scaffolding

Create a new microservice following Spec-Driven Development.

## Before scaffolding:
1. Ask for service name, purpose, and domain
2. Confirm tech stack (default: TypeScript/Express or Go/Fiber)
3. Generate SPEC.md and get approval before writing any code

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
├── Dockerfile            # Multi-stage build
├── package.json
├── tsconfig.json
├── .env.example
└── SPEC.md               # Frozen specification
```

## Scaffold structure (Go):
```
services/<name>/
├── cmd/                  # Entry point
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

## After scaffolding:
1. Add service to docker-compose.yml
2. Generate OpenAPI spec at docs/api/<name>.openapi.yaml
3. Write initial test suite (unit + integration)
4. Update root README if it exists
