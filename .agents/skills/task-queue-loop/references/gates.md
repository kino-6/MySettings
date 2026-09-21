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
