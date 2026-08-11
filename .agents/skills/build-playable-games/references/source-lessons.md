# Source Lessons

Provenance for [quality-gates.md](quality-gates.md) and
[genre-lenses.md](genre-lenses.md). Read this when working inside one of the
source repositories or when adapting a lesson and its original context
matters. Paths are relative to each repository.

## black-stela (`kino-6/black-stela`)

First-person DRPG. TypeScript/React is the rules and content-schema oracle;
Godot is the shipping runtime and consumes normalized exports. Playwright
drives browser evidence; `verify_*.gd` scripts drive Godot gates.

Gate authorities to read before working there:

- `AGENTS.md` — blocking completion rules, controller-first UI contract,
  dungeon and combat standards, "Lessons From Strong User Feedback".
- `docs/gates/` — eleven gate documents. Load-bearing ones:
  - `played-build-gate.md` — why 21 defects passed every green gate, and the
    G1–G4 executable gates plus P1–P3 process rules that answer it.
  - `past-trouble-regression-gate.md` — per-defect tables (past failure →
    blocking expectation → regression cover) and the completion note
    template.
  - `browser-selfplay-gate.md` — normal-controls-only self-play with named
    failure categories (`blocked_control`, `visual_mismatch`,
    `controller_input`, …).
  - `human-requirement-gate.md`, `player-facing-red-flags.md`,
    `screenshot-review.md` — human expectation, red-flag checklist, and fixed
    screenshot states.

Durable lessons with their incidents:

- **The gate played the wrong program.** `gate:final` booted the React
  reference via Playwright's `webServer` while players received the Godot
  build. A 3-minute human playtest found ~21 defects — auto-return after
  combat, map reset, held-key not repeating — that no gate could see.
- **The gate was the first defect.** The self-play route clicked through with
  `locator.click()`, so a screen with no keyboard entry point passed a
  "controller-first" gate. Fix: count real pointer events, check all four
  viewport edges per command.
- **Known defects were deferred under new content.** `Improve.md` recorded
  the exact defects months earlier as "Reproduced", marked "V pending", while
  advanced vocations shipped on top. Hence the base-playability guard.
- **Green tests, dead command.** Party-scope wards resolved correctly in
  units; the UI's ally/enemy branch dropped the order. Same bug written twice
  in both runtimes, found only by driving each UI.
- **Ports drifted on copied literals.** Five hardcoded GDScript tables
  silently excluded everything authored after them; parity stayed green
  because traces only walked the original four techniques. A parity suite is
  only as strong as the paths it walks.
- **Nondeterministic oracle.** The trace fixture seeded ids from
  `crypto.randomUUID`; 5/60 runs failed on a clean tree until the fixture was
  built under deterministic ids.

## RePrise (`kino-6/RePrise`)

Godot 4, SFC-styled run-based JRPG. Single runtime; Python tools are the gate
harness; assets are generated, never hand-edited.

Gate authorities to read before working there:

- `AGENTS.md` — the six checks that must all pass before finishing
  (`tools/test_core.py`, `tests/balance.gd`, `tools/check_ui.py`,
  `tools/check_assets.py`, `tools/check_terms.py`,
  `tools/check_abilities.py`), invariants (determinism, LLM boundary,
  loss/permanence boundary), capture states (`--shot=` / `--inspect=`),
  input-only autoplay (`--play=N`), and the pitfalls list.
- `docs/task_completion_audit.md` — the reverse audit of "completed" tasks
  against runtime reality; source of most false-positive-gate lessons.
- `docs/tasks_archive.md` + `tools/tasks_status.py` — archive discipline:
  one task one record, `Gate:` line with date and result required.

Durable lessons with their incidents:

- **All green, still not done.** The 2026-07-31 audit found every standard
  check green while: 60/64 events changed no state (a test asserted
  `INFORMATIONAL.size() > 0`, freezing non-implementation as success), the
  LLM boundary existed in two places instead of the mandated one, and the
  asset checker praised partial wiring with exit 0.
- **The simulator must play the real game.** The old balance harness modeled
  "4 fights per floor" by hand and measured a structure that did not exist.
  The rebuilt one calls only production components and fails outside the
  band; judgment uses the strongest policy, and a winning rush policy means a
  design decision died.
- **Autoplay found what checks could not.** Feeding input only (never
  internals) surfaced: 54% of play time in combat, chronicle text overflowing
  its window, random-walk exploration never leaving floor 1, and any UI jam
  as a detectable stall.
- **A wrong metric is worse than none.** Sprite-similarity scoring on
  whole-body overlap flagged the wrong pairs for redraw; measuring only the
  differing protrusions fixed it. "An index that orders the wrong redraws is
  worse than no index."
- **Look and listen mechanically when you cannot.** Kanji below 13px proved
  unreadable by side-by-side capture; audio is verified by silence/pitch/clip
  analysis because an agent has no ears; screenshots exist per screen id so
  looking is one command.
- **Process hygiene is a gate subject too.** Orphaned Godot processes
  accumulated to 41 and exhausted the Windows desktop heap, presenting as
  unrelated startup failures — hence `tools/godot_run.py` owns every launch
  and reaps.
