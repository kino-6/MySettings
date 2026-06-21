# ECC Structured Workflow

This directory captures useful agent-harness patterns without installing an
external harness or reserving vendor-owned workflow namespaces.

Use it for work that benefits from durable task context, explicit verification,
or a session-ending review ritual. Small one-shot edits can continue to use the
normal ECC / Codex flow.

## Layout

- `spec/`: durable repository standards and reusable project knowledge.
- `templates/task/`: task artifact templates for structured work.
- `tasks/`: optional task folders, usually named `YYYY-mm-dd-short-slug/`.
- `workspace/`: local session journals. This directory is gitignored except for
  its README because journals may include machine-specific notes.

## Task Lifecycle

1. Start with `ecc-task-workflow` when the work is broad, risky, or likely to
   span multiple sessions.
2. Create a task folder under `.agents/ecc-workflow/tasks/` when durable task
   artifacts would make the work easier to resume or review.
3. Keep the task folder small: `prd.md`, `implement.md`, and `check.md` are
   enough for most changes.
4. Use `ecc-final-check` before summarizing substantial work.
5. Use `ecc-finish-work` when a task is done or context is filling up.

## Guardrails

- Do not install or run external harness tooling from this workflow.
- Do not create vendor-owned workflow directories unless the user explicitly
  asks for a trial.
- Keep secrets, host credentials, and private machine state out of tracked task
  artifacts.
- Treat networked tools as read-only unless the user explicitly approves an
  external action.
- Preserve the existing ECC baseline in `.codex/config.toml`; add heavier tools
  only when a concrete task needs them.

## Verification

Before finishing a structured task, check:

- The diff is scoped to the task.
- Relevant tests, linters, or smoke checks were run, or the reason they were not
  run is recorded.
- New durable learning belongs in `spec/`, not only in a chat transcript.
- Follow-up work is recorded in the task folder or final response.
