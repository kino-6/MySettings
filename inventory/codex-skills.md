# Codex Skills Inventory

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-09-02 JST

Latest audit: [2026-09-14 Local / MySettings stocktake](2026-09-14-astra-stocktake.md)
and [complete structural inventory](2026-09-14-skill-scan.tsv). That scan found
93 local and 93 repository skills, with `sprite-gen` local-only and
`eval-bottleneck-reduction` repository-only. The dated merge summary and
same-name difference notes below describe the earlier inventory, not the
current mirror state. No skill synchronization was performed in the new audit.

## Sources

- Local user skills: `~/.codex/skills`
- Local Claude Code user skills: `~/.claude/skills` (only the skills explicitly mirrored for Claude Code; Claude Code does not read `~/.codex/skills`)
- Repository skills: `.agents/skills`

## Merge Summary

- Local user skills found: 92
- Repository skills found: 93
- Missing local user skills in repository: 0
- Same-name content differences: 1
- Local Codex system skills found under `~/.codex/skills/.system`: 6

All non-system local skills are already present in this repository. ECC upstream Codex skills from `affaan-m/ECC` were added in add-only mode on 2026-06-13.

`hirokita117/yaml-to-html-skill` was added in add-only mode on 2026-06-18. It contributes `generate-explainer-yaml` and `generate-explainer-html`, both kept as project-local skills under `.agents/skills/`; the upstream MIT license is copied into each imported skill directory.

`addyosmani/agent-skills` was added in add-only mode on 2026-06-18. It contributes 24 production engineering workflow skills to both `.agents/skills` and local `~/.codex/skills`. The upstream MIT license is copied into each imported skill directory, and root-level supporting `references/` / `agents/` files were copied into the specific standalone skill directories that reference them.

`agent-self-review` was added on 2026-06-20 as a Codex skill for one-pass self-review of agent outputs. It is intentionally lightweight and does not act as a strict review gate.

The structured ECC workflow skills were added on 2026-06-21 as Codex skills:

- `ecc-task-workflow`: starts lightweight task context for broad or multi-session repo work.
- `ecc-final-check`: checks diff scope, verification, and accidental private state before handoff.
- `ecc-finish-work`: closes structured tasks with check updates, resume notes, and durable learning promotion.

`eval-bottleneck-reduction` was added on 2026-07-11 as a project-local skill for designing layered AI evaluation workflows that reduce human review bottlenecks. It stays repository-only until it proves broadly useful outside this repo.

`observable-development-loop` was added on 2026-08-11 as a project-local skill that defines an Observability Contract for output that cannot be judged from source inspection alone: direct observation, stable reference points, deterministic checks, retained evidence, and failure promotion. It was mirrored into local `~/.codex/skills` on 2026-08-11 at the user's request.

`build-playable-games` was added on 2026-08-11. Its SKILL.md was authored in a separate session by the user's request; this repo integrated it and authored its missing `references/` (quality-gates, genre-lenses, source-lessons distilled from `kino-6/black-stela` and `kino-6/RePrise`) and `scripts/inspect_game_project.py`. On 2026-08-12, `references/task-queue.md` was added: the Tasks.md active-queue conventions (named FAIL-able gates, four-part definition of done, same-edit grooming) distilled from the black-stela operating rules. Mirrored into local `~/.codex/skills` so game repositories can load it.

`mattpocock/skills` was added in add-only mode on 2026-09-02. It contributes `grill-with-docs`, `grilling`, and `domain-modeling`. `grill-with-docs` is a user-invoked composite (`disable-model-invocation: true`) whose whole body is an instruction to call the other two, so the three are maintained as a set. `domain-modeling` keeps its `CONTEXT-FORMAT.md` and `ADR-FORMAT.md` references inside the skill directory so it stays standalone. The upstream MIT license is copied into each imported skill directory. At the user's request these three were mirrored into both `~/.codex/skills` and `~/.claude/skills` so every local project can reference them from either runtime; `~/.claude/skills` is a new distribution surface and currently holds only these three skills.

On 2026-09-02 the stale local copy of `skill-use-manager` was re-synced from the repository copy: it was missing the `observable-development-loop` and `build-playable-games` routing rows added earlier.

The only same-name difference is `skill-stocktake/SKILL.md`: the repository copy adds a `name: skill-stocktake` frontmatter field that is absent from the local copy. The repository version was kept because it is the more complete metadata form.

Codex system skills under `.system` were not vendored into `.agents/skills`; they are preinstalled Codex skills and should stay system-managed unless explicitly pinned for this repo later.

## Original Local User Skills

This table is the original audited local set from 2026-06-10. The 2026-06-13 ECC import, 2026-06-18 Addy import, and later project additions are mirrored into both local and repository skill directories when local inventory is current.

| Skill | Repo status |
| --- | --- |
| `agent-introspection-debugging` | Present |
| `agent-sort` | Present |
| `ai-regression-testing` | Present |
| `clickhouse-io` | Present |
| `code-tour` | Present |
| `configure-ecc` | Present |
| `continuous-learning` | Present |
| `continuous-learning-v2` | Present |
| `council` | Present |
| `database-migrations` | Present |
| `e2e-testing` | Present |
| `eval-harness` | Present |
| `gamestudio-review` | Present |
| `hookify-rules` | Present |
| `iterative-retrieval` | Present |
| `jpa-patterns` | Present |
| `plankton-code-quality` | Present |
| `postgres-patterns` | Present |
| `skill-stocktake` | Present; repo metadata kept |
| `strategic-compact` | Present |
| `tdd-workflow` | Present |
| `verification-loop` | Present |

## Repository-Only Skills

These skills exist in `.agents/skills` but not in local `~/.codex/skills`.

| Skill |
| --- |
| `eval-bottleneck-reduction` |

## Local Codex System Skills

These exist under `~/.codex/skills/.system` and were intentionally not copied into the repo.

| Skill | Note |
| --- | --- |
| `imagegen` | System-managed; includes license file |
| `openai-docs` | System-managed; includes license file |
| `plugin-creator` | System-managed |
| `skill-creator` | System-managed; includes license file |
| `skill-installer` | System-managed; includes license file |
