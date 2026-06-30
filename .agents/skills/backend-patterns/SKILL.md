---
name: backend-patterns
description: Use when implementing server-side behavior in Node.js, Express, Next.js API routes, or similar backends: services, repositories, middleware, database access, caching, jobs, logging, and auth integration.
---

# Backend Patterns

Use this skill for backend implementation structure: services, repositories,
middleware, data access, transactions, caching, retries, auth integration, rate
limits, background jobs, and structured logging.

For public contract design, use `api-and-interface-design`; for REST endpoint
surface details, use `api-design`; for database-specific schema/migration work,
use the relevant database skill.

## Workflow

1. Inspect the existing backend shape and naming before adding a pattern.
2. Choose the narrowest implementation pattern that fits the current codebase.
3. Keep abstractions earned by real duplication or boundary complexity.
4. Load `references/full-guide.md` only when you need detailed implementation
   examples.
5. Verify with targeted tests or smoke checks for the touched server behavior.

## Reference

- `references/full-guide.md` preserves the original detailed guide with
  examples for REST structure, repository and service layers, middleware,
  query optimization, transactions, caching, errors, retries, auth, rate
  limiting, queues, and logging.
