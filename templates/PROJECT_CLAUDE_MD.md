# Project: {{PROJECT_NAME}}

## Workflow: SDD (Mandatory)
Questions → SPEC.md → Approval → Code → Tests → `/codex:adversarial-review` (auto) → Fix → Repeat until stable

## Overview
<!-- Brief description of what this project does -->

## Tech Stack
<!-- e.g., Python 3.11, FastAPI, PostgreSQL, Redis, Docker -->

## Architecture
<!-- Key architectural decisions, patterns used -->

## Project Structure
```
├── src/            # Application source code
├── tests/          # Test suite (unit, integration, e2e)
├── docker/         # Dockerfiles
├── docs/           # Documentation
├── .env.example    # Environment variables template
├── docker-compose.yml
├── SPEC.md         # Frozen specification
└── swagger.yaml    # API documentation
```

## Commands
```bash
# Development
docker compose up -d          # Start all services
docker compose logs -f        # Follow logs

# Testing
npm test                      # or: python -m pytest
npm run test:coverage         # Full coverage report

# Linting & Formatting
npm run lint                  # or: python -m flake8
npm run format                # or: python -m black .

# Build
docker compose build          # Build all containers
```

## Conventions
- All new features require a SPEC.md before implementation
- 100% test coverage required
- No secrets in code — use .env.example as template
- All services containerized via docker-compose
- APIs documented in swagger.yaml / OpenAPI spec
- Follow SDD workflow: Spec → Approval → Code → Tests → Review

## Database
<!-- DB type, migration tool, seed data instructions -->

## Environment Variables
<!-- Reference .env.example, describe required vars -->

## Known Issues / Tech Debt
<!-- Track issues that need attention -->
