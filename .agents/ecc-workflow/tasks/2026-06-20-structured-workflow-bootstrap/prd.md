# PRD

## Goal

Add a lightweight workflow inspired by external agent-harness patterns to this
ECC dotfiles repository without installing extra harness tooling or creating
vendor-owned workflow directories.

## Background

The repo already has project-local ECC assets:

- `.codex/config.toml`
- `.codex/AGENTS.md`
- `.codex/agents/`
- `.agents/skills/`

External agent harnesses are valuable as patterns for durable specs, task
artifacts, final checks, and session journals, but a full generated setup may
overlap with the existing ECC baseline.

## Scope

In scope:

- Add a small workflow directory under `.agents/ecc-workflow/`.
- Add templates for `prd.md`, `implement.md`, `check.md`, and `journal.md`.
- Add skills that trigger task setup, final checks, and finish-work behavior.
- Document the workflow in `.codex/AGENTS.md` and `README.md`.
- Avoid installing external harness tooling or generating vendor-owned workflow
  directories.

Out of scope:

- Running external harness install commands.
- Running external harness init commands.
- Replacing existing ECC skills, agents, or MCP configuration.
- Committing or pushing the branch.

## Acceptance Criteria

- The branch contains a clear structured workflow that can be reviewed as a
  normal repo diff.
- Future sessions can discover when to use the workflow.
- Local/private journals are not accidentally tracked.
- The README states that this is not a full external harness install.

## Risks

- Adding too many skills could make the repo feel noisy.
- Using vendor-owned workflow directory names would conflict with a future
  full-tool trial.
- Journals could accidentally capture private host state if tracked.
