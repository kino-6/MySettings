---
name: skill-use-manager
description: Use when deciding which project skills should be loaded, routed, promoted to daily use, demoted to conditional/library use, or audited for overlap. Provides a lightweight router for this repo's `.agents/skills` without duplicating skill bodies.
---

# Skill Use Manager

Use this skill as the routing layer for `.agents/skills` in this repo.

The goal is to keep the always-on surface small while preserving access to specialized skills when the task calls for them.

## Buckets

- `DAILY`: consider on most sessions in this repo. These skills shape the work loop, verification, compaction, and skill governance.
- `CONDITIONAL`: use when the user request or repo evidence matches a clear trigger.
- `LIBRARY`: keep available as reference material, but do not load by default for this repo.

`LIBRARY` never means delete. It means searchable and selective.

## Daily Set

Use these as the default operating surface for this repo:

| Skill | Use |
| --- | --- |
| `skill-use-manager` | Decide whether another skill should be used. |
| `verification-loop` | Verify meaningful repo edits before handoff. |
| `agent-self-review` | Run a lightweight self-review pass before handoff. |
| `strategic-compact` | Preserve context during long-running repo work. |
| `skill-stocktake` | Audit skill quality, overlap, and stale references. |
| `agent-sort` | Reclassify skills into daily/conditional/library buckets. |
| `configure-ecc` | Adjust ECC/Codex installation and config surfaces. |
| `ai-automation-ops` | Operationalize Codex/ECC workflows into repo practice. |

## Conditional Routing

Use these when the task matches the trigger:

| Trigger | Skills |
| --- | --- |
| New feature, bug fix, refactor, shell/setup script change | `tdd-workflow`, `verification-loop` |
| Stricter Addy-style TDD or thin-slice implementation | `test-driven-development`, `incremental-implementation` |
| Test/build failure or unexpected behavior | `debugging-and-error-recovery` |
| AI-written code needs regression traps or review harnesses | `ai-regression-testing`, `eval-harness` |
| Browser or UI end-to-end/runtime tests are needed | `e2e-testing`, `browser-testing-with-devtools` |
| Requirements are unclear, vague, or need a spec | `interview-me`, `idea-refine`, `spec-driven-development`, `planning-and-task-breakdown` |
| Prompt, reusable instruction, or output contract design | `outcome-first-prompting`, `prompt-thinking-patterns` |
| Source-cited framework/library decisions | `source-driven-development`, `documentation-lookup` |
| High-stakes or unfamiliar decisions need adversarial review | `doubt-driven-development`, `council` |
| Long context, references, cache-aware prompt layout | `context-architecture`, `context-engineering`, `iterative-retrieval` |
| Multiple roles, debate, reviewer separation, subagent design | `multi-agent-prompting`, `council` |
| Tool-using AI agent harness design | `agent-harness-design` |
| Broad, risky, multi-file, or multi-session repo work | `ecc-task-workflow`, `ecc-final-check`, `ecc-finish-work` |
| Debugging a failed agent or session behavior | `agent-introspection-debugging` |
| Third-party AI tools, MCPs, research CLIs, OCR, TTS, video, or avatar apps | `external-ai-tools` |
| Continuous learning, local instincts, or session pattern capture | `continuous-learning-v2`, `continuous-learning` |
| Hookify or Plankton rule work | `hookify-rules`, `plankton-code-quality` |
| Onboarding walkthroughs or architecture tours | `code-tour` |
| Git hygiene, code review, or simplification | `git-workflow-and-versioning`, `code-review-and-quality`, `code-simplification` |
| API/interface, frontend UI, security, or performance work | `api-and-interface-design`, `frontend-ui-engineering`, `security-and-hardening`, `performance-optimization` |
| CI/CD, observability, deprecation, docs/ADRs, or launch readiness | `ci-cd-and-automation`, `observability-and-instrumentation`, `deprecation-and-migration`, `documentation-and-adrs`, `shipping-and-launch` |

## Library Routing

Keep these available, but only load them when the repo or user request explicitly needs the domain:

| Domain | Skills |
| --- | --- |
| Databases and migrations | `database-migrations`, `postgres-patterns`, `clickhouse-io` |
| Java backend | `jpa-patterns` |
| Games | `gamestudio-review` |
| Alternate skill router | `using-agent-skills` (reference only; this repo uses `skill-use-manager` as the daily router) |

## Operating Rules

1. Start with repo evidence and user intent, not generic preference.
2. Use the narrowest matching skill set.
3. Prefer one routing skill plus one domain skill; add more only when the workflow genuinely spans domains.
4. Do not read a domain skill body just because it exists.
5. If a skill seems useful in three unrelated recent sessions, propose promoting it from `CONDITIONAL` to `DAILY`.
6. If a daily skill has not affected decisions for several sessions, propose demoting it to `CONDITIONAL`.

## Auto Update Routine

When this skill is used for routing, stocktaking, or skill inventory work, first
check whether the mechanical inventory is stale:

```bash
bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check
```

`--check` exits `0` when inventory is current and `1` when drift is found.

If the check reports drift and the user has asked to update skill inventory or
classification files, run:

```bash
bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --write
```

The script only updates mechanical inventory facts:

- `inventory/codex-skills.md` update date.
- local non-system skill count.
- repository skill count.
- system skill count.
- repository-only skill list.

It does not classify skills into `DAILY`, `CONDITIONAL`, or `LIBRARY`. Bucket
changes still require repo evidence and judgment, then manual updates to this
file and `inventory/skill-use-classification.md`.

## Updating The Classification

When changing the buckets, update:

- `inventory/skill-use-classification.md`
- this file's Daily, Conditional, and Library tables
- `inventory/codex-skills.md` if the skill count changed
