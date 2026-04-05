---
description: Git workflow and commit conventions
globs: ["**/.gitignore", "**/CHANGELOG*", "**/.github/**"]
---

- Commit messages: imperative mood, <72 chars subject, blank line before body
- Branch naming: `feat/`, `fix/`, `chore/`, `refactor/` prefixes
- Never commit secrets, .env files, or large binaries
- Prefer small, focused commits over large monolithic ones
- Always pull before pushing to shared branches
- Resolve merge conflicts rather than discarding changes
