# Implementation Notes

## Relevant Context

- Shallow clones of both repos inspected under the session scratchpad
  (read-only; no writes to the game repos).
- Precedent: `observable-development-loop` addition (routing + inventory +
  mirror flow).

## Files To Inspect

- black-stela: `AGENTS.md`, `docs/gates/*.md` (esp. played-build-gate,
  past-trouble-regression-gate, browser-selfplay-gate, human-requirement-gate,
  player-facing-red-flags, screenshot-review)
- RePrise: `AGENTS.md`, `docs/task_completion_audit.md`, `tools/check_*.py`

## Plan

1. Extract gate-design lessons and genre conventions from both repos.
2. Keep the pasted SKILL.md as the skill body (fix CP932 mojibake in two
   lines); author the three missing references and the inspect script.
3. Route as LIBRARY (Games domain, beside `gamestudio-review`) since this
   repo has no game files; mirror to `~/.codex/skills` for game repos.
4. Update inventories via the documented write path.

## Decisions

- LIBRARY, not CONDITIONAL: matches `gamestudio-review` precedent — the
  trigger is a game repository, which this repo is not.
- Script is stdlib-only, read-only, bounded (20k files), and labels its
  output as discovery, not truth — consistent with the skill body.
- Kept the user's SKILL.md wording; added only a "Related skills in this
  repo" section for boundaries (gamestudio-review, observable-development-
  loop, ai-regression-testing, eval-bottleneck-reduction).

## Observability Contract

- Target: a skill whose referenced files all resolve and whose script runs
  against real game repos.
- Observation method: execute `inspect_game_project.py` on both cloned repos
  and read its actual output; grep routing surfaces for the skill name.
- Stable reference points: the two cloned repos at their 2026-08-11 HEAD;
  `update-inventory.sh --check` exit code.
- Deterministic checks: script exit 0 on both repos and 2 on a bad path;
  `py_compile` passes; inventory check passes; every `references/` and
  `scripts/` path named in SKILL.md exists.

## Verification Plan

- Run the script on black-stela and RePrise; confirm it finds their real
  gate surfaces (docs/gates, tools/check_*, npm gate:* scripts).
- `bash scripts/lint.sh`; `python3 -m py_compile` on the new script;
  `update-inventory.sh --check`.
