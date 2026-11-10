# Tasks 完了記録

> [Tasks.md](Tasks.md) から移した完了行。**1 タスク 1 レコード**、新しいものを上に。
> 後から「何をもって完了としたか」を辿れる形に保つ。Gate の原文は `Tasks.lock.json` にある。
> T001〜T009 の Gate と再現は、T010 で移した今の置き場所（`.agents/skills/morning-board/scripts/`）で書き直してある。封印した原文は旧パス `scripts/morning-board/`。

## 2026-11

### T016 — 写しの検査の試験を check.sh で毎回走らせ、下位だけのずれも赤にする

- 完了: 2026-11-10
- Gate: `bash scripts/test-skill-mirrors.sh && grep -Eq "^step skill-mirrors-test block bash scripts/test-skill-mirrors.sh" scripts/check.sh` — 試験が通り、check.sh が止める段として毎回走らせる。`diff -rq` を `diff -q` にすると赤
- 監査: 省略。試験だけの行で、`diff -rq` を `diff -q` に退行させると試験が赤になることを実装者が確かめた。監査が起票した行をまた監査する連鎖に止めどころが無いと分かり、T017 で決まりにした
- 再現: `bash scripts/test-skill-mirrors.sh`
- commit: `cc2cf11`

### T015 — skill の写しをそろえる処理と、その Gate の穴をふさぐ

- 完了: 2026-11-10
- Gate: `grep -Eq "^step skill-mirrors block bash scripts/skill-mirrors.sh --check" scripts/check.sh && ! SKILL_MIRROR_ROOTS=/nonexistent bash scripts/skill-mirrors.sh --check && t=$(mktemp -d) && cp -R .agents/skills/morning-board "$t"/ && echo x >>"$t"/morning-board/scripts/board.py && mkdir "$t"/morning-board/d && echo q >"$t"/morning-board/d/f && ! SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --check && SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --write && SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --check && ls "$t".bak/*/morning-board/scripts/board.py "$t".bak/*/morning-board/d/f` — check.sh が止める段として呼び、明示した root で 0 件なら赤、下位のずれを見つけ、--write が mirror の外に控えを残して 1 回で収まる
- 監査: `GATE_VALID`（2026-11-10）。修正を戻す・0 件の誤りを外す・cp で下位を落とす・check.sh の行をコメントや warn にする・控えを root の中に置く、のどれでも赤。`diff -rq` を `diff -q` にしても緑の穴は T016 に起票。同じ秒の 2 回目の --write で控えが入れ子になる、symlink の mirror が実体の写しになる、複数 root の 1 つの打ち間違いが通る、の 3 件は起きにくく元に戻せるので行にしない
- 再現: 最小検証と同じ（`Tasks.lock.json` の T015）
- 何が本当の原因だったか: rsync の `--backup` は控えを mirror の中に置くため、mirror にだけあるディレクトリを消せなかった。古い写しを root の外へ丸ごと移す形に変えた
- commit: `6e1c4f6`

### T014 — 完了した行を履歴ファイルに残し、憲章を本線 A・B に合わせる

- 完了: 2026-11-10
- Gate: `! grep -q "^>.*履歴ファイルを持たない" Tasks.md && grep -q "本線 B" CHARTER.md && test "$(python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T00:00 | grep -A4 "^## MySettings" | grep "終わった" | grep -o "T0[0-9][0-9]" | sort -u | wc -l)" -ge 13` — 見出しと憲章が今の運用に合い、朝の 1 枚が MySettings の T001〜T013 を「終わった」に出す
- 監査: `GATE_VALID`（2026-11-10）。元に戻すと 3 条件とも赤、archive を消すと赤。記録 14 件の Gate と commit を lock と git で照合済み。件数の条件 `-ge 13` は後の行も数えるのでゆるいが、行は閉じているので直さない
- 再現: `python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T00:00 | grep -A4 '^## MySettings'`
- 何が本当の原因だったか: 封印した Gate の最初の条件が Tasks.md 全体を探していて、行に書いた Gate の文自体に一致した。理由付きで、探す範囲を見出しの行に絞った
- commit: `cf4f5f0`

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
