# Implementation Notes

## Relevant Context

- `skill-use-manager` is the daily router; conditional skills need a trigger
  row there and in `inventory/skill-use-classification.md`.
- `eval-bottleneck-reduction` is the precedent for a repository-only skill
  (openai.yaml included, prose note in `inventory/codex-skills.md`).

## Files To Inspect

- `.agents/skills/{agent-harness-design,eval-bottleneck-reduction,ai-regression-testing,ecc-*}/SKILL.md`
- `.agents/ecc-workflow/README.md` and `templates/task/*.md`
- `.codex/AGENTS.md`, `inventory/*.md`, `scripts/lint.sh`

## Plan

1. Write the skill with a Boundary section deferring to neighboring skills.
2. Add Quality Bar / Human-Owned Judgment to `prd.md`, an Observability
   Contract block to `implement.md`, and Evidence / Blind Spots / Promotion
   to `check.md`.
3. Add routing rows, AGENTS.md entry, README bullets.
4. Update mechanical inventory via `update-inventory.sh --write`.

## Decisions

- Contract lives in the skill; templates carry only condensed prompts.
- Skill stays repository-only (not mirrored to `~/.codex/skills`) until it
  proves useful elsewhere, matching `eval-bottleneck-reduction`.
- Existing `Verification Plan` and `Residual Risk` sections kept; new fields
  added rather than renaming established headings.

## Observability Contract

- Target: routing docs, templates, and inventory that agree with each other;
  a skill body that composes with its neighbors instead of duplicating them.
- Observation method: generated-artifact inspection — read the final files
  and the git diff; run the inventory check to observe agreement mechanically.
- Stable reference points: `update-inventory.sh --check` exit code;
  `scripts/lint.sh`; grep for `observable-development-loop` across routing
  surfaces.
- Deterministic checks: inventory check exits 0; lint passes; every referenced
  skill name resolves to a `SKILL.md` under `.agents/skills/`.

## Verification Plan

- `bash scripts/lint.sh`
- `bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check`
- Grep all skill names referenced by the new SKILL.md and confirm they exist.
