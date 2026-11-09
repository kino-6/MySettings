# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは [Tasks-archive.md](Tasks-archive.md) へ移す（1 タスク 1 レコード、Gate・監査・再現・commit）。

次に起票する ID は **T017 以降**。

## 保守（2026-11-10〜）

- [-] **T016 — 写しの検査の試験を check.sh で毎回走らせ、下位だけのずれも赤にする**
  - なぜ: T015 の監査。Gate の作る `d/` が skill 直下にあり、`diff -rq` を `diff -q` に退行させても緑のまま。Gate は 1 回しか走らないので、後の退行も防げない
  - 最小検証: `bash scripts/test-skill-mirrors.sh` — 下位だけのずれ・mirror にだけあるディレクトリ・--write の控えと収束・明示した root で 0 件、の 4 つを一時 root で確かめる
  - Gate: `bash scripts/test-skill-mirrors.sh && grep -Eq "^step skill-mirrors-test block bash scripts/test-skill-mirrors.sh" scripts/check.sh` — 試験が通り、check.sh が止める段として毎回走らせる。`diff -rq` を `diff -q` にすると赤
  - 再現: `bash scripts/test-skill-mirrors.sh`

- [x] **T015 — skill の写しをそろえる処理と、その Gate の穴をふさぐ**
  - なぜ: T012 の監査。mirror にだけあるディレクトリは --write で控えが中に残って消せず、何度やっても収まらない。gate は下位のずれも --write も試さず、check.sh の行がコメントでも通る。root の打ち間違いが黙って通る
  - 最小検証: `t=$(mktemp -d) && cp -R .agents/skills/morning-board "$t"/ && mkdir "$t"/morning-board/d && echo q >"$t"/morning-board/d/f && SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --write && SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --check` — mirror にだけあるディレクトリが 1 回の --write で収まる
  - Gate: `grep -Eq "^step skill-mirrors block bash scripts/skill-mirrors.sh --check" scripts/check.sh && ! SKILL_MIRROR_ROOTS=/nonexistent bash scripts/skill-mirrors.sh --check && t=$(mktemp -d) && cp -R .agents/skills/morning-board "$t"/ && echo x >>"$t"/morning-board/scripts/board.py && mkdir "$t"/morning-board/d && echo q >"$t"/morning-board/d/f && ! SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --check && SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --write && SKILL_MIRROR_ROOTS="$t" bash scripts/skill-mirrors.sh --check && ls "$t".bak/*/morning-board/scripts/board.py "$t".bak/*/morning-board/d/f` — check.sh が止める段として呼び、明示した root で 0 件なら赤、下位のずれを見つけ、--write が mirror の外に控えを残して 1 回で収まる
  - 再現: 最小検証と同じ

T001〜T014 の記録は [Tasks-archive.md](Tasks-archive.md)。
