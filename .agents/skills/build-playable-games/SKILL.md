---
name: build-playable-games
description: Inspect, plan, implement, and review game projects as player-facing products rather than feature checklists. Use for game prototypes or existing game repositories when Codex is asked to build gameplay, improve game feel or presentation, recover a project that is technically functional but low quality, create a vertical slice, tune balance, review UI or assets, add playtesting and screenshot gates, or decide what to build next. Supports Godot, browser/Canvas, and mixed-runtime projects, with special guidance for first-person DRPGs, 2D action games, terminal/menu RPGs, and retro-styled JRPGs.
---

# Build Playable Games

Treat the game the player runs as the product. Convert intent into one small, observable play experience, then prove it in the shipping runtime.

## Start with evidence

1. Read repository instructions and design authorities before proposing changes. Search for `AGENTS.md`, `CLAUDE.md`, `README*`, plans, ADRs, design docs, playtest notes, gates, and known-defect lists.
2. Run `scripts/inspect_game_project.py <repo> --markdown` for a quick inventory. Treat its output as discovery, not truth.
3. Identify the shipping runtime. Label archived prototypes, rules oracles, editors, simulators, and migration references separately. Never validate only a reference runtime when another runtime ships.
4. Locate the normal player entry point and the shortest complete loop. If either is unclear, inspect code and launch commands before editing.
5. Read [references/quality-gates.md](references/quality-gates.md). For genre-specific work, also read [references/genre-lenses.md](references/genre-lenses.md). When working on one of the source projects or adapting its lessons, read [references/source-lessons.md](references/source-lessons.md).

Do not begin with a broad rewrite. First state what is currently observable and what evidence is missing.
Discover engine versions, launch commands, controls, viewports, and intended loops from the repository before asking the user. Ask only for a design judgment or genuinely absent fact that would materially change the slice.

## Frame one playable slice

Write this contract before implementation:

```md
### Player slice
- Player fantasy:
- Start state:
- Player decisions:
- Feedback and consequence:
- End state:
- Shipping runtime:
- Normal controls:
- Human expectation:
- Known failure at risk:
- Non-goals:
- Automated proof:
- Played-build proof:
- Screenshot states:
- Balance signal, if applicable:
```

The slice must contain a decision, visible feedback, a consequence, and a loop-closing or progress state. "A scene opens," "an entity exists," and "a test can call the rule" are not playable slices.

Prefer improving the weakest core-loop slice over adding breadth. Block advanced content while known core-loop, control, readability, or presentation defects remain open.

## Build in player order

1. Make the route reachable through normal input.
2. Make game state and affordances visible without requiring logs or debug knowledge.
3. Make the action readable: anticipation, contact, feedback, recovery, and consequence.
4. Make the choice meaningful through cost, risk, timing, positioning, or resource pressure.
5. Add content only after the repeated loop is credible.
6. Preserve deterministic rules beneath presentation when the project already has that boundary.

Keep debug, provider, save-slot, authoring, and admin controls out of normal play unless the design explicitly makes them diegetic.

## Use two proof lanes

Maintain both lanes; never substitute one for the other.

### Mechanical lane

Use unit tests, deterministic simulations, reachability checks, schema validation, and balance batches to prove state transitions, invariants, content completeness, and statistical bands. Reuse production rules; do not copy simplified formulas into the test harness.

### Player lane

Run the shipping build through visible controls. Verify focus, controller or keyboard flow, screen fit, feedback, pacing, scene transitions, and persistence. Capture representative states and inspect the actual pixels. Headless success proves no visual quality claim.

For player-facing changes, require at least one test or probe that would fail on the pre-fix behavior. If a new gate is green before the defect is fixed, explain why it is genuinely discriminating or strengthen it.

## Review the result

Apply the evidence ladder and stop conditions in [references/quality-gates.md](references/quality-gates.md). Review at the minimum supported viewport and the primary presentation viewport. Check localized text when the project supports it.

For each human-found defect:

1. Fix the visible defect.
2. Add the smallest durable regression lock.
3. If an existing gate should have caught it, repair the gate as part of the same slice.
4. Record the failure in the project's existing trouble log or equivalent authority; do not create a parallel documentation system.

## Report completion honestly

Lead with the player-visible outcome. Then report:

- the normal route exercised in the shipping runtime;
- automated checks and what each proves;
- screenshots or played-build observations;
- remaining risks and unverified claims;
- the next weakest core-loop slice.

Do not claim "done," "playable," "polished," "controller-ready," or genre fidelity from compilation, headless reachability, asset existence, or passing reference-runtime tests alone.

## Related skills in this repo

- Use `gamestudio-review` when the ask is a multi-role critique or "what should we build next," not implementation with gates.
- Use `observable-development-loop` for the generic Observability Contract on non-game work; this skill is its game-specific specialization.
- Use `ai-regression-testing` for recurring AI-authored code regressions outside game runtimes.
- Use `eval-bottleneck-reduction` when the bottleneck is grading and review routing rather than play evidence.
