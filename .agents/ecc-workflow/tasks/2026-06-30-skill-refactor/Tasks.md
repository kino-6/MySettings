# Skill Refactor Tasks

Date: 2026-06-30

Status: Completed on 2026-06-30

## Overview

Refactor the growing `.agents/skills` surface so Codex can route skills
accurately, keep daily context small, and notice stale upstream references
before they quietly drift.

Initial observed state:

- Repository skills: 87
- Existing inventory still records 86 repository skills.
- `strategic-ai-wall-partner` is present in `.agents/skills` but not reflected
  in the current inventory/classification.
- Some skill frontmatter names do not match their directories.
- `skill-stocktake` still documents `.claude/skills` as its default path even
  though this repo uses `.agents/skills`.

## Success Criteria

- Skill inventory and classification reflect the current repo state.
- Skill routing metadata is mechanically consistent.
- Duplicate or overlapping skill families have explicit ownership boundaries.
- Long skills are split into a small routing body plus references where useful.
- Reference URLs are recorded in a task-local index for future update checks.
- No skill is removed, merged, or demoted without a specific rationale.

## Completion Summary

- `skill-stocktake` now defaults to Codex/ECC paths: `~/.codex/skills` and
  `.agents/skills`.
- Stocktake scripts scan only `SKILL.md` files and report 87 project skills.
- `inventory/codex-skills.md` now records 87 repository skills and
  `strategic-ai-wall-partner` as repository-only.
- All checked skill frontmatter names match their directory names.
- `agents/openai.yaml` policy is documented as optional metadata for exported,
  plugin-facing, cross-runtime, or externally routed skills.
- DAILY routing was reduced to five skills: `skill-use-manager`,
  `verification-loop`, `agent-self-review`, `strategic-compact`, and
  `skill-stocktake`.
- `agent-sort`, `configure-ecc`, and `ai-automation-ops` moved to explicit
  CONDITIONAL triggers.
- TDD, security, API/backend/frontend, and legacy-router skill boundaries were
  clarified in `skill-use-manager`, classification docs, and relevant
  frontmatter descriptions.
- Six long skills were split into compact `SKILL.md` files plus
  `references/full-guide.md` copies preserving original detailed content.
- `reference-urls.md` records tracked upstream/official URLs and notes a source
  name that lacks a concrete tracked URL.

## Phase 0: Stocktake Foundation

### Task 0.1: Make `skill-stocktake` Codex/ECC aware

Description: Update the stocktake skill and scripts so this repo's
`.agents/skills` directory is a first-class scan target, not a workaround passed
to a Claude-oriented script.

Acceptance criteria:

- `skill-stocktake/SKILL.md` describes Codex/ECC paths accurately.
- `scripts/scan.sh` can scan `.agents/skills` by default when run from this repo.
- `scripts/quick-diff.sh` can compare against current repo skill paths.
- Claude-specific paths remain documented only as compatibility notes.

Verification:

- Run the scan script and confirm it reports 87 repository skills.
- Run quick-diff against a temporary or existing results file and confirm paths
  use the expected repo-local form.

Files likely touched:

- `.agents/skills/skill-stocktake/SKILL.md`
- `.agents/skills/skill-stocktake/scripts/scan.sh`
- `.agents/skills/skill-stocktake/scripts/quick-diff.sh`

Dependencies: None

Estimated scope: M

### Task 0.2: Refresh mechanical inventory

Description: Update inventory files so they stop claiming the repo has 86 skills
and include the new `strategic-ai-wall-partner` skill.

Acceptance criteria:

- `inventory/codex-skills.md` records 87 repository skills.
- `inventory/skill-use-classification.md` records 87 repository skills.
- `strategic-ai-wall-partner` is classified as DAILY, CONDITIONAL, or LIBRARY
  with evidence.
- The update date is refreshed.

Verification:

- Run `bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check`
  and confirm no mechanical drift remains.

Files likely touched:

- `inventory/codex-skills.md`
- `inventory/skill-use-classification.md`
- `.agents/skills/skill-use-manager/SKILL.md` if classification changes affect
  routing tables.

Dependencies: Task 0.1 preferred, but not strictly required.

Estimated scope: S

## Phase 1: Metadata Normalization

### Task 1.1: Fix frontmatter name mismatches

Description: Normalize `name` fields so routers and human readers can trust that
frontmatter names match skill directory names.

Known mismatches:

- `ci-cd-and-automation` currently reports `name: Rollback`.
- `e2e-testing` currently reports `name: E2E Tests`.
- `hookify-rules` currently reports `name: my-rule`.

Acceptance criteria:

- Every `.agents/skills/*/SKILL.md` has a `name` matching its directory.
- Descriptions remain short and trigger-oriented.
- No skill body is rewritten beyond metadata unless needed for consistency.

Verification:

- Run a shell check that compares directory basename to frontmatter `name`.
- Review `git diff` to confirm only intended metadata changed.

Files likely touched:

- `.agents/skills/ci-cd-and-automation/SKILL.md`
- `.agents/skills/e2e-testing/SKILL.md`
- `.agents/skills/hookify-rules/SKILL.md`

Dependencies: None

Estimated scope: XS

### Task 1.2: Decide `agents/openai.yaml` policy

Description: Decide whether all skills need `agents/openai.yaml` metadata or
whether it stays optional for skills that benefit from external routing.

Acceptance criteria:

- Policy is documented in `skill-use-manager` or inventory docs.
- The plan explicitly avoids adding boilerplate metadata to every skill without
  a routing benefit.
- Any required metadata gaps are listed as follow-up tasks.

Verification:

- Review the documented policy against current skill directories.

Files likely touched:

- `.agents/skills/skill-use-manager/SKILL.md`
- `inventory/skill-use-classification.md`

Dependencies: Task 1.1

Estimated scope: S

## Phase 2: Overlap Clusters

### Task 2.1: Split or merge TDD ownership

Description: Clarify the boundary between `tdd-workflow` and
`test-driven-development`.

Candidate direction:

- Keep `test-driven-development` as the general behavior-change testing skill.
- Narrow `tdd-workflow` to strict coverage/red-green workflows, or merge its
  useful content into `test-driven-development`.

Acceptance criteria:

- The two descriptions no longer trigger on the exact same broad task.
- `skill-use-manager` routes routine fixes to one default TDD skill.
- Any retained second skill has a clear stricter trigger.

Verification:

- Compare both SKILL.md files before and after.
- Confirm `skill-use-manager` routing table names the intended default.

Files likely touched:

- `.agents/skills/tdd-workflow/SKILL.md`
- `.agents/skills/test-driven-development/SKILL.md`
- `.agents/skills/skill-use-manager/SKILL.md`
- `inventory/skill-use-classification.md`

Dependencies: Phase 1

Estimated scope: M

### Task 2.2: Split security review from hardening

Description: Clarify `security-review` as review/checklist work and
`security-and-hardening` as implementation-time defensive design.

Acceptance criteria:

- `security-review` triggers on review/audit requests.
- `security-and-hardening` triggers on implementing or modifying sensitive
  behavior.
- Shared checklists are not duplicated more than necessary.

Verification:

- Check both skill descriptions and routing tables.
- Confirm references remain reachable after any movement.

Files likely touched:

- `.agents/skills/security-review/SKILL.md`
- `.agents/skills/security-and-hardening/SKILL.md`
- `.agents/skills/skill-use-manager/SKILL.md`

Dependencies: Phase 1

Estimated scope: M

### Task 2.3: Layer API, backend, and interface skills

Description: Make the boundaries between `api-design`,
`api-and-interface-design`, `backend-patterns`, and related frontend/backend
skills explicit.

Candidate direction:

- `api-and-interface-design`: public contracts and boundaries.
- `api-design`: REST details and conventions.
- `backend-patterns`: implementation patterns in backend codebases.
- `frontend-ui-engineering`: production UI execution.
- `frontend-patterns`: React/Next.js framework patterns.

Acceptance criteria:

- Each skill description has a distinct trigger.
- `skill-use-manager` routes to the smallest relevant skill set.
- No broad "use for all API/backend work" trigger remains in multiple places.

Verification:

- Run a text review of descriptions and routing rows.
- Use sample tasks to check which skill would fire.

Files likely touched:

- `.agents/skills/api-and-interface-design/SKILL.md`
- `.agents/skills/api-design/SKILL.md`
- `.agents/skills/backend-patterns/SKILL.md`
- `.agents/skills/frontend-patterns/SKILL.md`
- `.agents/skills/frontend-ui-engineering/SKILL.md`
- `.agents/skills/skill-use-manager/SKILL.md`

Dependencies: Phase 1

Estimated scope: M

### Task 2.4: Move legacy and alternate routers to library stance

Description: Keep compatibility/reference skills available while removing them
from the daily decision surface unless explicitly requested.

Candidates:

- `using-agent-skills`
- `continuous-learning`
- `everything-claude-code`

Acceptance criteria:

- Daily routing does not load alternate routers by default.
- Legacy skills explain their compatibility/reference role.
- Inventory records why each remains installed.

Verification:

- Review `skill-use-manager` daily/conditional/library tables.
- Confirm no task-critical workflow depends on a demoted skill.

Files likely touched:

- `.agents/skills/skill-use-manager/SKILL.md`
- `inventory/skill-use-classification.md`
- Candidate skill descriptions only if needed.

Dependencies: Phase 1

Estimated scope: S

## Phase 3: Long Skill Reference Split

### Task 3.1: Choose the first long-skill pilot

Description: Pick one high-line-count skill and split it into a compact
`SKILL.md` plus references. Use this as the pattern before touching many skills.

Candidates by current line count:

- `frontend-patterns`: 661 lines
- `backend-patterns`: 597 lines
- `coding-standards`: 549 lines
- `api-design`: 522 lines
- `security-review`: 494 lines
- `tdd-workflow`: 463 lines

Acceptance criteria:

- One pilot is selected with rationale.
- A target structure is written before moving content.
- The split preserves all unique operational content.

Verification:

- Compare old and new content for lost headings or examples.
- Confirm the compact `SKILL.md` still contains trigger, workflow, and routing
  instructions.

Files likely touched:

- One selected skill directory.
- Possibly `references/` under that skill directory.

Dependencies: Phase 2 preferred

Estimated scope: M

### Task 3.2: Apply reference-split pattern to remaining long skills

Description: After the pilot is reviewed, split the remaining long skills in
small batches.

Acceptance criteria:

- Each rewritten `SKILL.md` stays focused on when/how to use the skill.
- Detailed examples and long checklists live under `references/`.
- Relative reference paths are valid.

Verification:

- Run a link/path check for referenced files.
- Review each diff for content loss.

Files likely touched:

- Multiple long skill directories.

Dependencies: Task 3.1

Estimated scope: L, split into batches of 1-2 skills.

## Phase 4: Daily Surface Reduction

### Task 4.1: Reduce DAILY set

Description: Revisit the default daily skills so routine sessions do not load
too much process before the task is known.

Candidate daily set:

- `skill-use-manager`
- `verification-loop`
- `agent-self-review`
- `skill-stocktake`
- `strategic-compact`

Candidate demotions to CONDITIONAL:

- `agent-sort`
- `configure-ecc`
- `ai-automation-ops`

Acceptance criteria:

- DAILY contains only skills that shape most sessions in this repo.
- CONDITIONAL triggers preserve access to demoted skills.
- Classification docs and `skill-use-manager` agree.

Verification:

- Review a few recent task types and confirm the new daily set would still have
  routed them correctly.

Files likely touched:

- `.agents/skills/skill-use-manager/SKILL.md`
- `inventory/skill-use-classification.md`

Dependencies: Phase 0 and Phase 1

Estimated scope: S

## Phase 5: Reference URL Index

### Task 5.1: Maintain task-local reference URL index

Description: Keep a curated list of upstream and official URLs that influenced
the current skill surface, so future stocktakes can notice upstream changes,
duplicate references, or stale imports.

Acceptance criteria:

- `reference-urls.md` exists in this task folder.
- URLs are grouped by purpose.
- Sample URLs such as `localhost`, `example.com`, and placeholder API endpoints
  are excluded unless they are part of an actual dependency decision.
- Each URL lists the repo file that currently references it.

Verification:

- Run `rg 'https?://'` over relevant repo docs and compare against the curated
  index for notable omissions.

Files likely touched:

- `.agents/ecc-workflow/tasks/2026-06-30-skill-refactor/reference-urls.md`

Dependencies: None

Estimated scope: XS

## Checkpoints

### Checkpoint A: After Phase 0-1

- [x] Skill count and inventory agree.
- [x] Frontmatter names are mechanically consistent.
- [x] No skill behavior has been merged or deleted yet.

### Checkpoint B: After Phase 2

- [x] Major overlap clusters have clear ownership.
- [x] `skill-use-manager` reflects the new routing.
- [x] Merge/demotion decisions are documented with rationale.

### Checkpoint C: After Phase 3

- [x] Long-skill split pattern is validated.
- [x] At least one long skill has a compact body and references.
- [x] No reference path is broken.

### Checkpoint D: After Phase 4-5

- [x] Daily surface is smaller and documented.
- [x] URL index can support future update checks.
- [x] Final diff is reviewed for scope, secrets, and accidental host-specific state.

## Resolved Questions

- `skill-stocktake` supports Codex/ECC paths by default and retains
  `.claude/skills` as an explicit compatibility target through environment
  overrides.
- `agents/openai.yaml` stays optional. It is useful for exported,
  plugin-facing, cross-runtime, or externally routed skills, but local routing
  continues to use `SKILL.md` frontmatter.
- No skills were removed. Long skills preserve their original content in
  `references/full-guide.md`; future retire/merge work should still require a
  specific rationale.
