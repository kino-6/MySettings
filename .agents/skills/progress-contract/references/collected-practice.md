# Collected practice

Where this skill came from. One report, 2026-10-16, with a transcript excerpt
attached, so every threshold here traces to something observed rather than
guessed.

## The report

> 最近のモデル、結構応答が良くなくて、黙って裏で数分やって回答が来るケースが
> 多々あり、UXが良くないです。(…) 酷い時には、作業１時間続けて、その合間に
> 返すようなことも。

Note what is *not* being complained about: not wrong answers, not too much work,
not slowness. The complaint is **absence** - the agent stops existing for the
duration. That framing is why this skill is about visibility rather than speed.

## The transcript, read for the specific failures

The excerpt was one turn from a Godot game repository. Counted from it:

| Observed | Threshold it produced |
|---|---|
| **4 distinct requests in one message** (a "can this be mechanical?" question, "で、続けて", a Codex-delivery merge, and a design observation about generic characters) - none acknowledged before work began | Restate the bundle before the first tool call; name the order |
| **8 heavy Bash calls in a row, no text between any of them** - git fetch, git archive + art check, reading a design note, a merge plus two in-place doc edits, a Godot API probe, writing a ~100-line GDScript focus walker, running it | No 3+ tool calls without a line; narrate per decision or wait |
| Several calls that obviously exceed 30s: `git archive` of a 25-file art branch, `check_art.py` over 302 assets, a headless Godot run | One line before a >30s step, saying what it should tell us |
| The long test run was correctly sent to the background - **but with no text saying so** | Say when work moves to the background, and what happens meanwhile |
| Findings surfaced mid-work ("パッドで詰まる不具合が 3 つ見つかり、直しました") reported only in the closing summary | Say it at discovery, not in the summary |
| All four requests answered at the end | Report each item as it closes |

## Why it is not a skill alone

Checked at the time of the report: `~/work/layered_dreams` and
`~/work/layered_dreams-claude` had **no `CLAUDE.md`**, and there was **no
`~/.claude/CLAUDE.md`** either. The repository where the problem happened had no
instruction surface at all.

So the first diagnosis - "write a skill" - was wrong twice over. A skill loads
only when its description triggers, and cadence must hold on every turn; and in
that repository there was nothing loaded to constrain anything. The missing piece
was a **surface**, not a rule. Hence the split: this skill holds the judgment, and
`templates/response-cadence.md` is installed into a file that is always read.

## The counter-force

The first draft of the rules said only "talk more", which produces the opposite
failure: a line before every tool call trains the reader to skip all of them. The
table in SKILL.md therefore includes a row whose answer is **say nothing**, and
the unit is a decision or a wait rather than an action. A cadence rule without an
upper bound becomes noise, and noise is indistinguishable from silence in effect.

## Known limit

There is no mechanical version. A hook executes commands; it cannot make a model
speak. Compare the trouble registry in `task-queue-loop`, where writing down is
automated by a pre-commit hook and only the classification is left to judgement -
nothing equivalent exists here. So this stays an instruction, and the honest
recourse is the one the template states: when it is broken, say so, and if it
recurs, record it as a counted type.
