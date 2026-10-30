# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは消す（この branch の試行では履歴ファイルを持たない。記録は commit）。

次に起票する ID は **T012 以降**。

## 本線 A — 朝の 1 枚（2026-10-31〜）

- [x] **T011 — skill を他の repo の session から使えるようにする**
  - なぜ: T010 の監査。user 側の skill 置き場に写しが無く、SKILL.md のパスの基準が書かれず、境界の後に足されて消えた行が 終わった に出ない抜けが Limits に無い
  - 最小検証: `grep -c "境界の後に足されて" .agents/skills/morning-board/SKILL.md` — 1 以上
  - Gate: `diff -r -x __pycache__ .agents/skills/morning-board ~/.claude/skills/morning-board && diff -r -x __pycache__ .agents/skills/morning-board ~/.codex/skills/morning-board && grep -q "SKILL.md のある" .agents/skills/morning-board/SKILL.md && bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check` — 両方の写しが repo と一致し、パスの基準と抜けが書かれ、inventory がずれていない
  - 再現: `ls ~/.claude/skills/morning-board ~/.codex/skills/morning-board`

全行完了（2026-10-31）。T001〜T010 の記録は commit 履歴にある。
