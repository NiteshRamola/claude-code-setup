# Project: {{PROJECT_NAME}}

## Workflow
SDD: Questions → SPEC.md → Approval → Code → Tests → `/codex:adversarial-review` → Fix → Repeat

## Tech Stack

## Architecture

## Project Structure
```
├── src/
├── tests/
├── docker/
├── .env.example
├── docker-compose.yml
├── SPEC.md
└── swagger.yaml
```

## Commands
```bash
docker compose up -d          # Start dependencies
npm test                      # Run tests
npm run lint                  # Lint
docker compose build          # Build
```

## Conventions
- SPEC.md required before new features
- High test coverage on business logic, edge cases, error paths
- No secrets in code — use .env.example
- All services containerized
- APIs documented in OpenAPI spec

## Database

## Environment Variables

## Known Issues / Tech Debt
