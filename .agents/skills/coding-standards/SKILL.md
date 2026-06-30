---
name: coding-standards
description: Baseline cross-project coding conventions for naming, readability, immutability, and code-quality review. Use detailed frontend or backend skills for framework-specific patterns.
origin: ECC
---

# Coding Standards

Use this skill for general code-quality expectations that apply across
languages and frameworks: readability, simplicity, naming, immutability,
error handling, comments, tests, and code smell detection.

Prefer framework-specific skills for detailed frontend, backend, API, security,
or performance guidance. This skill should keep the baseline small and avoid
becoming a second copy of every domain checklist.

## Workflow

1. Read the files being changed and follow local style first.
2. Keep the diff scoped to the user's task.
3. Prefer clear, boring code over premature abstraction.
4. Check naming, error handling, type safety, comments, tests, and obvious code
   smells before handoff.
5. Load `references/full-guide.md` only when a detailed baseline checklist or
   example is needed.

## Reference

- `references/full-guide.md` preserves the original detailed guide with
  examples for naming, immutability, async/await, type safety, React basics,
  REST response shape, validation, file organization, documentation, testing,
  performance, and code smells.
