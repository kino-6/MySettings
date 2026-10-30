# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは消す（この branch の試行では履歴ファイルを持たない。記録は commit）。

次に起票する ID は **T013 以降**。

## 本線 A — 朝の 1 枚（2026-10-31〜）

- [x] **T012 — skill の写しのずれを push 前に見つける**
  - なぜ: user の問い「Skill 改良の際困らないか」。写しに 1 行足しても inventory も check.sh も通った。api-design・external-ai-tools・security-review は既に `~/.codex/skills` 側が古い
  - 最小検証: `bash scripts/skill-mirrors.sh --check` — 今ある 3 件のずれで赤、そろえた後は緑
  - Gate: `bash scripts/skill-mirrors.sh --check && grep -q "skill-mirrors.sh --check" scripts/check.sh && t=$(mktemp -d) && cp -R .agents/skills/morning-board "$t"/ && echo x >>"$t"/morning-board/SKILL.md && ! SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --check` — 写しがそろい、check.sh が呼び、1 行足した写しで赤になる
  - 再現: `bash scripts/skill-mirrors.sh --check`

全行完了（2026-10-31）。T001〜T011 の記録は commit 履歴にある。
