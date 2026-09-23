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

## The minimum check, and the gate

Every row carries **two** commands with the same contract, differing only in how
often they run:

| | 最小検証 (minimum check) | Gate |
|---|---|---|
| Question | did this row's change work? | is the row complete? |
| Scope | one file, one behaviour, one seed, one screen | the whole suite, the bands, the real pixels |
| Cadence | every iteration | once, before the commit |
| Budget | seconds | whatever it costs |

This is the single biggest lever on how long a lap takes. A full gate run in a
mature project is minutes; the narrowest slice of it is usually about a second.
Measured in this repo's own audit run: `./Run.sh test --only=test_two_ways_to_earn`
returned **3 tests / 37 checks in 1s**, against a full gate of **914 tests**.
Reaching for the full gate on every edit is what makes queue work feel slow.

**Narrowing has ready-made handles in most projects** - use them before inventing
anything: `--only=<file>`, `--lane=<rules|content|ui>`, a single seed instead of
five, one fixture, one `--state=`, one captured screen.

Four rules:

- **Write it at the same time as the gate,** in the same edit, before the work.
  Deciding the cheap check afterwards means the whole iteration ran on the
  expensive one.
- **It must be able to go red for this row.** A minimum check that cannot fail is
  the gate with the assertions thinned out, which is worse than nothing: it makes
  the iteration feel verified.
- **Falsify on the cheap one.** Watch the minimum check fail before you start;
  save the gate's red for the cases the cheap one cannot express.
- **Minimum green + gate red is information, not an annoyance.** The narrowing was
  too tight. Widen the minimum check in the same edit that fixes the code, so the
  next lap on this row does not pay the same price.

Both go in the row, both with a condition:

```
最小検証: `./Run.sh test --only=test_trade_routes` — 経路が 1 本以上、parts を含まない（~1s）
Gate:     `./Run.sh gate` — 914 tests 緑・165 帯域緑・GATE_EXIT=0
```

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

## One command to reproduce

Every row names a single command that puts a reader in front of the thing:
a fixture name, a boot flag, a `--state=` scenario, a script invocation. This is
separate from the gate and equally required - the gate proves it works, the repro
lets someone see it.

```
Repro: `./Run.sh play --state=hunt`
Repro: fixture `equip_screen_min` / boot flag `--scene=equip`
```

## Pre-registration, for measurements

When the row's outcome is a number rather than a behaviour, write the expected
result and the pass condition **before** running, and commit that. Then run.
Do not flip the threshold after seeing the output, and keep the missed
predictions on record - a prediction you can compute should be computed, not
registered as a guess.

## Parallelising, only after narrowing

Parallelism is the second lever and it is strictly the weaker one. **Narrow
first.** Running the full gate on eight cores is still the full gate; a one-second
check does not need cores. Reach for parallelism only when the thing is already as
narrow as it can be and is *still* slow.

**When it pays**

- **A long gate under a short check.** Run the gate in a duplicated tree in the
  background while you keep iterating on the minimum check in the working tree.
  This is what a shadow tree is for - see
  [runtime-contract.md](runtime-contract.md).
- **A sweep.** Parameter scans, seed sets, per-map measurements: independent by
  construction, so split them across workers or trees.
- **Independent rows.** Several closed rows waiting on their step 8 audit can be
  dispatched at once - one message, several agents.
- **A test suite that isolates per file.** If the runner already forks a process
  per file, raising the worker count is free; check before building anything.

**When it does not**

- **Same tree, same lock.** Two runs in one working directory contend on the
  engine's import cache, the build directory, or the run lock, and the usual
  result is a hang or a corrupted cache rather than a speedup. Give each run its
  own tree, its own lock, and its own user-data dir, or run them in sequence.
- **Order- or state-dependent bugs.** The failure you are chasing may stop
  reproducing under concurrency, and you will read that as fixed.
- **Anything you have to read.** Four screenshots produced in parallel still take
  one person one look each, and a parallel run whose output you skim is a green
  gate.
- **When it hides which one failed.** If the harness interleaves output so you
  cannot tell which worker went red, the time saved is spent twice over finding
  out.

Say it in the row when a lane is parallel-safe, so the next lap does not have to
rediscover it: `最小検証: ... （seed 5 本は並列可 / 同一木では不可）`.
