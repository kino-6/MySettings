---
name: ecc-task-workflow
description: Use when starting broad, risky, multi-file, or multi-session work in this repo. Creates lightweight structured task context without installing external harness tooling.
---

# ECC Task Workflow

Use this skill when the user asks to structure work, when a change affects
agent behavior or durable repo automation, or when the task may span sessions.

## Workflow

1. Read `.agents/ecc-workflow/README.md`.
2. Read relevant files in `.agents/ecc-workflow/spec/`.
3. Decide whether a task folder is useful. Skip it for tiny tasks.
4. If useful, create `.agents/ecc-workflow/tasks/YYYY-mm-dd-short-slug/` with:
   - `prd.md`
   - `implement.md`
   - `check.md`
5. Keep artifacts concise. They should preserve decisions, scope, acceptance
   criteria, and verification, not duplicate the whole chat.
6. Continue normal Codex work: inspect, edit, verify, summarize.

## Artifact Rules

- Use `.agents/ecc-workflow/templates/task/` as the starting shape.
- Do not create vendor-owned workflow directories.
- Do not install external harness tooling.
- Do not store secrets or host-private state in tracked task files.
- Promote stable lessons to `.agents/ecc-workflow/spec/` only when they will
  help future sessions.
