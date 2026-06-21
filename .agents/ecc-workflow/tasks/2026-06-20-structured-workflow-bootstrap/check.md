# Check

## Diff Scope

- Added `.agents/ecc-workflow/` docs, specs, templates, and a bootstrap task.
- Added three workflow skills under `.agents/skills/ecc-*`.
- Updated `.codex/AGENTS.md` and `README.md` to expose the workflow.
- Added `.gitignore` rules for local workspace journals.

## Verification Run

- `git status --short --branch`
- `git ls-files --others --exclude-standard | sort`
- `git check-ignore -v .agents/ecc-workflow/workspace/local-journal.md`
- `find .agents/ecc-workflow .agents/skills/ecc-task-workflow .agents/skills/ecc-final-check .agents/skills/ecc-finish-work -type f | sort`
- Brand-name scan across `README.md`, `.codex/AGENTS.md`,
  `.agents/ecc-workflow/`, `.agents/skills/ecc-*`, and `.gitignore`
- `git diff --check`
- `rg -n "[ \\t]+$" .agents/ecc-workflow .agents/skills/ecc-task-workflow .agents/skills/ecc-final-check .agents/skills/ecc-finish-work .codex/AGENTS.md README.md .gitignore`

## Findings

- No blocking findings.
- `.agents/ecc-workflow/workspace/local-journal.md` is ignored by the new
  `.gitignore` rule, while `workspace/README.md` remains trackable.
- The docs explicitly say this workflow does not install external harness
  tooling, run external init commands, or create vendor-owned workflow
  directories.
- Brand-name scan is clean across the workflow docs and skills.
- Whitespace checks are clean after replacing template placeholders with `TBD`.

## Residual Risk

- The new workflow is intentionally unproven until it is used on a few real
  tasks.
- Skill trigger wording may need tuning after observing how often it fires.

## Follow-Ups

- If a full external harness trial becomes interesting, run it in a scratch repo
  or separate branch and compare generated `.codex/`, `.agents/`, and workflow
  directory changes before merging anything into this baseline.
