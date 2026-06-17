# Skill Use Classification

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-06-18 JST

## Position

`skill-use-manager` is a good next step.

The useful split is not just "always" versus "sometimes"; it is:

- `DAILY`: always considered for this repo's operating loop.
- `CONDITIONAL`: used when a task trigger matches.
- `LIBRARY`: kept searchable, but not loaded by default.

This follows the same progressive-disclosure idea used by Codex skills: keep metadata and routing cheap, load detailed skill bodies only when needed.

## Repo Evidence

- This repo is a dotfiles/setup repository, not an application runtime.
- Active first-party files are mostly Markdown and shell scripts: `README.md`, `mac-setup.sh`, `wsl-setup.sh`, and `scripts/*.sh`.
- The repo contains `.agents/skills`, so skill governance is a first-class concern.
- There are no active app manifests such as `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or `tsconfig*.json`.

## DAILY

| Skill | Evidence | Why |
| --- | --- | --- |
| `skill-use-manager` | Added as the router for `.agents/skills` | Keeps routing decisions lightweight and repeatable. |
| `verification-loop` | Repo changes affect setup scripts and dotfiles | Verification should be considered before handoff after meaningful edits. |
| `strategic-compact` | Skill and config work can run long | Helps preserve state during long repo maintenance sessions. |
| `skill-stocktake` | User is actively auditing skills | Core workflow for skill quality and overlap review. |
| `agent-sort` | User is sorting skill use surfaces | Core workflow for daily versus library decisions. |
| `configure-ecc` | Repo owns ECC/Codex setup guidance | Needed when the classification turns into install/config changes. |
| `ai-automation-ops` | Repo contains Codex/ECC operational guidance | Helps turn local agent practice into maintainable repo rules. |

## CONDITIONAL

| Skill | Trigger |
| --- | --- |
| `tdd-workflow` | New feature, bug fix, refactor, or setup script behavior change. |
| `ai-regression-testing` | AI-written changes need regression traps or review harnesses. |
| `e2e-testing` | Browser/UI end-to-end tests are relevant. |
| `eval-harness` | Prompt, agent, or workflow quality needs formal evaluation. |
| `outcome-first-prompting` | A prompt needs stable schema, format, examples, or acceptance criteria. |
| `prompt-thinking-patterns` | A prompt needs reasoning quality, verification, self-refine, pre-mortem, or confidence labels. |
| `context-architecture` | Large references, anchor documents, session continuity, or cache-aware layout are involved. |
| `multi-agent-prompting` | Routing, debate, independent alternatives, or reviewer separation would improve the task. |
| `agent-harness-design` | Designing or improving a tool-using agent loop, guardrails, or stop conditions. |
| `council` | Multiple valid paths require structured disagreement before deciding. |
| `iterative-retrieval` | Context must be retrieved progressively instead of bulk-loaded. |
| `agent-introspection-debugging` | A failed agent/session needs structured diagnosis and recovery. |
| `external-ai-tools` | Evaluating or installing third-party AI tools, MCPs, research CLIs, OCR, TTS, video, or avatar apps. |
| `generate-explainer-yaml` | A document, PR, README, design note, or spec should be captured as `core.yaml` + `view.yaml` before visualization. |
| `generate-explainer-html` | A `core.yaml` / `view.yaml` pair should become an offline switchable HTML explainer bundle. |
| `continuous-learning-v2` | Session patterns should become project-scoped reusable instincts. |
| `continuous-learning` | Legacy continuous-learning workflow is explicitly requested. |
| `hookify-rules` | Creating or modifying Hookify rules. |
| `plankton-code-quality` | Plankton hook-based code quality workflow is explicitly needed. |
| `code-tour` | User asks for onboarding, architecture walkthrough, PR tour, or RCA tour. |

## LIBRARY

| Skill | Why Library For This Repo |
| --- | --- |
| `database-migrations` | No active database schema or migration tool in this repo. |
| `postgres-patterns` | No active PostgreSQL project files in this repo. |
| `clickhouse-io` | No active ClickHouse analytics workload in this repo. |
| `jpa-patterns` | No Java/Spring/JPA code in this repo. |
| `gamestudio-review` | No game project files in this repo. |

## Notes

- Internet research was not used for this pass. The better source of truth is repo-local evidence plus the existing `agent-sort` workflow.
- `LIBRARY` skills should stay installed and searchable. They are just not worth loading by default for this repository.
- Revisit this classification when the repo gains application code, CI, package manifests, hooks, or new project-local MCP configuration.
