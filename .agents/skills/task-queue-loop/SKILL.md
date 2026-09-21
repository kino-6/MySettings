---
name: task-queue-loop
description: Run repository work as a Tasks.md lap - read the queue and its rules file at every lap entry, take one item top down, write a gate that can FAIL, verify it yourself, commit, hand the row to a fresh-context auditor that attacks the gate and files refactoring rows, and groom the queue in the same edit. Use when starting or continuing work in a repo with an active task queue (Tasks.md / TASKS.md), when work drifts off that queue, when the queue has become a history dump, or when installing one in a new repo. Templates in templates/. Two on-demand sub-skills: references/runtime-contract.md (launcher entry point, shadow tree, headless agent lanes that never take window focus, capture, seeds, version stamping, gated recording) and references/trouble-registry.md (repeated failures generalised into counted types, enforced at commit time).
---

# Task Queue Loop

A `Tasks.md` is not a todo list. It is the **state of a loop**, and each lap is
one task carried from "not started" to "committed with a green gate". The file
exists so that a fresh session, a different model, or the user tomorrow can
re-enter the loop at the same place without being told anything.

This is not the `/loop` interval runner (that reruns a prompt on a timer). This
skill is the work discipline: what one lap is, and what the file must say for the
next lap to start correctly.

## The lap

1. **Entry: read the queue and its rules file.** Every lap, not just the first.
   The queue file alone is not enough - it deliberately holds only work, so the
   purpose, goals, and completion criteria live next to it (`CHARTER.md`,
   `docs/work-rules.md`, or whatever the repo already uses). Read both before
   touching anything.
2. **Confirm the topic is on the queue.** If the thing you are about to do is
   not a row in the queue, either add it as a row first, or state plainly that
   this lap is a detour (`脇道`) and why. Silent off-queue work is how a queue
   stops describing reality.
3. **Take the top item.** One at a time, top down. Do not open a second item
   because the first is blocked - move the blocked one to `[~]` / `[!]` with the
   reason and take the next.
4. **Write the gate before the work.** The row is not startable until it names a
   gate: a command whose pass/fail a machine or an image can decide. See
   [references/gates.md](references/gates.md) for what counts and what does not.
5. **Confirm the gate is red now.** A gate that is already green before the fix
   proves nothing. If you cannot make it fail, the gate is measuring the wrong
   thing.
6. **Do the work, then verify it yourself.** Render the real screen and actually
   read it; probe the real values; run the gate. Headless `pass` is not a
   substitute for looking. Verification is the implementer's job - see Never.
7. **Commit.** Not done until committed. Never commit or push on a red gate; if
   you think the red is unrelated, first prove it reproduces on the base branch.
8. **Audit from a second perspective.** Dispatch a fresh-context agent that
   attacks the gate rather than the diff: revert the change and prove the gate
   goes red, mutate the behaviour and prove it goes red again, run the named
   repro, read the artifact. Its verdict either closes the row or sends it back,
   and its refactoring proposals enter the queue as rows with their own gates.
   See [references/gate-audit-loop.md](references/gate-audit-loop.md).
9. **Groom in the same edit, then loop.** Update the status, move finished rows
   to the archive leaving a one-line pointer, collapse the verbose completion
   notes. Grooming happens at commit granularity - not "later".

## Status markers

`[ ]` not started, or waiting on an external verdict ·
`[-]` in progress ·
`[x]` gate and any required image check are done ·
`[~]` needs a human judgement call ·
`[!]` blocked by an external user/system action

Use only the markers the project actually needs; `[ ]` `[-]` `[x]` is the
minimum set. Two rules regardless of which set:

- A partially done row spells out its own breakdown with nested `[x]` / `[ ]`.
- When you interrupt a `[-]`, write how far you got into the state column. The
  next lap starts from that sentence.

## Definition of done

Do not write `[x]` until all four hold:

1. The gate is green in the final run - not behind `test.fail()`, `xfail`, or any
   expected-failure marker.
2. You verified the real build or the real values yourself.
3. A one-command reproduction exists and is named in the row: a fixture name, a
   boot flag, a `--state=` scenario. "Walk there in game" and pointing at a
   `.png` do not count.
4. The change is committed.

Those four make the row **`[x]`-proposed**. It is only archived once the step 8
audit returns `GATE_VALID`; a `GATE_BROKEN` verdict sends it back to `[-]` and the
gate gets fixed before the code. The commit stands either way - the fix continues
on the branch rather than rewriting history.

**A human play-through is never a completion condition.** Keep exactly one `[x]`
row in the queue as a boundary marker so the next session can see where the last
lap ended; everything older moves to the archive.

## The audit is what makes it a loop

Steps 4-6 are all run by the context that produced the diff, so the loop's one
structural hole is self-approval: the implementer reads a green gate as
confirmation because they know what the fix was meant to do. Step 8 closes it by
handing the row to a perspective that was never told why the fix is correct.

The reason this is a loop and not a checkpoint: **the audit's output is work.**
A broken gate sends the row back with a counterexample; a valid gate archives with
the falsification recorded as part of its 証跡; and either way the refactoring
proposals become new rows that will themselves be audited. Verification never
just ends in an approval.

Run it per row, not per edit. [references/gate-audit-loop.md](references/gate-audit-loop.md)
has the checks, the verdict contract, how the three verdicts translate into queue
edits, and how to make the step mechanical rather than remembered - a hook on the
queue file that refuses a fresh `[x]` without a recorded verdict.

## Invariants of the file

- **Cap it.** Keep the queue at or under 200 lines. Over the cap is the signal
  to archive, not to widen the file.
- **Active work only.** History, design rationale, long RED/GREEN logs, and
  unapproved future ideas are not queue content. They have their own homes -
  write the placement map into the queue header so there is no guessing.
- **One reader per question.** If "when does this open?" can be answered from
  three places, two of them will silently drift. The queue points at the one
  owner.
- **One row per ID, updated in place.** Do not add a dated "Current Truth"
  section or a second board for the same problem each time it moves.
- **Declare the next ID.** Put `next ID: T610 以降` in the header so parallel
  sessions cannot collide, and bump it when you file a row.
- **Group into mainlines with dates** (`本線 C — ... (2026-09-16〜)`) once the
  queue outlives a single theme. The mainline is what gets reported on; the rows
  are not the reporting unit.

## Never

- Commit or push on a red gate, or park one as "unrelated / WIP".
- Put "the user plays it and approves" in a checklist. The user receives
  questions that genuinely need their judgement, never verification chores.
- Read a headless `pass` as a visual pass.
- Mix unapproved future design into the queue.
- Batch unrelated diffs into a commit just to get a row closed.
- Let a row exist without a gate. A row whose gate cannot be written is not yet
  a task - park it as a note until it can be.

## Installing a queue in a new repo

Copy the templates and fill them in **in the repository's working language** -
the header has to be operable by a fresh session with this skill not loaded:

- [templates/Tasks.md](templates/Tasks.md) - the queue, with the READ FIRST
  header, the placement map, and the status legend.
- [templates/CHARTER.md](templates/CHARTER.md) - purpose, goal, approach, scope,
  completion criteria, constraints. The queue links to it and says "read both at
  every lap entry".
- [templates/Tasks-archive.md](templates/Tasks-archive.md) - where `[x]` rows go,
  one record per task with its gate and date.
- [templates/gate-auditor.md](templates/gate-auditor.md) - drop into the repo's
  `.claude/agents/` (or mirror as a Codex role) so step 8 has someone to dispatch.

Prune the template to what the repo needs. A queue with sections nobody writes
into is as dead as a queue full of history.

## Sub-skills

Two documents that are part of this skill but are only worth loading when their
problem shows up. Both were distilled from the same local repositories as the
loop itself.

- **[references/runtime-contract.md](references/runtime-contract.md)** - load when
  step 6 is expensive: no single launch command, agent runs steal the human's
  window, verification has to wait for the human to stop playing, or a screenshot
  cannot tell you which build it came from. Step 6 quietly degrades into
  "headless pass, ship it" whenever observing the real thing is costly, so this is
  what keeps the loop honest rather than an optional nicety.
- **[references/trouble-registry.md](references/trouble-registry.md)** - load when
  the same *class* of mistake keeps coming back, or before writing a conclusion or
  a report. The gate audit catches a bad gate on one row; this catches the mistake
  you will repeat on the next twenty. Its core move is storing counted **types**
  rather than incidents, with appending automated and classification enforced by a
  commit block.

## Related

- [references/gates.md](references/gates.md) - writing a gate that can fail.
- [references/gate-audit-loop.md](references/gate-audit-loop.md) - the
  second-perspective audit: checks, verdict contract, wiring, cost control.
- [references/collected-practice.md](references/collected-practice.md) - which
  local repositories each rule was distilled from, for tracing a rule back.
- `observable-development-loop` - use with this skill when the result cannot be
  judged from the diff and needs an Observability Contract.
- `build-playable-games` carries `references/task-queue.md`, the game-project
  cut of these same conventions; this skill is the general version.
