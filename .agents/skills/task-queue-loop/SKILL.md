---
name: task-queue-loop
description: Operate a repository's active task queue (Tasks.md / TASKS.md) as a loop - one lap carries one row from not-started to committed behind a gate that can FAIL, audited by a fresh context. Use when working from such a queue, when work drifts off it, when it has become a history dump, or when installing one.
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
4. **Write the gate and the minimum check, before the work.** The row is not
   startable until it names both: a **gate**, the command whose pass/fail proves
   completion, and a **minimum check**, the shortest command that can tell
   whether this row's change worked. Same contract for both - a command, a
   condition, and the ability to go red. They differ only in how often they run.
   **Write both into `Tasks.lock.json` too** - that copy is the seal. See
   [references/gates.md](references/gates.md).
5. **Confirm red on the minimum check first.** It is the cheap one, so it is
   where falsification belongs: watch it fail before you start. A check that
   cannot fail for this row is measuring the wrong thing.
6. **Do the work against the minimum check, then run the row's gate once.**
   Iterate on the seconds-long check. To close the row, run its own gate plus
   whatever the change could have affected and no green run covers - the **full
   suite waits for the push**. Then verify it yourself: render the real screen
   and actually read it, probe the real values. Headless `pass` is not a
   substitute for looking. Verification is the implementer's job - see Never.
7. **Commit.** Not done until committed. A commit is cheap and local, so it does
   not owe the full suite - **the full run is owed before the push**, and it is
   the backstop that makes every earlier skip affordable. Never commit or push on
   a red gate; if you think the red is unrelated, first prove it reproduces on
   the base branch.
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

1. The row's gate is green in the final run - not behind `test.fail()`, `xfail`,
   or any expected-failure marker. The row's gate is its own proving command, not
   the whole suite; the suite runs before the push.
2. You verified the real build or the real values yourself.
3. A one-command reproduction exists and is named in the row: a fixture name, a
   boot flag, a `--state=` scenario. "Walk there in game" and pointing at a
   `.png` do not count.
4. The change is committed.

Flip `passes` to `true` in `Tasks.lock.json` at the same time. That flip is the
only edit an agent makes to a locked row without an amendment.

Those four make the row **`[x]`-proposed**; it is archived only after the step 8
audit returns `GATE_VALID`.

**A human play-through is never a completion condition.** Keep exactly one `[x]`
row in the queue as a boundary marker so the next session can see where the last
lap ended; everything older moves to the archive.

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
- Loosen a sealed gate to match what the work did. Changing a locked 最小検証 or
  Gate takes an amendment naming the field and the reason; the pre-commit hook
  refuses anything else.
- Iterate on the full suite, put the suite in a row's Gate column, skip on a
  belief, skip the pre-push full run, delete a gate because the suite is slow, or
  parallelise before narrowing. **Shrink the run, not the suite** - the rules and
  their reasons are in [references/gates.md](references/gates.md).

## Installing a queue in a new repo

Copy the templates and fill them in **in the repository's working language** -
a fresh session with this skill not loaded has to be able to operate the queue
from the queue header plus the file it points at:

- [templates/Tasks.md](templates/Tasks.md) - the queue. A 40-line header: the
  READ FIRST block, the placement map, the column and status legend, and the
  cadence in one line. Nothing else - the queue does not restate the rules.
- [templates/work-rules.md](templates/work-rules.md) - the rules the header
  points at: the 最小検証 / Gate / 再現 contract, narrowing and parallelisation,
  the four-part definition of done, the second-perspective check, and the
  prohibitions. Read before starting and before writing `[x]`.
- [templates/CHARTER.md](templates/CHARTER.md) - purpose, goal, approach, scope,
  completion criteria, constraints. The queue links to it and says "read both at
  every lap entry".
- [templates/Tasks-archive.md](templates/Tasks-archive.md) - where `[x]` rows go,
  one record per task with its gate and date.
- [templates/gate-auditor.md](templates/gate-auditor.md) - drop into the repo's
  `.claude/agents/` (or mirror as a Codex role) so step 8 has someone to dispatch.
- [templates/Tasks.lock.json](templates/Tasks.lock.json) +
  [scripts/check_tasks_lock.py](scripts/check_tasks_lock.py) (copy to `tools/`) +
  [templates/hooks/](templates/hooks/) - the sealed contract behind each started
  row. People read Tasks.md; the lock is what the agent may not quietly change.
  `pre-commit` checks the lock, `pre-push` checks it against upstream and runs
  the full gate. Set an upstream, or `pre-push` can only see uncommitted drift.

Prune the templates to what the repo needs. **The queue holds work; the rules
file holds rules** - the longest queues surveyed carry the thinnest headers (8
lines against 178 and 197), because header weight and room for rows trade off.

## Sub-skills

Load only when the problem shows up.

- **[references/runtime-contract.md](references/runtime-contract.md)** - step 6 is
  expensive: no single launch command, agent runs steal the human's window,
  verification waits for the human to stop playing, or a screenshot cannot tell
  which build it came from. Costly observation degrades into "headless pass, ship
  it".
- **[references/trouble-registry.md](references/trouble-registry.md)** - the same
  *class* of mistake keeps coming back. Store counted **types**, not incidents;
  append automatically, block the commit until each is classified.

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
