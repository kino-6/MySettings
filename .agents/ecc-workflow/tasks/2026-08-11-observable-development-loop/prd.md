# PRD

## Goal

Add an `observable-development-loop` skill and concise observability fields to
the ECC task templates so that substantial AI implementation work observes its
own output, compares it under stable conditions, verifies mechanically, and
promotes failures into durable project knowledge.

## Background

- Generalized from the `Kenton-GMI/sakura-crossing` lesson: agents produce
  better work when they can observe output directly and preserve failures.
- Neighboring skills already own parts of this space: `agent-harness-design`
  (agent loop), `eval-bottleneck-reduction` (layered evals and promotion),
  `ai-regression-testing` (recurring code regressions), `ecc-task-workflow`
  (task artifacts). The new skill only owns agent-visible evidence and
  repeatable observation.

## Scope

In scope:

- `.agents/skills/observable-development-loop/` (SKILL.md, openai.yaml)
- Observability fields in `.agents/ecc-workflow/templates/task/`
- Routing: `skill-use-manager`, `.codex/AGENTS.md`, inventory files
- One bullet in the Japanese README and the ecc-workflow README

Out of scope:

- External harness tooling, browser/screenshot framework prescriptions
- Rewriting existing skills or the ECC baseline
- Commit or push

## Acceptance Criteria

- Skill activates only on results that cannot be judged from the diff alone.
- Templates stay lightweight; small edits need no contract.
- Routing docs and mechanical inventory agree (`update-inventory.sh --check`).
- No overlap with the neighboring skills listed above.

## Quality Bar

The workflow must require evidence (commands, outputs, artifacts) rather than
self-asserted completion, while staying proportional to task size.

## Human-Owned Judgment

Whether the template field set is the right weight, and whether the skill
should later be mirrored to `~/.codex/skills`.

## Risks

- Template bloat making small tasks feel ceremonial.
- Routing-table drift if the skill is renamed or demoted later.
