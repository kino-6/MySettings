# Quality Gates

Distilled from `kino-6/black-stela` (dual-runtime DRPG) and `kino-6/RePrise`
(Godot SFC-style roguelite JRPG). Both projects paid for these rules with real
shipped defects; the incidents live in
[source-lessons.md](source-lessons.md).

## Evidence ladder

Order evidence from weakest to strongest. A claim may only be made at the
level its evidence reaches.

1. **Compiles / boots headless** — proves reachability of code, nothing about
   play.
2. **Unit tests and deterministic simulation** — prove rules and invariants.
   They cannot prove a player can reach the behavior.
3. **Driven UI / self-play in the shipping runtime** — proves the route exists
   through normal input.
4. **Screenshots and rendered-text checks** — prove what is actually on
   screen, at declared viewports, in each supported locale.
5. **Human play** — proves feel, taste, and product fit. Never simulated away.

"Green unit tests, dead command in the game" is the canonical failure: the
resolver worked, every test passed, and the menu item did nothing because the
UI branch never routed to it. Only level 3+ evidence catches that class.

## Gate design rules

1. **Gate the shipping runtime.** black-stela's truth-gate ran the React
   reference app while the shipped artifact was the Godot build; 21 defects a
   human found in 3 minutes were architecturally invisible to every green
   gate. When two runtimes exist, at least one gate must drive the one players
   receive.
2. **Falsify every new gate.** Break the mechanic, watch the gate go red,
   restore it. A gate that is green before the defect is fixed proves nothing.
   Known cases: a self-play route that clicked with a mouse so "keyboard-only"
   could never fail; `test.fail()` markers that Playwright reports as PASS
   (strip them in the final gate); an assertion on one axis (`scrollWidth`)
   while the overflow was on the other.
3. **Advisory output is not a gate.** A checker that prints failures but exits
   0 will be read as green forever. RePrise's audit found 24 failing
   candidates behind exit code 0, and partial asset wiring reported as
   success. Detection and verdict must not be separated: fail, or list the
   exemption by ID in an allowlist.
4. **A success condition must demand the implementation, not record its
   absence.** A test asserting `INFORMATIONAL.size() > 0` froze
   not-implemented as passing. Assert the state change the feature promises.
5. **Follow content end to end.** Authored data is shipped only when a player
   can obtain it, see it, and select it in the real UI — type, loader schema,
   catalog, shop/menu, target picker. Schema loaders silently strip unknown
   fields; count candidate → generated → runtime-referenced stages and fail on
   generated-but-never-referenced.
6. **Do not copy the model into the measure.** A balance simulator must call
   the same production components as real play (world gen, routing, encounter,
   combat, auto-policy). RePrise's old simulator embedded a hand-written "4
   fights per floor" model and measured a structure that did not exist —
   worse than broken.
7. **Drive the state a check needs; never hope for it.** A recovery-screen
   test relied on the party happening to be wounded and passed only on the day
   it was written. If a screen needs a state, produce it and fail loudly when
   it cannot be reached.
8. **A deterministic oracle must itself be deterministic.** A parity fixture
   seeded from `crypto.randomUUID` failed 5 times in 60 runs on an unmodified
   tree and trained everyone to re-run until green. Fix the seed; a trace that
   exercises a conditional must guarantee the condition, not roll for it.
9. **A gate nothing runs is a file.** black-stela's only Godot loop check had
   been red for months ("it was not in any gate, so nothing said so"), and a
   capture harness called methods that no longer existed. Wire every gate into
   the command that defines done, and treat a failing gate script as a build
   break.
10. **Autoplay feeds input, not internals.** RePrise's autoplay injects only
    key events, so any UI jam stops progress and is detected as a jam. It
    found real defects mechanical checks missed: 54% of play time in combat,
    log overflow, exploration that never left floor 1.
11. **Ports read exported data, never copies.** Hardcoded literals in a second
    runtime do not error when the source grows; they silently exclude. After
    fixing a UI bug in one runtime, look for the same wrong assumption in the
    other — it was usually written twice.
12. **Look at the pixels.** For visual work, capture fixed screenshot states
    (same scene ids, same viewport, same seed/preset) and actually view the
    image before claiming done. Rendered-text checks (size, overflow, locale)
    back the eyes mechanically.

## Stop conditions and process rules

- **Base playability outranks new content.** While a reproduced core-loop,
  control, readability, or presentation defect is open, no advanced-content
  slice may be called complete. "Visual acceptance pending" is not a done
  state.
- **Every hand-found defect earns a lock — and, when a gate should have
  caught it, the missing gate too.** Fixing only the defect leaves the hole
  that shipped it.
- **Completion records carry evidence.** A finished task records the gate
  command, run date, result, and the screenshot path for visual work. Archive
  the "why", keep task IDs unique, and never delete an unimplemented request —
  move it, with both IDs cross-referenced.
- **Do not self-approve taste.** Visual and feel acceptance on the real build
  belongs to a second reviewer (another agent or the user), not the
  implementer.
- **Escalate genuinely subjective calls.** Balance targets, mood, and product
  taste are human-owned; report the evidence and stop.

## Completion note template

```md
Past trouble checked:
- Could recur:
- Gate used (command, date, result):
- Played-build / browser evidence:
- Headless limitation:
- Remaining risk:
- Lock added (or missing gate repaired):
```
