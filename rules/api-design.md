---
description: API design standards
globs: ["**/routes/**", "**/handlers/**", "**/controllers/**", "**/interface/**", "**/api/**"]
---

- Always generate OpenAPI/Swagger documentation alongside API code
- Version all APIs (e.g., `/api/v1/`)
- Define strict request/response contracts with validation (Zod, Pydantic, Go struct tags)
- Use consistent error response format across all endpoints
- Pagination required for list endpoints returning >50 items
- Rate limiting on all public endpoints
