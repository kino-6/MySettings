# Skill Use Classification

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-08-11 JST

Audit follow-up: [2026-09-14 stocktake](2026-09-14-astra-stocktake.md) records
current counts, overlapping routing rules, and proposed model-switch profiles.
The buckets below remain the existing policy; the audit proposals have not
been applied. These labels do not disable skill discovery or remove metadata
from the model's available-skill catalog.

## Position

`skill-use-manager` is a good next step.

The useful split is not just "always" versus "sometimes"; it is:

- `DAILY`: always considered for this repo's operating loop.
- `CONDITIONAL`: used when a task trigger matches.
- `LIBRARY`: kept searchable, but not loaded by default.

This follows the same progressive-disclosure idea used by Codex skills: keep metadata and routing cheap, load detailed skill bodies only when needed.

`agents/openai.yaml` is optional metadata. Keep it for exported, plugin-facing,
or cross-runtime skills where external router metadata helps. Do not add
boilerplate `agents/openai.yaml` files to every skill solely for symmetry;
`SKILL.md` frontmatter remains the canonical local routing source.

## Repo Evidence

- This repo is a dotfiles/setup repository, not an application runtime.
- Active first-party files are mostly Markdown and shell scripts: `README.md`, `mac-setup.sh`, `wsl-setup.sh`, and `scripts/*.sh`.
- The repo contains `.agents/skills`, so skill governance is a first-class concern.
- Current scan found 90 repository skills, 89 non-system local user skills, and 1 repository-only skill: `eval-bottleneck-reduction`.
- There are no active app manifests such as `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or `tsconfig*.json`.

## DAILY

| Skill | Evidence | Why |
| --- | --- | --- |
| `skill-use-manager` | Added as the router for `.agents/skills` | Keeps routing decisions lightweight and repeatable. |
| `verification-loop` | Repo changes affect setup scripts and dotfiles | Verification should be considered before handoff after meaningful edits. |
| `agent-self-review` | Agent-created outputs need a lightweight check before handoff | Adds one self-review pass without turning routine work into a strict gate. |
| `strategic-compact` | Skill and config work can run long | Helps preserve state during long repo maintenance sessions. |
| `skill-stocktake` | User is actively auditing skills | Core workflow for skill quality and overlap review. |

## CONDITIONAL

| Skill | Trigger |
| --- | --- |
| `test-driven-development` | New feature, bug fix, refactor, or behavior change where tests should prove the result. |
| `tdd-workflow` | Strict coverage gates, explicit red-green-refactor, or coordinated unit/integration/E2E planning are required. |
| `incremental-implementation` | Multi-file changes should land as thin, verifiable slices. |
| `debugging-and-error-recovery` | Tests fail, builds break, or behavior is unexpected and needs systematic root-cause triage. |
| `ai-regression-testing` | AI-written changes need regression traps or review harnesses. |
| `e2e-testing` | Browser/UI end-to-end tests are relevant. |
| `browser-testing-with-devtools` | Browser runtime inspection via DevTools MCP is needed. |
| `eval-harness` | Prompt, agent, or workflow quality needs formal evaluation. |
| `eval-bottleneck-reduction` | Human review, LLM-as-judge, subjective quality gates, golden task sets, or evaluation bottleneck reduction needs a scalable workflow. |
| `observable-development-loop` | An AI-generated result must be observed at runtime or as a generated artifact, with stable reference points, deterministic checks, and retained evidence. |
| `interview-me` | Requirements are underspecified and need one-question-at-a-time clarification. |
| `idea-refine` | A vague idea needs divergent/convergent refinement before planning. |
| `grill-with-docs` | A plan or design should be stress-tested and documented in one pass; user-invoked only, and it calls `grilling` plus `domain-modeling`. |
| `grilling` | A plan, decision, or idea needs relentless round-based questioning until the design tree has no open branches. |
| `domain-modeling` | Codebase terminology is being challenged or fixed, or a `CONTEXT.md` glossary / `docs/adr/` ADR is being written or edited. |
| `spec-driven-development` | A significant feature or project needs a PRD/spec before implementation. |
| `planning-and-task-breakdown` | A spec or clear request needs implementable, ordered tasks. |
| `outcome-first-prompting` | A prompt needs stable schema, format, examples, or acceptance criteria. |
| `prompt-thinking-patterns` | A prompt needs reasoning quality, verification, self-refine, pre-mortem, or confidence labels. |
| `source-driven-development` | Framework/library decisions need official documentation and source-cited verification. |
| `doubt-driven-development` | Stakes are high enough to justify adversarial fresh-context review of non-trivial decisions. |
| `context-architecture` | Large references, anchor documents, session continuity, or cache-aware layout are involved. |
| `context-engineering` | Agent context/rules setup needs explicit optimization. |
| `multi-agent-prompting` | Routing, debate, independent alternatives, or reviewer separation would improve the task. |
| `agent-harness-design` | Designing or improving a tool-using agent loop, guardrails, or stop conditions. |
| `ecc-task-workflow` | Broad, risky, multi-file, or multi-session repo work should create lightweight task context. |
| `task-queue-loop` | A repository keeps an active `Tasks.md` / `TASKS.md` queue, work keeps drifting off it, the queue has grown into a history dump, or a queue should be installed in a new repo. |
| `task-queue-loop` / `references/runtime-contract.md` | Launcher or entry-point design; agent runs take window focus, wait on the human's session, or cannot produce a real-pixel capture; seeds and build identity are not visible in the output. |
| `task-queue-loop` / `references/trouble-registry.md` | The same class of mistake recurs; a lessons or trouble file should become counted types with automatic appending and a commit block on unclassified entries. |
| `ecc-final-check` | Substantial structured workflow changes need a final diff, scope, and verification review. |
| `ecc-finish-work` | Structured tasks need a clean ending ritual with check updates, resume notes, and durable learning promotion. |
| `agent-sort` | Reclassifying skills, commands, rules, hooks, or extras into daily/conditional/library buckets. |
| `configure-ecc` | Adjusting ECC/Codex installation, config, or project/user-level setup surfaces. |
| `ai-automation-ops` | Turning local agent practice into repo/team automation, review gates, or repeatable skill packaging. |
| `council` | Multiple valid paths require structured disagreement before deciding. |
| `iterative-retrieval` | Context must be retrieved progressively instead of bulk-loaded. |
| `agent-introspection-debugging` | A failed agent/session needs structured diagnosis and recovery. |
| `external-ai-tools` | Evaluating or installing third-party AI tools, MCPs, research CLIs, OCR, TTS, video, or avatar apps. |
| `generate-explainer-yaml` | A document, PR, README, design note, or spec should be captured as `core.yaml` + `view.yaml` before visualization. |
| `generate-explainer-html` | A `core.yaml` / `view.yaml` pair should become an offline switchable HTML explainer bundle. |
| `continuous-learning-v2` | Session patterns should become project-scoped reusable instincts. |
| `hookify-rules` | Creating or modifying Hookify rules. |
| `plankton-code-quality` | Plankton hook-based code quality workflow is explicitly needed. |
| `code-tour` | User asks for onboarding, architecture walkthrough, PR tour, or RCA tour. |
| `git-workflow-and-versioning` | Branching, committing, conflict resolution, or release history hygiene matters. |
| `code-review-and-quality` | Reviewing self/agent/human code before merge. |
| `code-simplification` | Refactoring for clarity without behavior change. |
| `documentation-and-adrs` | Architectural decisions, APIs, or durable context should be documented. |
| `api-and-interface-design` | Public contracts, module boundaries, schemas, or frontend/backend integration points are being designed. |
| `api-design` | REST endpoint/resource conventions, status codes, pagination, filtering, errors, versioning, or rate limits are needed. |
| `backend-patterns` | Backend implementation patterns for services, repositories, middleware, data access, caching, jobs, or logging are needed. |
| `frontend-patterns` | React/Next.js implementation patterns for components, hooks, state, forms, errors, animation, or frontend performance are needed. |
| `frontend-ui-engineering` | Production-quality UI layout, visual hierarchy, interaction states, responsiveness, or design-system fit is needed. |
| `security-and-hardening` | Designing or implementing sensitive behavior with untrusted input, auth, storage, secrets, or external integrations. |
| `security-review` | Reviewing or auditing changes for vulnerabilities, secrets, auth gaps, injection risks, or missing security tests. |
| `performance-optimization` | Performance requirements, regressions, Core Web Vitals, or profiling are relevant. |
| `ci-cd-and-automation` | CI/CD pipelines, quality gates, or deployment automation are being set up or changed. |
| `observability-and-instrumentation` | Logging, metrics, tracing, or production diagnosability are needed. |
| `deprecation-and-migration` | Removing old systems or migrating users/behavior. |
| `shipping-and-launch` | Preparing production launch, staged rollout, rollback, or monitoring. |
| `strategic-ai-wall-partner` | Strategy, business ideas, product bets, career decisions, research questions, or assumption stress tests need a wall partner. |

## LIBRARY

| Skill | Why Library For This Repo |
| --- | --- |
| `database-migrations` | No active database schema or migration tool in this repo. |
| `postgres-patterns` | No active PostgreSQL project files in this repo. |
| `clickhouse-io` | No active ClickHouse analytics workload in this repo. |
| `jpa-patterns` | No Java/Spring/JPA code in this repo. |
| `gamestudio-review` | No game project files in this repo; use in game repositories for multi-role critique. |
| `build-playable-games` | No game project files in this repo; use in game repositories (e.g. black-stela, RePrise) for playable-slice implementation with shipping-runtime gates. |
| `using-agent-skills` | Addy pack's alternate router; this repo keeps `skill-use-manager` as the daily router. |
| `continuous-learning` | Legacy workflow; use `continuous-learning-v2` for current project-scoped learning. |
| `everything-claude-code` | Upstream ECC conventions/provenance reference; this repo keeps its Codex baseline in `.codex/AGENTS.md` and `.agents/ecc-workflow/`. |

## Notes

- `task-queue-loop`'s two sub-skills are deliberately not separate skills: both are near-universal, and splitting them would only add routing surface. They stay as on-demand `references/` documents, with their own trigger rows in the router so they remain reachable in repositories that keep no queue. `references/runtime-contract.md` sits next to `observable-development-loop`: that skill owns how an agent observes its own output, this one owns whether the project can be launched and observed at all without taking over the machine. `references/trouble-registry.md` sits next to `continuous-learning-v2`: that one extracts instincts from sessions via hooks, this one generalises repeated failures into counted types enforced at commit time.
- `task-queue-loop` and `ecc-task-workflow` both create task context but at different scales: `ecc-task-workflow` spins up per-task artifacts under `.agents/ecc-workflow/tasks/` for one broad piece of work, while `task-queue-loop` operates a single long-lived queue file that outlives individual tasks. `build-playable-games/references/task-queue.md` stays the game-project cut and is cross-referenced from both directions.
- `interview-me` and `grilling` overlap on "grill me" style triggers but differ in shape: `interview-me` asks one question at a time to recover intent behind an underspecified ask, while `grilling` asks a whole decision frontier per round to stress-test a plan that already exists. Prefer `grill-with-docs` when the grilling should also leave `CONTEXT.md` / ADR behind.
- Internet research was not used for this pass. The better source of truth is repo-local evidence plus the existing `agent-sort` workflow.
- `LIBRARY` skills should stay installed and searchable. They are just not worth loading by default for this repository.
- Revisit this classification when the repo gains application code, CI, package manifests, hooks, or new project-local MCP configuration.
