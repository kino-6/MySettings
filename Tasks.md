# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは消す（この branch の試行では履歴ファイルを持たない。記録は commit）。

次に起票する ID は **T015 以降**。

## 保守（2026-11-10〜）

- [-] **T014 — 完了した行を履歴ファイルに残し、憲章を本線 A・B に合わせる**
  - なぜ: 完了記録が commit にしか無く、次の改良で「何をもって完了としたか」を辿りにくい（user の指摘）。朝の 1 枚も、消された行は「終わった」に出せない。憲章は本線 A だけで、完了の判断も T001〜T005 のまま
  - 最小検証: `grep -c "^### T0" Tasks-archive.md` — 13（T001〜T013 が 1 件ずつ）
  - Gate: `! grep -q "履歴ファイルを持たない" Tasks.md && grep -q "本線 B" CHARTER.md && test "$(python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T00:00 | grep -A4 "^## MySettings" | grep "終わった" | grep -o "T0[0-9][0-9]" | sort -u | wc -l)" -ge 13` — 見出しと憲章が今の運用に合い、朝の 1 枚が MySettings の T001〜T013 を「終わった」に出す
  - 再現: `python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T00:00 | grep -A4 '^## MySettings'`

## 本線 B — Codex 公式実装との整合（2026-11-08〜）

- [x] **T013 — Codex 設定を現行仕様へ合わせ、Stop hook と厳格検査を実証して導入する**
  - なぜ: `persistent_instructions` と旧 profile 形式が現行 CLI で効かず、AGENTS.md も hooks / multi-agent / MCP の実態とずれている
  - 最小検証: `bash scripts/check-codex-config.sh` — Codex 設定と profile の厳格検査、Stop hook の読み込み、英語検出・1 回だけの継続・Claude 互換出力が通る
  - Gate: `bash scripts/check-codex-config.sh && python3 .agents/skills/progress-contract/scripts/test_report_check.py && bash scripts/skill-mirrors.sh --check` — 追跡中の Codex 設定と profile が厳格検査を通り、hook の両 runtime 出力と skill の写しが一致する
  - 再現: `REPORT_CHECKS=lang REPORT_HOOK_RUNTIME=codex python3 .agents/skills/progress-contract/scripts/report_check.py <<<'{"stop_hook_active":false,"last_assistant_message":"This deliberately long English response demonstrates that the Codex Stop hook detects a final answer written in English and requests one revision before the turn is allowed to finish normally."}'`

T001〜T012 の記録は commit 履歴にある。
