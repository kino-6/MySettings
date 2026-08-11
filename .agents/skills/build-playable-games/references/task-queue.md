# Task Queue Conventions (Tasks.md)

How to write and run a repository's active task queue file (`Tasks.md` or
equivalent). Distilled from the operating rules of `kino-6/black-stela`
(dual-runtime task queue with named gates and fixtures) and `kino-6/RePrise`
(archive discipline: one task one record, a `Gate:` line with date and
result). If the target repository already carries a rules header inside its
own Tasks.md, that in-repo header is authoritative; this file is the
transferable version.

The two load-bearing ideas: every task names a gate that can FAIL, and
"done" requires self-verification plus a one-command reproduction. A task
without those is a wish, not work.

## The file is an active queue

Tasks.md holds only work being done now. History, completed items, and
design philosophy live elsewhere (see Placement). A queue mixed with history
stops being read, and stale entries get re-implemented or silently skipped.

## Every task is one self-contained block

Required elements — a task missing any of them can be neither started nor
judged complete:

- **ID and one-line title**, phrased as a verb: what, once achieved, ends
  the task (`#18 — Reach the Equip screen with arrow keys only`).
- **Provenance**: who raised it, the date (convert relative dates to
  absolute at write time), and whether it came from a real played build
  (`user 2026-08-12, played-build screenshot`).
- **Gate**: name a specific test or gate that can FAIL headless, concretized
  to numbers and key names — not "does not overflow" but "at 1280×720 every
  command is on screen; assert bottom edge ≤ 720". Only when no such gate
  can be written, spell out an explicit manual/visual check procedure
  instead. See the falsification rule in
  [quality-gates.md](quality-gates.md): a gate that is green before the fix
  proves nothing.
- **Truth source and parity**: which runtime owns the rule or data and
  whether the change must land in both runtimes (e.g. React/TS is the rules
  oracle, Godot follows; state whether parity work is in scope).

Example block:

```md
- [ ] #18 — Reach the Equip screen with arrow keys only
  - From: user 2026-08-12, played-build screenshot
  - Gate: `gate:ui-nav` — at 1280×720, Equip gains focus within 4 arrow
    presses from the command menu; assert focused node id
  - Truth source: React/TS rules; Godot must follow (parity in scope)
  - Repro: fixture `equip_screen_min` / boot flag `--scene=equip`
```

## Status markers

`[ ]` not started · `[-]` in progress · `[x]` complete (awaiting archive).

## Definition of done

Do not mark `[x]` until all four hold:

1. The gate is green in the final gate run — not hidden behind
   `test.fail()` or any expected-failure marker.
2. You verified the real build or real values yourself: for player-facing
   work, render the PNG without `--headless` and actually READ it; probe
   actual values; run the gate.
3. A one-command reproduction exists and is named in the task: a debug
   fixture name or a boot flag. Pointing at a `*.png` or writing "walk
   there in game" does not count.
4. The change is committed.

## Groom in the same edit

Whenever a status changes, in that same edit: move `[x]` items to the
archive file, leave a one-line pointer in Tasks.md, and collapse verbose
completion notes. The queue holds active work only.

## Never

- Commit or push on a red gate, or park a red gate as "unrelated/WIP". If
  you believe the red is unrelated, first prove it reproduces on `main`.
- Put "user plays and approves" in a checklist. Verification is the
  implementer's job; the user receives specific questions that require
  judgment, never verification chores.
- Mix unapproved future design ideas into the queue. Move them to design
  docs or the archive marked as deferred.

## One task, top down

Process the queue in order. Finish one task — verification, green gate,
commit — before starting the next.

## Placement

- Completed history: `docs/archive/Tasks.completed-YYYY-MM.md` (or the
  project's existing archive; do not create a parallel one).
- Lane split when multiple agents share the queue: name the lanes in the
  header (e.g. Codex owns art/assets and visual sign-off; Claude owns
  rules/data/renderer wiring/parity/gates). The implementer never
  self-approves their own visual work — see "Do not self-approve taste" in
  [quality-gates.md](quality-gates.md).
- Unapproved future design: `docs/design/…`.

## Installing these rules in a repository

Paste the rules as a "READ FIRST — all agents" header at the top of the
repository's Tasks.md, in the repository's working language, covering: the
active-queue purpose, the required task elements, status markers, the
four-part definition of done, same-edit grooming, the prohibitions, the
one-task-top-down order, and the placement map. Other models and fresh
sessions must be able to operate the queue from that header alone, without
this skill loaded.
