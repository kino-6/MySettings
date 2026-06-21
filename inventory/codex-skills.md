# Codex Skills Inventory

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-06-21 JST

## Sources

- Local user skills: `~/.codex/skills`
- Repository skills: `.agents/skills`

## Merge Summary

- Local user skills found: 86
- Repository skills found: 86
- Missing local user skills in repository: 0
- Same-name content differences: 1
- Local Codex system skills found under `~/.codex/skills/.system`: 5

All non-system local skills are already present in this repository. ECC upstream Codex skills from `affaan-m/ECC` were added in add-only mode on 2026-06-13.

`hirokita117/yaml-to-html-skill` was added in add-only mode on 2026-06-18. It contributes `generate-explainer-yaml` and `generate-explainer-html`, both kept as project-local skills under `.agents/skills/`; the upstream MIT license is copied into each imported skill directory.

`addyosmani/agent-skills` was added in add-only mode on 2026-06-18. It contributes 24 production engineering workflow skills to both `.agents/skills` and local `~/.codex/skills`. The upstream MIT license is copied into each imported skill directory, and root-level supporting `references/` / `agents/` files were copied into the specific standalone skill directories that reference them.

`agent-self-review` was added on 2026-06-20 as a Codex skill for one-pass self-review of agent outputs. It is intentionally lightweight and does not act as a strict review gate.

The structured ECC workflow skills were added on 2026-06-21 as Codex skills:

- `ecc-task-workflow`: starts lightweight task context for broad or multi-session repo work.
- `ecc-final-check`: checks diff scope, verification, and accidental private state before handoff.
- `ecc-finish-work`: closes structured tasks with check updates, resume notes, and durable learning promotion.

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
| _(none)_ |


## Local Codex System Skills

These exist under `~/.codex/skills/.system` and were intentionally not copied into the repo.

| Skill | Note |
| --- | --- |
| `imagegen` | System-managed; includes license file |
| `openai-docs` | System-managed; includes license file |
| `plugin-creator` | System-managed |
| `skill-creator` | System-managed; includes license file |
| `skill-installer` | System-managed; includes license file |
