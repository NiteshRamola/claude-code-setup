---
description: Container and infrastructure rules
globs: ["**/Dockerfile*", "**/docker-compose*", "**/.env*", "**/infrastructure/**"]
---

- Every service must have a Dockerfile with multi-stage builds
- Local dev must use docker-compose with all dependencies (DB, cache, queues)
- Always create `.env.example` with all required variables (no real values)
- Health checks required for all docker-compose services
- Pin base image versions (no `:latest` tags)
- Externalize all stateful services (databases, caches, message queues)
