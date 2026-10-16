---
name: progress-contract
description: What an agent owes the person waiting while it works and when it reports - narration thresholds, handling a message that carries several requests, and a report that is short, answers first, lists no passed checks, and is written in plain phrasing. Use when an agent goes quiet for minutes during long work, when a multi-request message gets a single late answer, or when installing cadence rules into a project or user-level instruction file. Template in templates/.
---

# Progress Contract

An agent that works for ten minutes and then answers is not slow - it is
**absent**. The work was fine; the person watching had no way to tell whether
anything was happening, which of their requests was in flight, or whether to
wait or interrupt.

This is the mirror of an observability contract. That one is about the agent
being able to see its own output; this one is about the **person being able to
see the agent**.

## What is owed

While a turn is running, the person waiting is owed four things, cheaply:

1. **What is happening now** - one line, in their terms, not a tool name.
2. **Roughly how long** - said *before* the wait, not after it.
3. **Which of their asks is in flight** - when they sent several.
4. **Results as they land** - per item, not assembled into one closing essay.

Nothing here asks for less work or smaller steps. It asks that the work be
visible while it happens.

## Thresholds, not "talk more"

Over-narration is the other failure, and it is the one that makes people stop
reading. A line before every tool call trains the reader to skip all of them, so
the line that mattered gets skipped too. Narrate per **decision or wait**, not
per action.

| Situation | Owed |
|---|---|
| A step expected to exceed ~30s | One line first: what is being run, and what it should tell us |
| 3+ tool calls in a row | At least one line of text; 1-2 silent is fine |
| A step turns out longer than expected | Say so **at discovery**, not in the summary |
| Work moved to the background | Say that, and what happens while it runs |
| Below those | Say nothing; silence is correct |

"What it should tell us" is the part that carries weight. *Running the gate* is a
tool name. *Running the gate to see whether the pad can still reach Equip* is a
reason, and it lets the person judge whether you are on their question at all.

## A message with several requests

People bundle. One message routinely carries a correction, a new ask, and an
observation. The failure mode is answering all of it at the end, so for the whole
turn the person cannot tell which part is being worked on - that makes the
silence twice as bad.

- **Restate before acting.** One line each, numbered, and say which is first.
  Before the first tool call.
- **Report each item as it closes.** Do not assemble one closing essay.
- **When interrupting or reordering, state the remaining count** and what is in
  it.
- **If something will not be done, say so and why.** Never drop a request
  silently; a bundled ask is the easiest place for one to vanish.

## The report itself

The message that ends the work is the one the person has to read, and
AI-written ones are reliably too long and over-decorated: answer first, no list
of passed checks, around ten lines, plain phrasing without "——" insertions or
aphorisms, plumbing last.
[references/report.md](references/report.md) has the rules, where they came
from, measurements, and an optional Stop hook
([scripts/report_check.py](scripts/report_check.py)) that sends an egregious
report back once.

## Leftovers get verdicts, or no section

The same discipline at the end of a turn. Listing "outstanding items" with no
verdict hands the triage back to the person who asked you to do the work. Attach
a one-line verdict to every item - including "no action, because X" - or do not
write the section.

Related: the mechanical consequence of a change you just made is yours to
finish, not theirs to decide.

## What can be mechanized, and what cannot

Be honest about this when installing the rules:

- **Real harness features**: moving long work to the background, task
  notifications on completion, interrupting a running turn. Use them.
- **Not available**: making a model speak. A hook runs commands; it cannot
  produce narration. There is no commit-blocking version of this.

So this is an instruction-shaped problem, and instructions only fire where they
are **always loaded**. A skill is the wrong sole vehicle: it loads when its
description triggers, and cadence has to hold on every turn, including turns that
trigger nothing. **The skill carries the judgment; the template carries the
rules into a file that is always read.**

## Installing it

[templates/response-cadence.md](templates/response-cadence.md) is the installable
text. Place it where it is loaded every turn, in the project's working language:

- **All projects** - the user-level instruction file (`~/.claude/CLAUDE.md`, or
  the equivalent for the host). Choose this when the complaint is about
  behaviour everywhere, which it usually is.
- **One project** - that repository's `CLAUDE.md` / `AGENTS.md`.

Check first whether the affected project has an instruction file at all. The
report that produced this skill came from a repository with **no `CLAUDE.md` and
no user-level file**, so nothing was constraining anything - the fix was a
missing surface, not a missing rule.

Keep the installed copy short. It is paid for on every turn.

## Related

- [references/collected-practice.md](references/collected-practice.md) - the
  report this came from and the transcript it was read out of.
- `observable-development-loop` - the agent seeing its own output; this skill is
  the person seeing the agent.
- `task-queue-loop` - the same split, where the skill holds the discipline and a
  template carries the operable rules into each repository.
