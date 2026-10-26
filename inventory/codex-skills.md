# Codex Skills Inventory

Generated: 2026-06-10 09:11:40 JST
Updated: 2026-10-26 JST

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

- Local user skills found: 72
- Repository skills found: 96
- Missing local user skills in repository: 4 (`sprite-gen`, `illustration-to-rigged-avatar-parts`, `image-to-3d-avatar-triage`, `rigged-anime-avatar-base`)
- Same-name content differences: 1
- Local Codex system skills found under `~/.codex/skills/.system`: 5

Four non-system local skills are not in this repository. `illustration-to-rigged-avatar-parts`, `image-to-3d-avatar-triage` and `rigged-anime-avatar-base` appeared in `~/.codex/skills` on 2026-10-16 from another session - in-progress VRM/avatar work in Codex, deliberately left there rather than vendored. `sprite-gen` (Apache-2.0, appeared in `~/.codex/skills` on 2026-09-12 from another session; it is a full package with `pyproject.toml`, `scripts/`, and `tests/`, so vendoring it is a deliberate decision that has not been made yet). ECC upstream Codex skills from `affaan-m/ECC` were added in add-only mode on 2026-06-13.

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

`mattpocock/skills` was added in add-only mode on 2026-09-02. It contributes `grill-with-docs`, `grilling`, and `domain-modeling`. `grill-with-docs` is a user-invoked composite (`disable-model-invocation: true`) whose whole body is an instruction to call the other two, so the three are maintained as a set. `domain-modeling` keeps its `GLOSSARY-FORMAT.md` and `ADR-FORMAT.md` references inside the skill directory so it stays standalone. The upstream MIT license is copied into each imported skill directory. At the user's request these three were mirrored into both `~/.codex/skills` and `~/.claude/skills` so every local project can reference them from either runtime; `~/.claude/skills` is a new distribution surface. As of 2026-10-07 it holds four: these three plus `task-queue-loop`. Repo-scoped skills stay out of it - `skill-use-manager` routes *this* repository's `.agents/skills` and would fire in unrelated projects, so it lives only in `.agents/skills` and `~/.codex/skills`.

On 2026-09-02 the stale local copy of `skill-use-manager` was re-synced from the repository copy: it was missing the `observable-development-loop` and `build-playable-games` routing rows added earlier.

`task-queue-loop` was added on 2026-09-21. It is not an upstream import: it was distilled from the `Tasks.md` queues actually in use across 11 local repositories (see its `references/collected-practice.md` for the per-rule provenance table and the variations deliberately left open). It carries the `Tasks.md` / `CHARTER.md` / archive templates plus `templates/gate-auditor.md`, and `references/gate-audit-loop.md` adds the second-perspective gate audit: a fresh-context agent that attacks the row's gate rather than the diff, returns a fixed-format verdict, and files refactoring proposals back into the queue as gated rows. Mirrored into both `~/.codex/skills` and `~/.claude/skills`. `build-playable-games/references/task-queue.md` stays the game-project cut of the same conventions and now cross-references this skill in both directions.

On 2026-09-21 the skill gained two on-demand sub-skills, deliberately kept inside it rather than split out: `references/runtime-contract.md` (single launch entry point, exclusive lock and run-scope separation, shadow tree, headless-only agent lanes with the macOS focus measurement and an executable focus check, windowless real-pixel capture, seeds, version and seed stamped into the frame, gated recording) and `references/trouble-registry.md` (repeated failures generalised into counted types, appended automatically by a pre-commit hook and classified under a commit block, recalled via a SessionStart digest). Both are near-universal, so splitting them would have added routing surface without adding reach; they get their own trigger rows in `skill-use-manager` instead. Sources are recorded in the skill's `references/collected-practice.md`.

`context-architecture` gained a "Converting A Document You Keep Re-Reading" section on 2026-10-05. The skill already owned the retrieval side of large documents (build an index, load one section); what was missing was the authoring side - when a local document earns being restructured into a skill, and what file set to produce. The file-set shape with per-part token budgets, the trigger test ("re-open it often enough to wish you had memorized it"), and the "structure, not a summary" framing are adapted from `virgiliojr94/book-to-skill` (MIT, 33.7k stars). Only the ideas were taken: the tool is not installed, its `~/.agents/skills` root is not adopted (this setup uses `~/.codex/skills` + `~/.claude/skills`), and generated distillations of purchased books are deliberately kept out of this repository, which is public. Note that the project carries a `SECURITY-NOTICE.md` about a malicious re-upload at `Leutenegger/book-to-skill` that exfiltrated crypto-wallet data - only the official repository is safe to reference.

**Import policy addition (2026-10-07): record provenance at import time.** Every newly vendored skill carries a `provenance.json` next to its `LICENSE`: the upstream repo, the exact revision fetched, a sha256 per file, and the verification date. `bash scripts/check-provenance.sh --check` re-fetches each recorded path at its recorded revision and exits 1 on drift, on a local edit to a vendored file, or on a recorded path that no longer exists upstream. The idea is borrowed from [Alder](https://github.com/mk3008/alder), which pins its bundled reference copies the same way; nothing else from that kit was adopted.

The first run paid for itself. `mattpocock/skills` had **renamed `CONTEXT.md` to `GLOSSARY.md`** (and `CONTEXT-FORMAT.md` to `GLOSSARY-FORMAT.md`) between the 2026-09-02 import and 2026-10-07, so the local `domain-modeling` copy was teaching a filename upstream had abandoned - silently, with no signal. The three mattpocock skills were re-vendored at `6fd94792` and this repository's own references were updated to match. Note that `~/work/little-reef/CONTEXT.md` is a real glossary in this skill's format and was **not** renamed: it belongs to that project, and the updated skill will look for `GLOSSARY.md` there.

Pre-existing imports (ECC, Addy pack, yaml-to-html-skill) have no `provenance.json`: the revision they were taken from was never recorded and guessing one would be worse than an honest gap. They get a manifest the next time they are deliberately re-vendored.

`progress-contract` was added on 2026-10-16 from a user report that recent models "黙って裏で数分やって回答が来る" and occasionally work for an hour while answering only in the gaps. It is the mirror of `observable-development-loop`: that skill owns the agent seeing its own output, this one owns the person seeing the agent. It carries narration thresholds (including a row whose correct answer is silence, because a line per tool call trains the reader to skip all of them), the handling of a message that bundles several requests, per-item reporting, and `templates/response-cadence.md` for installation into an always-loaded instruction file. Its `references/collected-practice.md` counts the specific failures out of the attached transcript. Deliberately not held in the skill body alone: cadence must apply on turns that trigger no skill, and the repository the report came from had no instruction surface at all, so the missing piece was a place to put rules rather than the rules. This repo's instance is `settings/common/.claude/CLAUDE.md`, deployed to `~/.claude/CLAUDE.md` by the existing `deploy_tree`.

`repo-preflight` was added on 2026-10-16 at the user's request: work happens mostly in private repositories, so accidents stay invisible until a repo goes public or gains a remote. It scans tracked, untracked and (with `--history`) every commit for secrets, personal data and risky files, and classifies each by the state that decides the fix - `.gitignore` only prevents untracked files, so tracked secrets need `git rm --cached` and anything ever committed needs rotation. It changes nothing and every proposed fix needs the user's confirmation. Secret values are masked in its output. Standard library only, no network, in keeping with this repo's rule of auditing through readable commands rather than a downloaded scanner. Mirrored into both `~/.codex/skills` and `~/.claude/skills`.

**Unused tools removed (2026-10-26).** Codex session logs (27 sessions, 2026-09-08 .. 10-25) showed 26 of 99 local skills read and none of the 8 MCP servers called. The 27 skills that were neither used nor classified `DAILY` / `CONDITIONAL` moved out of `~/.codex/skills` to `~/.codex/skills-unused-20261026/`; all of them remain in `.agents/skills`, so the "Repository-Only Skills" list below is now intentional rather than drift. Twenty of them had never been classified at all - ECC imports such as article-writing, investor-materials and x-api.

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
| `article-writing` |
| `brand-voice` |
| `bun-runtime` |
| `clickhouse-io` |
| `coding-standards` |
| `content-engine` |
| `continuous-learning` |
| `crosspost` |
| `database-migrations` |
| `dmux-workflows` |
| `documentation-lookup` |
| `eval-bottleneck-reduction` |
| `everything-claude-code` |
| `exa-search` |
| `fal-ai-media` |
| `frontend-slides` |
| `gamestudio-review` |
| `investor-materials` |
| `investor-outreach` |
| `jpa-patterns` |
| `market-research` |
| `mcp-server-patterns` |
| `mle-workflow` |
| `nextjs-turbopack` |
| `postgres-patterns` |
| `product-capability` |
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
