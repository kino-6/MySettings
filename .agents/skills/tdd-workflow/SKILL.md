---
name: tdd-workflow
description: Use when strict TDD discipline is explicitly needed: red-green-refactor, coverage gates, and coordinated unit/integration/E2E test planning. For ordinary behavior changes, prefer test-driven-development.
origin: ECC
---

# TDD Workflow

Use this skill when the user or task calls for strict test-first development,
coverage thresholds, full red-green-refactor discipline, or coordinated
unit/integration/E2E planning.

For ordinary bug fixes and behavior changes where tests should prove the
result, use `test-driven-development` as the default. This skill is the stricter
coverage-and-process variant.

## Workflow

1. Define the user-visible behavior or regression being protected.
2. Write the failing test first, or explain why the architecture prevents it.
3. Run the targeted test and confirm the expected failure.
4. Implement the smallest change that makes the test pass.
5. Refactor only after green tests.
6. Run coverage or broader checks when the task requires a gate.
7. Load `references/full-guide.md` for detailed examples and test patterns.

## Reference

- `references/full-guide.md` preserves the original detailed guide with
  activation criteria, core principles, workflow steps, Jest/Vitest examples,
  API integration tests, Playwright E2E examples, test organization, mocks,
  coverage thresholds, common mistakes, watch mode, pre-commit, CI, and success
  metrics.
