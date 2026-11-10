# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは [Tasks-archive.md](Tasks-archive.md) へ移す（1 タスク 1 レコード、Gate・監査・再現・commit）。

次に起票する ID は **T018 以降**。

## 保守（2026-11-10〜）

- [-] **T017 — 監査を回す行と、監査から行を立てる条件を絞る**
  - なぜ: user の指摘。監査が穴を見つけ、その穴の行をまた監査する連鎖に止めどころが無かった。T012〜T016 で 50 行ほどの script に監査 3 回・行 4 つ。使う人が困る不具合は前半で出尽くし、後半は試験の甘さだけ
  - 最小検証: `grep -q 'Audit only rows that changed behaviour' .agents/skills/task-queue-loop/SKILL.md` — 決まりが SKILL.md の手順 8 にある
  - Gate: `grep -q 'Audit only rows that changed behaviour' .agents/skills/task-queue-loop/SKILL.md && grep -q 'only for a defect a user would hit' .agents/skills/task-queue-loop/references/gate-audit-loop.md && grep -q 'defect a user would hit' .agents/skills/task-queue-loop/templates/gate-auditor.md && grep -q '使う人が踏む不具合' .agents/skills/task-queue-loop/templates/work-rules.md && bash scripts/skill-mirrors.sh --check` — 2 つの決まりが手順・監査の手引き・監査役の指示・作業規則の 4 か所にあり、user 側の写しも同じ
  - 再現: `grep -n 'Audit only rows' .agents/skills/task-queue-loop/SKILL.md`

- [x] **T016 — 写しの検査の試験を check.sh で毎回走らせ、下位だけのずれも赤にする**
  - なぜ: T015 の監査。Gate の作る `d/` が skill 直下にあり、`diff -rq` を `diff -q` に退行させても緑のまま。Gate は 1 回しか走らないので、後の退行も防げない
  - 最小検証: `bash scripts/test-skill-mirrors.sh` — 下位だけのずれ・mirror にだけあるディレクトリ・--write の控えと収束・明示した root で 0 件、の 4 つを一時 root で確かめる
  - Gate: `bash scripts/test-skill-mirrors.sh && grep -Eq "^step skill-mirrors-test block bash scripts/test-skill-mirrors.sh" scripts/check.sh` — 試験が通り、check.sh が止める段として毎回走らせる。`diff -rq` を `diff -q` にすると赤
  - 再現: `bash scripts/test-skill-mirrors.sh`

T001〜T015 の記録は [Tasks-archive.md](Tasks-archive.md)。
