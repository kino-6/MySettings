# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは [Tasks-archive.md](Tasks-archive.md) へ移す（1 タスク 1 レコード、Gate・監査・再現・commit）。

次に起票する ID は **T017 以降**。

## 保守（2026-11-10〜）

- [x] **T016 — 写しの検査の試験を check.sh で毎回走らせ、下位だけのずれも赤にする**
  - なぜ: T015 の監査。Gate の作る `d/` が skill 直下にあり、`diff -rq` を `diff -q` に退行させても緑のまま。Gate は 1 回しか走らないので、後の退行も防げない
  - 最小検証: `bash scripts/test-skill-mirrors.sh` — 下位だけのずれ・mirror にだけあるディレクトリ・--write の控えと収束・明示した root で 0 件、の 4 つを一時 root で確かめる
  - Gate: `bash scripts/test-skill-mirrors.sh && grep -Eq "^step skill-mirrors-test block bash scripts/test-skill-mirrors.sh" scripts/check.sh` — 試験が通り、check.sh が止める段として毎回走らせる。`diff -rq` を `diff -q` にすると赤
  - 再現: `bash scripts/test-skill-mirrors.sh`

T001〜T015 の記録は [Tasks-archive.md](Tasks-archive.md)。
