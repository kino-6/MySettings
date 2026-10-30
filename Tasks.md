# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは消す（この branch の試行では履歴ファイルを持たない。記録は commit）。

次に起票する ID は **T011 以降**。

## 本線 A — 朝の 1 枚（2026-10-31〜）

- [-] **T010 — 朝の 1 枚を skill `morning-board` にまとめる**
  - なぜ: user の指摘。dotfiles の scripts より、どの repo の session からも呼べる skill が置き場に合う
  - 最小検証: `python3 .agents/skills/morning-board/scripts/test_board.py` — skill の下で全試験が通る
  - Gate: `python3 .agents/skills/morning-board/scripts/test_board.py && ! test -e scripts/morning-board && bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check` — 試験が通り、旧置き場が無く、inventory がずれていない
  - 再現: `python3 .agents/skills/morning-board/scripts/board.py --root .agents/skills/morning-board/scripts/fixtures --since 2000-01-01 --agents-json .agents/skills/morning-board/scripts/fixtures/agents.json`

- [x] **T009 — `claude agents` が `null` や数だけを返しても、表は出る**
  - なぜ: T003 の再監査。一覧でないことを確かめる行を外しても全試験が通った（試験の `{"sessions": []}` は別の確かめで落ちる）
  - 最小検証: `python3 scripts/morning-board/test_board.py LiveAgents` — `if not isinstance(data, list)` を外すと赤
  - Gate: `python3 scripts/morning-board/test_board.py` — 全試験が通る
  - 再現: `python3 scripts/morning-board/test_board.py LiveAgents -v`
  - 監査: GATE_VALID（T006〜T009 をまとめて 1 回）

全行完了（2026-10-31）。T001〜T008 の記録は commit 履歴にある。
