# Codex Skills Inventory

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-06-18 JST

## Sources

- Local user skills: `~/.codex/skills`
- Repository skills: `.agents/skills`

## Merge Summary

- Local user skills found: 22
- Repository skills found: 58
- Missing local user skills in repository: 0
- Same-name content differences: 1
- Local Codex system skills found under `~/.codex/skills/.system`: 5

All non-system local skills are already present in this repository. ECC upstream Codex skills from `affaan-m/ECC` were added in add-only mode on 2026-06-13.

`hirokita117/yaml-to-html-skill` was added in add-only mode on 2026-06-18. It contributes `generate-explainer-yaml` and `generate-explainer-html`, both kept as project-local skills under `.agents/skills/`; the upstream MIT license is copied into each imported skill directory.

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
| `api-design` |
| `article-writing` |
| `backend-patterns` |
| `brand-voice` |
| `bun-runtime` |
| `coding-standards` |
| `content-engine` |
| `context-architecture` |
| `crosspost` |
| `deep-research` |
| `dmux-workflows` |
| `documentation-lookup` |
| `everything-claude-code` |
| `exa-search` |
| `external-ai-tools` |
| `fal-ai-media` |
| `frontend-patterns` |
| `frontend-slides` |
| `generate-explainer-html` |
| `generate-explainer-yaml` |
| `investor-materials` |
| `investor-outreach` |
| `market-research` |
| `mcp-server-patterns` |
| `mle-workflow` |
| `multi-agent-prompting` |
| `nextjs-turbopack` |
| `outcome-first-prompting` |
| `product-capability` |
| `prompt-thinking-patterns` |
| `security-review` |
| `skill-use-manager` |
| `video-editing` |
| `x-api` |

## Local Codex System Skills

These exist under `~/.codex/skills/.system` and were intentionally not copied into the repo.

| Skill | Note |
| --- | --- |
| `imagegen` | System-managed; includes license file |
| `openai-docs` | System-managed; includes license file |
| `plugin-creator` | System-managed |
| `skill-creator` | System-managed; includes license file |
| `skill-installer` | System-managed; includes license file |
