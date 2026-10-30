# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは消す（この branch の試行では履歴ファイルを持たない。記録は commit）。

次に起票する ID は **T010 以降**。

## 本線 A — 朝の 1 枚（2026-10-31〜）

- [x] **T002 — 指定時刻以降の commit と、`[x]` になった行を repo ごとに出す**
  - なぜ: 「何が終わったか」は今の Tasks.md だけでは分からない（`[x]` は移されて消える）。差分で取る
  - 最小検証: `python3 scripts/morning-board/test_board.py Since` — 一時 repo で、境界より前の commit と `[x]` を出さず、後のものだけ出す
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/board.py --since 2026-10-30T18:00`
  - 監査: GATE_VALID（変異 8 件中 6 件で赤。残る 2 件は T007）
- [x] **T003 — いま動いている Claude Code の session を repo ごとに出す**
  - なぜ: Agent View（`claude agents`）は組み込みで入れる物がない。`--json` の cwd で repo に結び付ける
  - 最小検証: `python3 scripts/morning-board/test_board.py Agents` — 試験用の JSON で、cwd が repo の下にある session だけがその repo に付く
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/board.py --root scripts/morning-board/fixtures --agents-json scripts/morning-board/fixtures/agents.json`
  - 監査: 差し戻し後の再監査で GATE_VALID。残る穴は T009
- [x] **T004 — 実際の `~/work` で回し、出力を読んで直す**
  - なぜ: 試験データは自分で作ったもので、実在の Tasks.md の書き方の幅を代表しない
  - 最小検証: `python3 scripts/morning-board/board.py --since 2026-10-30T00:00 | grep -c 'T376'` — 1 以上（layered_dreams の人の判断待ちの行）
  - Gate: `python3 scripts/morning-board/board.py --since 2026-10-30T00:00 --check` — 表に出す行（`[~]` `[!]` `[-]`）で、ID を読めない行と、題が ID・優先度・担当の印で始まる行が 0。加えて `test_board.py` の Shapes と Archive が通る
  - 修正（2026-10-31）: Gate。実データには ID の無い完了行が 234 行あり（AutoRogue・codex-game-test など。表には出ない）、元の条件は満たせない。代わりに表に出る行の題の崩れと、完了記録の 3 つの書き方を条件に足した
  - 着手時の注記: 最小検証は着手前から 1（T376 は T001 から出ていた）。この行の変更では赤にできない。後戻りを見張る役で残す
  - 監査: GATE_VALID。修正理由の「234 行」は数え違いで、ID の無い行は 229 行（完了 192・未着手 37）。ID の無い `[x]` は「終わった」に出ない（受け入れ済み）。残る穴は T008
  - 再現: `python3 scripts/morning-board/board.py --since 2026-10-30T00:00`
- [x] **T005 — 全体の検査に試験を入れ、README に使い方を書く**
  - なぜ: 試験が push 前に走らなければ、壊れても気づかない
  - 最小検証: `grep -c 'morning-board' scripts/check.sh README.md` — それぞれ 1 以上
  - Gate: `bash scripts/check.sh --offline` — `morning-board` の段が ok
  - 再現: `python3 scripts/morning-board/board.py`
  - 監査: GATE_VALID。段を報告だけ（note）に変えても気づけない穴は、差分に出る意図的な変更なので行にしない
- [x] **T006 — 表の形でも `[!]` の行が消えたら試験が赤になる**
  - なぜ: T001 の監査。表の試験データに `[!]` の行が無く、表の正規表現から `!` を外しても全試験が通った
  - 最小検証: `python3 scripts/morning-board/test_board.py Rows` — 表の正規表現から `!` を外すと赤
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/board.py --root scripts/morning-board/fixtures`
- [x] **T007 — 境界の前から `[x]` の行は、後で文面が直っても「終わった」に出ない**
  - なぜ: T002 の監査。引き算を外す変異と、基準を空の木にする変異が全試験を通った。試験データの T1 が HEAD で消えるため
  - 最小検証: `python3 scripts/morning-board/test_board.py Since` — 上の 2 つの変異でどちらも赤
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/test_board.py Since -v`
- [x] **T008 — 題の崩れを、題を整える関数とは別の物差しで見る**
  - なぜ: T004 の監査。`malformed()` が `clean_title()` 自身で判定するため、`TITLE_LEAD` から担当の印を外す後戻りが、実データの `--check` では通ってしまった
  - 最小検証: `python3 scripts/morning-board/test_board.py Shapes` — `TITLE_LEAD` から `〔[^〕]*〕|` を外すと赤
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/board.py --since 2026-10-30T00:00 --check`
  - 着手時の注記: 封印した最小検証は着手前から赤（Shapes の別の試験が落ちる）で、この行を確かめられない。追加の確かめとして、同じ変異で実データの `--check` が直す前 0・直した後 1 になることを見た
- [x] **T009 — `claude agents` が `null` や数だけを返しても、表は出る**
  - なぜ: T003 の再監査。一覧でないことを確かめる行を外しても全試験が通った（試験の `{"sessions": []}` は別の確かめで落ちる）
  - 最小検証: `python3 scripts/morning-board/test_board.py LiveAgents` — `if not isinstance(data, list)` を外すと赤
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/test_board.py LiveAgents -v`
