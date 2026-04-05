---
description: Security rules for all code changes
globs: ["**/*.ts", "**/*.js", "**/*.py", "**/*.go", "**/*.rs", "**/*.java"]
---

- No secrets, API keys, or credentials in source files
- Use environment injection via `.env` (never read `.env` directly — use config loaders)
- Validate all user inputs at system boundaries
- Sanitize file paths to prevent directory traversal
- Follow least privilege for all service accounts and permissions
- No `eval()`, no dynamic SQL without parameterized queries
- Dependencies must be pinned to exact versions
