# Collected practice

Where each rule in this skill came from. Distilled 2026-09-21 by reading the
task queues actually in use across the local projects, so a rule can be traced
back to the repository that paid for it.

## Sources read

| Repository | File | Lines | What it contributed |
|---|---|---|---|
| `steering-health-intelligence` | `Tasks.md` + `CHARTER.md` + `TROUBLES.md` | 178 / 63 / 1371 | Lap entry reads queue **and** charter. Detours declared as `脇道`. Mainlines (`本線 C/D/E`) with date ranges as the reporting unit. Pre-registration before measurement. A trouble registry of recurring *types*, enforced mechanically. |
| `rustbound` | `Tasks.md` + `docs/work-rules.md` | 38 / — | Columns are 何を・なぜ・Gate・状態. Gate = the command that proves completion. Keep exactly one `[x]` as a boundary marker. A human play-through is not a completion condition. Declare the next ID (`T610 以降`). Staged verification (one file → lane → full gate only at slice close). Placement map as a table in the header. |
| `black-stela` | `Tasks.md` | 91 | Process top down. `判断待ち` rows state what the user has to decide and why the agent did not decide it. Closed items keep a one-line record with date and gate name. |
| `cdda-musou` | `TASKS.md` | 197 | 200-line cap. A row without 実装 and Gate "is not yet a task". Symptom first, not the fix. Archive file for `[x]`. Separate homes for number-found vs play-found findings. |
| `ecliptica` | `Tasks.md` | 44 | Do not add a dated "Current Truth" or a second board for the same problem. One row per ID, updated in place. Implemented-but-uncommitted gets its own column, not a trip back to in-progress. Headless pass is not a visual pass. Do not batch unrelated diffs for the sake of a commit. |
| `virtual-ecu-peripheral-harness` | `Tasks.md` | 179 | 200-line cap with an explicit archive link list. A `Current Goal` section above the phases. |
| `watchless-notes` | `Tasks.md` | 91 | `[!]` blocked by external user/system action. Acceptance criteria as nested checkboxes under the task. |
| `AutoRogue` | `Tasks.md` | 420 | Playable-demo command block at the top (the repro, hoisted to file level). Also the counter-example: at 420 lines it carries provisional conclusions and design discussion, which is what the cap exists to prevent. |
| `codex-game-test` | `Tasks.md` | 488 | Definition-of-quality section as its own checklist with an explicit NG list. Also over the cap. |
| `.agents/skills/build-playable-games/references/task-queue.md` | — | — | The prior game-project cut of these conventions: self-contained task blocks, the four-part definition of done, same-edit grooming, lane split between agents. |
| `steering-health-intelligence/.claude/skills/loop/SKILL.md` | — | — | The reporting unit is the question, not the agent's work unit. Do not report per completed step. When forced to report mid-loop, state `残り N 件` and what remains. |

## Sources read for the two sub-skills (2026-09-21)

| Repository | File | Lines | What it contributed |
|---|---|---|---|
| `cdda-musou` | `run.sh` | 551 | Version = short SHA + dirty marker, written to a per-port file so a parallel session can see what is being served and leave it alone. |
| `cdda-musou` | `docs/LEARNED.md` | 1167 | 33 entries of "what building it taught me", more about wrong designs and wrong measurements than successes. #25 is the version/seed-in-frame lesson: title bar and log carry neither into a screenshot. |
| `cdda-musou` | `.claude/skills/gate/SKILL.md` | — | The registry generalised into a pre-flight skill: "同じ失敗を4回以上繰り返したので、着手前に必ず通す". Checks phrased as answerable questions, not warnings. |
| `black-stela` | `run.sh` | 404 | One entry point is the only thing to memorise; bare invocation prints a menu. Fixture/gate/route lists derived from source each run so the help cannot go stale. |
| `ecliptica` | `run.sh` | 309 | Agent lanes headless only, with the macOS focus measurement recorded next to the rule. Window-creating lanes (`record-walk`, `window-evidence`) gated behind an env flag and "only when the human asks". |
| `rustbound` | `Run.sh`, `tools/shadow.sh`, `tools/capture_web.py`, `tools/check_background_launch.sh` | 264 + — | Exclusive lock that waits rather than kills, run-scope separation from the player's save, shadow tree for verification during play (T566: never suggest stopping the lock owner), headless 1920x1080 capture, and the window-focus rule enforced as an executable check. |
| `rustbound` | `docs/trouble-log.md` | 385 | The generalisation move, visible: nine play-session complaints were six types, each with 症状 / 原因 / 修正 / 再発防止. |
| `steering-health-intelligence` | `TROUBLES.md`, `.claude/skills/troubles/SKILL.md`, `scripts/sync_troubles.py`, `scripts/check_repo.py` | 1371 + — | 46 counted types sorted by recurrence (top = 11). Appending automated from a pre-commit hook into an unclassified section; `troubles classified` blocks the commit until the entry is filed under a type; `troubles registered` blocks a retraction missing from the registry; a SessionStart digest puts the types in context without anyone remembering. Five types delegated to machine checks, the rest kept as judgement questions. Limits stated in the skill itself: only noticed failures are in it, and T1 recurred after its corrective procedure was written. |

## The 最小検証 column (added 2026-09-23)

Asked for after the loop proved slow in practice: every lap was reaching for the
full gate. The staging already existed in `rustbound/docs/work-rules.md` as
"検証の段階化" - one file during iteration, a lane per feature, the full suite once
at integration, the full gate only at slice close and before reporting - but it
lived in the rules file, not in the row, so it was a habit rather than something
the queue made you write down. Promoting it to a column alongside `Gate` is what
makes the cadence per-row and visible.

The cost ratio is measured, from this repo's own audit run on `rustbound` T609:
`./Run.sh test --only=test_two_ways_to_earn` returns **3 tests / 37 checks in 1s**
against a full gate of **914 tests**. Narrowing handles (`--only=`, `--lane=`, one
seed, one fixture, one `--state=`) already exist in every launcher surveyed here,
which is why narrowing is the first lever and parallelism the second.

Parallelisation guidance was folded into the same section rather than made its own
document: the only forms worth reaching for are a long gate running in a shadow
tree under a short check, a sweep, and independent rows auditing at once - and the
counter-cases (same tree same lock, order-dependent bugs, output a human has to
read) all come from the runtime contract that was already collected.

The audit gained a matching check, so a minimum check that cannot see its own
change gets caught rather than silently making every future lap on that row
expensive.

## Variations deliberately left open

- **Marker set.** `[ ] [-] [x]` everywhere; `[~]` (human judgement) in
  `steering-health-intelligence` and `rustbound`; `[!]` (external block) only in
  `watchless-notes`. The skill takes the three as the minimum and treats the
  other two as opt-in.
- **Row shape.** `rustbound` and `black-stela` use markdown tables; `cdda-musou`
  and `steering-health-intelligence` use nested bullets. Tables survive a
  `なぜ` column of several sentences badly, bullets survive many columns badly.
  Left to the repo; the template shows both.
- **Filename.** `Tasks.md` in nine repos, `TASKS.md` in `cdda-musou`. Not worth
  normalising - match whatever the repo already has.
- **Archive location.** `docs/archive/*.md`, `docs/changelog-YYYY-MM.md`,
  `TasksArchive.md`, `docs/TASKS-ARCHIVE.md`. Do not create a parallel archive
  when one exists.

## Observed failure modes these rules answer

- A queue that grew into a history dump stops being read, and its stale rows get
  re-implemented or silently skipped (`AutoRogue` 420 lines,
  `codex-game-test` 488).
- "Tasks.md が Task でないものの記述が多い" (`rustbound`, user 2026-08-16) - the
  reason the rules and the queue are separate files.
- A gate that was green before the fix, or that asserted on a no-op-satisfiable
  outcome, closed a row that was not done (`rustbound` T604/T605).
- The same question answered from three places drifted silently, and a shop shelf
  stayed permanently closed in one world (`black-stela`, 2026-09-17).
- Verification handed to the user: "確認を振りすぎ" (`rustbound`, 2026-08-12).
- The implementer self-approving their own gate. The prior game-project cut
  already forbade self-approving visual work and split lanes between agents for
  exactly this reason, but left the gate itself to the implementer. The audit loop
  in [gate-audit-loop.md](gate-audit-loop.md) is the generalisation: a fresh
  context that is never told why the fix is correct, attacking the gate rather
  than the diff. Its enforcement shape is borrowed from
  `steering-health-intelligence`, where the trouble registry is not a habit but a
  commit blocked by `scripts/check_repo.py`.

## First run of the audit loop (2026-09-21)

Run against `rustbound` T609 ("二つの稼ぎ方は競合していない") at `05367a2`, in a
throwaway `git worktree` so the working tree was never touched.

- Baseline `./Run.sh test --only=test_two_ways_to_earn`: green, 3 tests / 37 checks.
- **revert-and-run: N/A.** The commit changes only `tests/` and `tools/` - no
  production code - so reverting deletes the gate instead of the fix. This case
  was missing from the skill and is now written into
  [gate-audit-loop.md](gate-audit-loop.md).
- **mutations: 3/3 RED.** Adding `"parts": 1` to `trade_routes()` (30 failures),
  raising `cu_scrambler` to `encounter_mult 3.0 / elite_mult 5.0` so avoiding
  out-earns luring (2 failures), and multiplying the trade payout by 10 (ratio
  10.5, 1 failure). The gate survived none of them.
- **assertion-executed: YES.** The test guards its own preconditions with
  `t.gt(routes.size(), 0)` before looping, which is the check this skill asks for.
- **repro: OK.** `./Run.sh script res://tools/report_income.gd` reproduced every
  number quoted in the row (交易 3.5〜4.4G/歩, 荒野+誘引 4.5 → 3.7G/歩, 部品 0.024).
- **Finding filed.** `tools/report_income.gd` measures the market-to-market
  distance at run time (`_walk_between_markets()`), while the gate hard-codes
  `var legs := 164.0`. The tool re-measures when the map moves and the gate does
  not, so the ratio band silently goes stale. The test's own comment already
  refuses to copy the gold amounts for this exact reason - the step count slipped
  through. This is now an explicit refactor check in the audit.

Verdict: `GATE_VALID`. Cost: four gate runs at roughly one second each.
