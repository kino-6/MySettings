# Codex Skills Inventory

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-06-10 09:11:40 JST

## Sources

- Local user skills: `~/.codex/skills`
- Repository skills: `.agents/skills`

## Merge Summary

- Local user skills found: 22
- Repository skills found: 30
- Missing local user skills in repository: 0
- Same-name content differences: 1
- Local Codex system skills found under `~/.codex/skills/.system`: 5

All non-system local skills are already present in this repository.

The only same-name difference is `skill-stocktake/SKILL.md`: the repository copy adds a `name: skill-stocktake` frontmatter field that is absent from the local copy. The repository version was kept because it is the more complete metadata form.

Codex system skills under `.system` were not vendored into `.agents/skills`; they are preinstalled Codex skills and should stay system-managed unless explicitly pinned for this repo later.

## Local User Skills

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
| `agent-harness-design` |
| `ai-automation-ops` |
| `context-architecture` |
| `external-ai-tools` |
| `multi-agent-prompting` |
| `outcome-first-prompting` |
| `prompt-thinking-patterns` |
| `skill-use-manager` |

## Local Codex System Skills

These exist under `~/.codex/skills/.system` and were intentionally not copied into the repo.

| Skill | Note |
| --- | --- |
| `imagegen` | System-managed; includes license file |
| `openai-docs` | System-managed; includes license file |
| `plugin-creator` | System-managed |
| `skill-creator` | System-managed; includes license file |
| `skill-installer` | System-managed; includes license file |
