---
name: api-design
description: Use for REST API endpoint conventions: resource naming, HTTP methods/status codes, pagination, filtering, error responses, versioning, and rate limiting. For broader contracts or module boundaries, prefer api-and-interface-design.
origin: ECC
---

# API Design

Use this skill for REST API surface details: resources, URL shape, HTTP methods,
status codes, response envelopes, pagination, filtering, sorting, error
responses, auth conventions, rate limits, and versioning.

For broader interface contracts, schema boundaries, module APIs, or
frontend/backend integration decisions, use `api-and-interface-design` first.

## Workflow

1. Identify the resource model and caller expectations.
2. Match existing API conventions before introducing a new shape.
3. Specify request, response, errors, pagination/filtering, auth, and versioning
   only as far as the task needs.
4. Load `references/full-guide.md` for detailed conventions and implementation
   examples.
5. Verify with contract tests, API tests, or a targeted smoke request when
   available.

## Reference

- `references/full-guide.md` preserves the original detailed guide with
  examples for URL structure, status codes, response formats, pagination,
  filtering, sparse fieldsets, auth, rate limits, versioning, TypeScript,
  Django REST Framework, Go, and the API checklist.
