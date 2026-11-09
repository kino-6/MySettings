# Tasks 完了記録

> [Tasks.md](Tasks.md) から移した完了行。**1 タスク 1 レコード**、新しいものを上に。
> 後から「何をもって完了としたか」を辿れる形に保つ。Gate の原文は `Tasks.lock.json` にある。
> T001〜T009 の Gate と再現は、T010 で移した今の置き場所（`.agents/skills/morning-board/scripts/`）で書き直してある。封印した原文は旧パス `scripts/morning-board/`。

## 2026-11

### T013 — Codex 設定を現行仕様へ合わせ、Stop hook と厳格検査を実証して導入する

- 完了: 2026-11-08
- Gate: `bash scripts/check-codex-config.sh && python3 .agents/skills/progress-contract/scripts/test_report_check.py && bash scripts/skill-mirrors.sh --check` — 追跡中の Codex 設定と profile が厳格検査を通り、hook の両 runtime 出力と skill の写しが一致する
- 監査: `GATE_BROKEN` 2 回の後に `GATE_VALID`。最小検証を広げ、登録 command を隔離 HOME で実行する確かめを足した
- 再現: `REPORT_CHECKS=lang REPORT_HOOK_RUNTIME=codex python3 .agents/skills/progress-contract/scripts/report_check.py`（英語の最終返答を JSON で渡すと `decision: "block"`。逐語は `.agents/ecc-workflow/tasks/2026-11-08-codex-upstream/check.md`）
- 何が本当の原因だったか: `persistent_instructions` と旧 profile 形式が現行 CLI で効いていなかった
- commit: `6e685d9`

## 2026-10

### T012 — skill の写しのずれを push 前に見つける

- 完了: 2026-10-31
- Gate: `bash scripts/skill-mirrors.sh --check && grep -q "skill-mirrors.sh --check" scripts/check.sh && t=$(mktemp -d) && cp -R .agents/skills/morning-board "$t"/ && echo x >>"$t"/morning-board/SKILL.md && ! SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --check` — 写しがそろい、check.sh が呼び、1 行足した写しで赤になる
- 監査: `GATE_VALID`（2026-11-10）。ただし gate は下位ディレクトリのずれと `--write` を確かめず、check.sh の行がコメントでも通る。mirror にだけあるディレクトリを `--write` すると収まらない不具合あり。T015 に起票
- 再現: `bash scripts/skill-mirrors.sh --check`
- 何が本当の原因だったか: 写しのずれを調べる検査が無かった。api-design・external-ai-tools・security-review は既に `~/.codex/skills` 側が古かった
- commit: `b0f05d9`

### T011 — skill を他の repo の session から使えるようにする

- 完了: 2026-10-31
- Gate: `diff -r -x __pycache__ .agents/skills/morning-board ~/.claude/skills/morning-board && diff -r -x __pycache__ .agents/skills/morning-board ~/.codex/skills/morning-board && grep -q "SKILL.md のある" .agents/skills/morning-board/SKILL.md && bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check` — 両方の写しが repo と一致し、パスの基準と抜けが書かれ、inventory がずれていない
- 監査: 未実施
- 再現: `ls ~/.claude/skills/morning-board ~/.codex/skills/morning-board`
- 何が本当の原因だったか: 写しが無く、他の repo からは skill として見つからなかった。境界の後に足されて消えた行が「終わった」に出ない抜けも、ここで Limits に書いた
- commit: `e0202f3`

### T010 — 朝の 1 枚を skill `morning-board` にまとめる

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py && ! test -e scripts/morning-board && bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check` — 試験が通り、旧置き場が無く、inventory がずれていない
- 監査: `GATE_VALID` — 3 つの条件をそれぞれ壊して赤。所見 3 件は T011 に起票
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --root .agents/skills/morning-board/scripts/fixtures --since 2000-01-01 --agents-json .agents/skills/morning-board/scripts/fixtures/agents.json`
- commit: `5080040`

### T009 — `claude agents` が `null` や数だけを返しても、表は出る

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py` — 全試験が通る
- 監査: `GATE_VALID`（同上）
- 再現: `python3 .agents/skills/morning-board/scripts/test_board.py LiveAgents -v`
- commit: `673514e`

### T008 — 題の崩れを、題を整える関数とは別の物差しで見る

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py` — 全試験が通る
- 監査: `GATE_VALID`（同上）
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T00:00 --check`
- commit: `48b32f2`

### T007 — 境界の前から `[x]` の行は、後で文面が直っても「終わった」に出ない

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py` — 全試験が通る
- 監査: `GATE_VALID`（同上）
- 再現: `python3 .agents/skills/morning-board/scripts/test_board.py Since -v`
- commit: `fe24adb`

### T006 — 表の形でも `[!]` の行が消えたら試験が赤になる

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py` — 全試験が通る
- 監査: `GATE_VALID`（T006〜T009 をまとめて 1 回）
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --root .agents/skills/morning-board/scripts/fixtures`
- commit: `eb4040f`

### T005 — 全体の検査に試験を入れ、README に使い方を書く

- 完了: 2026-10-31
- Gate: `bash scripts/check.sh --offline` — `morning-board` の段が ok
- 監査: `GATE_VALID`。check.sh の段を note に変えても気づけない穴は、差分に出る意図的な変更なので行にしない
- 再現: `python3 .agents/skills/morning-board/scripts/board.py`
- commit: `e0640e1`

### T004 — 実際の `~/work` で回し、出力を読んで直す

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T00:00 --check` — 表に出す行（`[~]` `[!]` `[-]`）で、ID を読めない行と、題が ID・優先度・担当の印で始まる行が 0。加えて `test_board.py` の Shapes と Archive が通る
- 監査: `GATE_VALID`。残る穴は T008
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T00:00`
- 何が本当の原因だったか: 実データには ID の無い行が 229 行あり（完了 192・未着手 37）、封印した Gate は満たせなかった。理由付きで Gate を修正した（修正理由の「234 行」は数え違い）。ID の無い `[x]` は「終わった」に出ない
- commit: `8a000ad`

### T003 — いま動いている Claude Code の session を repo ごとに出す

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py` — 全試験が通る
- 監査: 1 回目は差し戻し（再現が単独で session を出さず、`claude agents` の想定外の答えで表全体が止まった）。再監査で `GATE_VALID`。残る穴は T009
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --root .agents/skills/morning-board/scripts/fixtures --agents-json .agents/skills/morning-board/scripts/fixtures/agents.json`
- 何が本当の原因だったか: 外から来る JSON は、一覧でない・cwd が文字列でない場合がある。相対の `--root` と、親 repo の commit を拾う誤りも再現の出力を読んで見つかった
- commit: `a8e0eaf`

### T002 — 指定時刻以降の commit と、`[x]` になった行を repo ごとに出す

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py` — 全試験が通る
- 監査: `GATE_VALID` — 変異 8 件中 6 件で赤。残る 2 件は T007 に起票
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T18:00`
- commit: `87cb0db`

### T001 — Tasks.md の `[~]` `[!]` `[-]` の行を、repo ごとに ID と題で出す

- 完了: 2026-10-31
- Gate: `python3 .agents/skills/morning-board/scripts/test_board.py` — 全試験が通る
- 監査: `GATE_VALID`
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --root .agents/skills/morning-board/scripts/fixtures`
- commit: `6db7c75`
