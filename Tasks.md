# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは消す（この branch の試行では履歴ファイルを持たない。記録は commit）。

次に起票する ID は **T007 以降**。

## 本線 A — 朝の 1 枚（2026-10-31〜）

- [x] **T002 — 指定時刻以降の commit と、`[x]` になった行を repo ごとに出す**
  - なぜ: 「何が終わったか」は今の Tasks.md だけでは分からない（`[x]` は移されて消える）。差分で取る
  - 最小検証: `python3 scripts/morning-board/test_board.py Since` — 一時 repo で、境界より前の commit と `[x]` を出さず、後のものだけ出す
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/board.py --since 2026-10-30T18:00`
- [x] **T003 — いま動いている Claude Code の session を repo ごとに出す**
  - なぜ: Agent View（`claude agents`）は組み込みで入れる物がない。`--json` の cwd で repo に結び付ける
  - 最小検証: `python3 scripts/morning-board/test_board.py Agents` — 試験用の JSON で、cwd が repo の下にある session だけがその repo に付く
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/board.py --agents-json scripts/morning-board/fixtures/agents.json`
- [ ] **T004 — 実際の `~/work` で回し、出力を読んで直す**
  - なぜ: 試験データは自分で作ったもので、実在の Tasks.md の書き方の幅を代表しない
  - 最小検証: `python3 scripts/morning-board/board.py --since 2026-10-30T00:00 | grep -c 'T376'` — 1 以上（layered_dreams の人の判断待ちの行）
  - Gate: `python3 scripts/morning-board/board.py --since 2026-10-30T00:00 --check` — 状態の印がある行のうち、ID を読めなかった行が 0
  - 再現: `python3 scripts/morning-board/board.py --since 2026-10-30T00:00`
- [ ] **T005 — 全体の検査に試験を入れ、README に使い方を書く**
  - なぜ: 試験が push 前に走らなければ、壊れても気づかない
  - 最小検証: `grep -c 'morning-board' scripts/check.sh README.md` — それぞれ 1 以上
  - Gate: `bash scripts/check.sh --offline` — `morning-board` の段が ok
  - 再現: `python3 scripts/morning-board/board.py`
- [ ] **T006 — 表の形でも `[!]` の行が消えたら試験が赤になる**
  - なぜ: T001 の監査。表の試験データに `[!]` の行が無く、表の正規表現から `!` を外しても全試験が通った
  - 最小検証: `python3 scripts/morning-board/test_board.py Rows` — 表の正規表現から `!` を外すと赤
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/board.py --root scripts/morning-board/fixtures`
