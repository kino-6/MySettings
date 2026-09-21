# The gate audit loop

The person who wrote the gate is the worst judge of whether it works. They know
what the fix was supposed to do, so they read the green as confirmation instead of
as evidence. This is the loop's one structural hole: steps 4-6 of the lap are all
run by the same context that produced the diff.

The fix is a **second perspective with no access to the first one's reasoning**,
run automatically on every `[x]` transition, whose output is new queue rows. That
makes verification productive rather than a checkpoint: an audit either closes the
row or files the next lap.

```
implementer lap ──[x] proposed──▶ auditor (fresh context)
                                    │
             ┌──────────────────────┼──────────────────────┐
        GATE_BROKEN            GATE_VALID             REFACTOR
     row back to [-]        row closes, archived    new rows filed
        with the            with the audit           with their own
       counterexample           verdict                 gates
             └──────────────────────┴──────────────────────┘
                              next lap
```

## What the auditor is given, and what it must not be given

Give it: the row (title, なぜ, Gate, 再現), the diff, the gate command, the
produced artifacts, and the repository's rules file.

Do **not** give it: the implementer's narrative of why the fix is correct, the
transcript, or the commit message body. A fresh context is the whole mechanism -
an auditor told "the fix works because X" audits X, not the code.

## Check 1 — gate falsification (the load-bearing one)

The auditor's first job is to attack the gate, not the code.

1. **Revert-and-run.** Stash or revert the diff, run the gate. **It must go red.**
   Green here means the gate does not measure the fix, and the row reopens
   regardless of how good the code is.
2. **Mutate-and-run.** Break the behaviour the row claims while keeping the diff's
   shape - flip a comparison, zero a constant, drop one branch. **The gate must go
   red for each.** A mutation the gate survives names the hole precisely, and that
   sentence goes in the verdict.
3. **No-op check.** Does the assertion execute at all? An empty match, a skipped
   fixture, a loop over zero items, a regex that matched nothing - all pass
   silently. The auditor asserts on the count, not on the absence of failures.
4. **Behaviour, not source text.** A gate that greps the source it just changed is
   a tautology. It must open the real screen or read the real values.

## Check 2 — evidence audit

- Run the named 再現 command verbatim. If it does not put the auditor in front of
  the thing, the row is not done.
- For a visual row, **look at the artifact** and say in the verdict what is
  visible, in its own words. If the row says "刃の向きが振り下ろし方向と一致" and
  the auditor cannot see that, the disagreement is the finding.
- Check the claimed numbers against the run output, not against the row.

## Check 3 — refactoring plan (files rows, never applies them)

A closing diff leaves debt, and the moment it is cheapest to name is now. The
auditor proposes, and **only** proposes:

- Duplication the diff introduced, and which of the copies should own the rule.
  "One reader per question" is the invariant being protected.
- A seam the diff worked around instead of moving.
- Naming that will read wrong to the next session.
- Missing coverage adjacent to the change - not a wishlist, only what the diff
  made reachable.

Each item comes out as a **queue row with its own gate**, or it is dropped. A
refactor suggestion without a gate is an opinion, and opinions do not enter the
queue. The auditor does not edit code: applying its plan is a later lap that
goes through the same audit.

## Verdict contract

The auditor's whole output. Keep it this shape so a hook or a script can act on
it, and so the queue edit is mechanical:

```
VERDICT: GATE_VALID | GATE_BROKEN | EVIDENCE_MISSING
ROW: <id>
FALSIFICATION:
  revert-and-run: RED | GREEN(<why this is fatal>)
  mutations: <what was mutated> -> RED | GREEN(<the hole>)
  assertion-executed: YES(<count>) | NO
REPRO: OK | FAILED(<what happened>)
EVIDENCE: <what the auditor actually saw, in its own words>
REFACTOR_ROWS:
  - <一文> | Gate: `<command>` — <condition> | 再現: `<command>`
```

- `GATE_VALID` → the implementer archives the row, appending the verdict's
  falsification line as part of the 証跡.
- `GATE_BROKEN` → the row goes back to `[-]` with the counterexample verbatim in
  the state column. **Fix the gate before the code.**
- `EVIDENCE_MISSING` → the row stays `[x]`-proposed and the missing artifact
  becomes the immediate next action.

`REFACTOR_ROWS` are appended to the queue whatever the verdict is - a broken gate
does not invalidate a naming problem.

## Wiring it up

**Claude Code.** Drop [../templates/gate-auditor.md](../templates/gate-auditor.md)
into the repository's `.claude/agents/`, then at lap step 7.5 dispatch it with the
Agent tool, one call per row. It runs in its own context by construction, which is
the property being bought. Several closed rows audit in parallel - send them in
one message.

**Codex.** The same brief as a role under `.codex/agents/`, invoked like the
existing `reviewer` role.

**Making it automatic rather than remembered.** Two options, in increasing order
of force:

- Put step 7.5 in the queue header's READ FIRST block. Cheap, and it survives into
  sessions that never load this skill - but it is a habit, and habits are what the
  audit exists to distrust.
- A `PostToolUse` hook on edits to the queue file that greps for a fresh `[x]` and
  refuses the edit until an audit verdict for that ID exists in the archive. This
  is the mechanical version, and it is how the trouble registry in
  `steering-health-intelligence` is enforced (`scripts/check_repo.py` blocks a
  commit whose retraction is not registered). Use the repo's existing check script
  if it has one rather than adding a second gatekeeper.

**Cost control.** The audit is per row, not per edit, and revert-and-run plus two
or three mutations is the whole budget. Skip the audit only for rows whose gate is
a pure equality on a value the diff does not compute - and say in the row that you
skipped it, so the skip is visible.

## Why this is not just "run the review skill"

A code review reads the diff and asks whether it is good. This audit ignores that
question and asks whether **the row's own gate can tell**. The two find different
things, and only this one can catch the failure that already happened in these
repositories: a green gate that was green before the fix, closing a row on a bug
that shipped.
