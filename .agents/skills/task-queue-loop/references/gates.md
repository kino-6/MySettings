# Writing a gate that can FAIL

A gate is the sentence that makes a row closable. Everything else in the row is
context; the gate is the contract. A row whose gate cannot be written is not a
task yet.

## The shape

**A gate is a command plus the condition its output has to meet.** Both halves
are required. `./run.sh gate` alone is a command, not a gate - it does not say
what about the run decides the row.

```
Gate: `./Run.sh capture verify_weld verify_weld_01_menu` — 否定の括弧 0 件、
      「タイトルへ戻る」が存在する
```

```
Gate: `gate:ui-nav` — 1280×720 で、コマンドメニューから矢印 4 回以内に
      Equip がフォーカスを得る（focused node id を assert）
```

## Concretize to numbers and key names

"does not overflow" is not a gate. "at 1280x720 every command is on screen;
assert the bottom edge <= 720" is. The test of concreteness: could someone who
disagrees with you run it and be forced to agree?

Replace, every time:

| Vague | Concrete |
|---|---|
| 見た目が自然 | 準備 180ms → 振り抜き 60ms → 制動 115ms を実測で満たす |
| はみ出さない | 1280×720 で下端 ≤ 720 を assert |
| 動く | `--state=weld` で起動し、装甲が最大の 6 割で止まる |
| 性能が改善 | 164 歩を歩かせ、G/歩 が交易 3.5〜4.4 の帯域に入る |

## Concrete does not mean invented

Pressing for concreteness has a failure mode: asked for a number, write one that
nothing supports. A gate built on an invented threshold is worse than a vague one,
because it looks checkable and will be defended.

**Never silently fill in these five.** When the value is not established, say it is
unknown and ask, or mark the row `[~]`:

| | A silent fill looks like |
|---|---|
| **policy** | "cancelling frees the slot immediately" - nobody said it frees it |
| **permissions** | "the operator can approve it" - access was never stated |
| **timing** | "within 200ms" - no requirement said 200 |
| **cardinality** | "one per account" - one was assumed, never confirmed |
| **failure behaviour** | "retries three times" - retrying at all is an invention |

The tell is a sentence that sounds like a natural consequence. A natural-sounding
consequence is still a policy when it changes availability, authorization, state,
or what happens next. If the source does not establish it, the gate cannot assert
it - and "when X becomes available" presupposes that X becomes available, so ask
*whether* before asking *when*.

Numbers that came out of a measurement are concrete. Numbers that came out of the
drafting are decoration. Say which one each is.

(The five-way split is borrowed from [Alder](https://github.com/mk3008/alder),
whose business-design skill refuses to fill in "policy, permissions, timing,
cardinality, or failure behavior". The rest of that kit was not adopted.)

## Three commands per row, three runs

Every row names three commands. Two are checks with the same contract - a
command, a condition, the ability to go red - and differ only in when they run.
The third is not a check.

| | 最小検証 | Gate | 再現 |
|---|---|---|---|
| Asks | did this row's change work? | is the row complete? | what does it look like? |
| Answers with | pass / fail | pass / fail | the thing itself |
| Scope | one file, behaviour, seed, screen | the row's own proving command | one state |

**The repro proves nothing.** It has no pass condition; it puts a person in front
of the result in one command (a fixture, a boot flag, a `--state=`). "Walk there
in game" or a `.png` path does not count.

**The row's Gate is the row's own proving command, not the whole suite.** Writing
the full-gate command in a row's Gate column is the single habit that turns every
lap into a full-suite run.

### Three runs

| Run | When | Budget |
|---|---|---|
| **最小検証** | every iteration | seconds |
| **行の Gate + 未検査ぶん** | before closing the row | **~2 min, 1 for some people** |
| **フル** | **before push only** | as long as it takes |

The middle figure is the one that matters, because it is paid every lap. It is a
threshold of human attention, not a technical limit: past a couple of minutes the
person stops waiting and the loop stops being a loop. Put the project's own
measured number in its rules file. The full run is exempt by design - once per
push barely costs per lap. A commit is cheap and local; a push is what other
people and machines see, so the complete run goes right before the work leaves
the machine.

For scale: a narrowed run in `rustbound` returned 3 tests / 37 checks in 1s,
against a full gate of 914 tests.

### The minimum check

- **Write it with the gate, before the work.** Chosen afterwards, the iteration
  already ran on the expensive one.
- **It must be able to go red for this row,** or it is the gate with the
  assertions thinned out - worse than nothing, because it feels verified.
- **Falsify on the cheap one first.**
- **Minimum green + gate red is information:** the narrowing was too tight. Widen
  it in the same edit that fixes the code.

Narrowing handles usually exist already: `--only=<file>`, `--lane=`, one seed
instead of five, one fixture, one `--state=`, one captured screen.

### Skipping what is already verified

A gate whose area the change could not have touched, with a green run on exactly
this content, need not re-run. **The skip must be derived, not asserted** - "I
didn't touch that" is the belief that lets regressions through.

| Source, strongest first | Existing tools |
|---|---|
| Content identity: inputs byte-identical to the last green run | Bazel, Pants, Buck, Gradle build and test caching |
| A tool that computes impact | `pytest-testmon`, Jest `--changedSince`, Vitest `--changed`, Nx `affected` |
| A declared ownership map in the rules file | lanes such as `--lane=rules\|content\|ui` |

Godot projects rarely have either of the first two; declared lanes are the
realistic option there. With none of the three, there is no skip - run the suite
and file a row to build one.

**Record the skip in the row.** It is a claim, and the pre-push full run is what
falsifies it. **Never skip into a push**: that run is what makes every earlier
skip affordable.

### What still earns deletion

Cost is not a reason; being wrong is - a gate pinned to a closed row's incidental
numbers, a gate on unreachable behaviour, a duplicate whose failure does not
locate the fault. **Promote to a cheaper fixture before deleting**: the same
assertion made cheap beats one fewer assertion. Archive a deletion with what it
used to catch, or the next session re-adds it.

The gates are the accumulated record of what the project learned, and they are
what lets an agent make broad changes safely. A gate that never goes red is the
guard doing its job. **Shrink the run, not the suite.**

### Why full gets reached for anyway

An incentive, not ignorance: running everything is defensible without judgement,
while a selected run carries the risk of having chosen wrong. "Don't" does not
change that arithmetic. Making the selection **citable** does - the minimum check
sealed in `Tasks.lock.json` before the work, the skip derived from a source above,
the full run guaranteed before push. Absent that record, full is correct and the
defect is in the row.

**Minutes per lap** is the measurement behind "development isn't progressing".
It splits into gate run, re-render, a wrong skip that cost a full run anyway, and
waiting on a human. Measure a few laps before optimising.

## Falsification: confirm the red first

**Run the gate before the fix and watch it fail.** A gate that is green before
the work proves nothing about the work, and this failure mode is quiet - the run
is green, the row gets closed, the bug ships.

Two real shapes of this failure:

- The assertion never executes (an empty match, a skipped fixture, a loop over
  zero items). Guard against it by asserting on the rule directly rather than on
  an outcome that a no-op also satisfies - check that the payment rule ran, not
  that the fight was won.
- The gate pins source text rather than behaviour. Rewrite it to open the real
  screen and read the real values.

If you cannot make the gate red, the gate is measuring the wrong thing.

## When no machine gate can be written

Only then, and say so in the row: spell out the explicit manual or visual check -
the exact command that produces the artifact, the resolution, what you will look
for, and what would count as a failure. Then **you** run it and read the image.
This is still your verification, not the user's.

```
Gate: 機械判定なし。`./run.sh agent axe-render` で 1920×1080 PNG を出し、
      刃の向きが振り下ろし方向と一致していること・手元と斧頭が離れていない
      ことを目視。どちらか崩れていれば失敗
```

## Image and real-screen gates

A headless `pass` is not a visual pass. For anything player-facing or
user-facing, the gate has to include rendering the real thing at a stated
resolution and reading it. Name the artifact path in the row so the next lap can
re-render the same view.

## Self-verification belongs to the implementer

The gate exists so that you can close the row without asking. Do not put "the
user checks it" in the gate; the user gets the questions that need taste or a
product decision, and nothing else. If you are tempted to hand over a
verification chore, the gate is not finished yet.

## Pre-registration, for measurements

When the row's outcome is a number rather than a behaviour, write the expected
result and the pass condition **before** running, and commit that. Then run.
Do not flip the threshold after seeing the output, and keep the missed
predictions on record - a prediction you can compute should be computed, not
registered as a guess.

## Parallelising, only after narrowing

Parallelism is the weaker lever. Eight cores running the full gate still run the
full gate, and a one-second check needs no cores. Reach for it only when the run
is already as narrow as it can be and still slow.

**Pays:** a long gate in a duplicated tree under a short check in the working
tree (what a shadow tree is for - see [runtime-contract.md](runtime-contract.md));
sweeps over seeds or parameters; several closed rows auditing at once; raising
the worker count on a runner that already isolates per file.

**Does not:** two runs in one tree on one lock (they contend on the engine's
cache or the build dir and hang - give each its own tree, lock and user-data
dir); order- or state-dependent bugs, which stop reproducing and get read as
fixed; anything a person has to read, since four screenshots in parallel are
still four looks; harnesses that interleave output until you cannot tell which
worker went red.

Say it in the row when a lane is parallel-safe so the next lap need not
rediscover it: `最小検証: ... （seed 5 本は並列可 / 同一木では不可）`.
