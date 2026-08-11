# PRD

## Goal

Turn the durable lessons and quality gates from `kino-6/black-stela` and
`kino-6/RePrise` into a reusable game-development skill, integrating the
user-provided `build-playable-games` SKILL.md as the base, and verify the
result works.

## Background

- The user pasted a SKILL.md authored in another session. It referenced
  `references/quality-gates.md`, `references/genre-lenses.md`,
  `references/source-lessons.md`, and `scripts/inspect_game_project.py` —
  none of which existed anywhere locally or in either game repo.
- Both game repos carry mature gate systems: black-stela `docs/gates/`
  (11 gate docs, played-build gate, self-play gate, trouble tables) and
  RePrise `AGENTS.md` + `tools/check_*.py` + `docs/task_completion_audit.md`.

## Scope

In scope: `.agents/skills/build-playable-games/` (SKILL.md + references +
script), LIBRARY routing, inventories, mirror to `~/.codex/skills`.
Out of scope: modifying the game repositories; commit/push.

## Acceptance Criteria

- Pasted SKILL.md preserved (mojibake fixed), all referenced files exist.
- References distill both repos' lessons with provenance, no invention.
- Inspect script runs read-only against both repos and finds their gates.
- Routing and mechanical inventory agree.

## Quality Bar

The references must carry the concrete incidents (why each rule exists), not
generic advice; the script must surface real gate surfaces in both repos.

## Human-Owned Judgment

Whether LIBRARY (vs CONDITIONAL) is the right bucket, and whether the lesson
compression kept the right incidents.

## Risks

- Lessons drift from the source repos as they evolve; source-lessons.md
  records paths so future sessions re-verify against the repos.
