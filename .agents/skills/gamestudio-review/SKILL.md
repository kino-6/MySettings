---
name: gamestudio-review
description: Multi-role game studio review for game design, playtest logs, balance, UX, and implementation planning. Use when Codex is asked to make a game more fun, critique a game feature, analyze a playtest/headless run, propose next development items, or turn design direction into an implementation plan.
---

# GameStudio Review

Use this skill to simulate a compact game studio inside one Codex pass. It is
especially useful for roguelikes, incremental games, automation-heavy games,
playtest log reviews, feature prioritization, and "what should we build next?"
questions.

## Core Workflow

1. **Gather evidence first.**
   Read the current design docs, relevant code, tests, recent logs, screenshots,
   and active branch diff. Do not judge fun from a single headless metric unless
   the user explicitly asks for a metric-only read.

2. **Run a short studio pass.**
   Use these roles internally, then synthesize instead of dumping six separate
   essays:
   - Game Director: player fantasy, emotional arc, and priority.
   - Systems Designer: rules, resource loops, incentives, and failure recovery.
   - Roguelike Designer: identification, risk, unfairness, tactical outs.
   - Spectator UX Designer: whether a viewer can read danger and intent.
   - Balance Analyst: seed evidence, rates, breakpoints, and missing telemetry.
   - Implementation Lead: smallest coherent implementation slice.

3. **Name the player-experience problem.**
   State the problem as a gameplay sentence, not a code sentence.
   Example: "The AI made a smart escape, but the player cannot tell why it was
   smart until reading the log afterward."

4. **Separate design from implementation.**
   Keep "why this improves play" separate from "what files change." Avoid
   starting with code tasks before the experience goal is clear.

5. **Choose one or two next slices.**
   Prefer a playable vertical slice over a wide feature list. Include explicit
   validation: seed, scenario, GUI behavior, headless signal, or tests.

## Output Shape

For a design/review request, answer in this order:

1. **面白さの軸**: the intended player/viewer experience.
2. **現状の読み**: what current evidence says, including uncertainty.
3. **改善案**: 3-5 options, with tradeoffs.
4. **次の実装計画**: small ordered steps, each testable.
5. **確認方法**: seeds, tests, logs, or GUI checks.

For an implementation request, compress the review and then implement:

1. State the selected slice in one short update.
2. Modify code/docs/tests.
3. Verify with focused tests and, when relevant, GUI/manual seed guidance.
4. Commit only intentional files if the user asked for commit.

## AutoRogue Defaults

When working in AutoRogue:

- Treat "watching automation" as a first-class experience, not just a debug view.
- Make AI choices legible through short in-game logs and visual cues.
- Preserve manual play paths when adding automation behavior.
- Prefer tactical outs: throw, scroll, wand/staff, movement, search, retreat.
- Prefer balance/config files for numeric tuning unless the codebase already
  encodes the rule in source.
- Do not commit runtime saves such as `autorogue_save.json.backup`.

Read `references/autorogue-studio.md` when the task is specifically about
AutoRogue design direction, tactical-item behavior, intervention builds,
monster houses, traps, or spectator UX.
