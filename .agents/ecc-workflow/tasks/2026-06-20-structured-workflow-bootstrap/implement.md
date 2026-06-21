# Implementation Notes

## Relevant Context

- The user asked to try the lightweight approach first and work on a branch.
- Existing ECC structure is already substantial, so changes should be additive.
- External harness docs describe full systems with specs, tasks, workspace
  memory, skills, sub-agents, and platform adapters; this task only borrows the
  durable workflow pattern.

## Files To Inspect

- `.codex/AGENTS.md`
- `.codex/config.toml`
- `.codex/agents/`
- `.agents/skills/`
- `README.md`

## Plan

1. Create a short-lived branch.
2. Add `.agents/ecc-workflow/` with specs, templates, tasks, and workspace docs.
3. Add three small skills: task workflow, final check, finish work.
4. Add `.gitignore` rules for local workspace journals.
5. Document the workflow in `.codex/AGENTS.md` and `README.md`.
6. Review the diff and record verification in `check.md`.

## Decisions

- Use `.agents/ecc-workflow/` instead of vendor-owned workflow names to leave
  room for a future full-tool trial.
- Track specs, templates, skills, and task artifacts.
- Ignore `.agents/ecc-workflow/workspace/*` because journals may be private or
  machine-specific.

## Verification Plan

- Inspect `git status --short --branch`.
- Inspect the diff for README, `.codex/AGENTS.md`, `.gitignore`, and new files.
- Check that the ignored workspace rule still allows `workspace/README.md`.
