# Genre Lenses

Genre conventions are solved problems; departing from them is a design
decision, not a default. Evidence sources: `black-stela` (first-person DRPG),
`RePrise` (retro-styled JRPG roguelite).

## First-person DRPG (Wizardry / Etrian lineage)

- The labyrinth is a continuous grid with walls, doors, stairs, and
  current-cell actions — never room cards linked by exits. View, movement, and
  minimap must derive from the same map truth.
- Combat commands advance through party members in formation order; clicking
  an arbitrary actor card is a web list, not a command RPG.
- Controller/keyboard first: every screen has a focus landing point, a way
  out, one focus ring, and confirm/cancel semantics. What looks selected IS
  what is focused. Mouse is a secondary convenience.
- Attrition is the genre's economy: return and recovery are paid, authored
  affordances, never free escapes that erase risk.
- Affordances are visible before use — enemies, stairs, traps, rewards exist
  on screen, not only in logs.
- Red flags: top bars, config panels, save-slot buttons, provider settings,
  raw route ids, coverage grades, product copy on the title screen — the game
  reads as an admin dashboard.
- Town services are counters, not lists: show what needs deciding, the price,
  and before/after. A completion screen says one thing; administration lives
  behind a command.
- Character creation carries the fantasy of making adventurers: staged
  choices, rerollable texture, visible front/back rows — not a data-entry
  form.

## Retro-styled JRPG / run-based (SFC lineage)

- Determinism per seed: terrain, encounters, damage, and turn order replay
  identically. One RNG service; no wall-clock or raw `randi()` in logic.
- One run = one world: generated worlds must be completable — a single
  unreachable goal wastes the whole run. Reachability is a mechanical gate.
- Balance is measured, never felt: run the simulator per policy and judge by
  bands. If the degenerate policy (rush, ignore everything) starts winning,
  a design decision is dead even though the numbers "pass".
- Every ability needs a reason to press it; a strictly-worse duplicate fails
  mechanically. "Cheaper but weaker" is a legitimate difference.
- Platform constraints (palette, resolution, sprite size, audio profile) are
  enforced by tools, not by memory.
- Legibility is measured: minimum glyph sizes per script (kanji need more
  pixels than kana), overflow checks per screen, text placed by top-left
  contract.
- Distinguish characters by silhouette, not palette swap; measure similarity
  on the parts that differ (headgear, weapons, outlines), not whole-body
  overlap.
- If an LLM writes flavor text, it names things only: structure and numbers
  come from the game, output is validated before display, and the game is
  complete when generation fails.

## 2D action

- Readability beats complexity: every attack has anticipation, contact,
  feedback, and recovery the player can see at game speed.
- Feedback is local to the struck subject; never full-screen flashes.
- Fairness is mechanical: hitboxes match silhouettes, and deaths trace to a
  visible cause.
- Input latency and held-key repeat are gate subjects — "hold to move" that
  steps once is a real shipped defect class.

## Terminal / menu RPG

- The menu tree is the world: every screen is enterable, exitable, and
  navigable by the documented keys; a dead end is a blocking defect.
- State the player must weigh (HP, resources, position in the loop) is on
  screen at decision time, not scrolled away.
- Fixed-width layout is a viewport: line width, wrapping, and alignment are
  checkable properties; capture real terminal output as the screenshot lane.
