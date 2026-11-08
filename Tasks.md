# Tasks.md — 作業のブレークダウン

> **READ FIRST** 憲章は [CHARTER.md](CHARTER.md)。作業規律は [work-rules.md](.agents/skills/task-queue-loop/templates/work-rules.md)。
> **毎周の入口でこのファイルと CHARTER.md を読み、`[x]` を付ける前に work-rules.md を読む。**
> **上から 1 件ずつ**処理する。題が下に無ければ脇道と明記する。**200 行以内**（pre-commit が数える）。
> 最小検証と Gate は着手前に書き、`Tasks.lock.json` に封印する。フルの検査は push の直前（`bash scripts/push.sh` が `scripts/check.sh` を走らせる）。
> 完了した行は 1 件だけ下に残し、それより古いものは消す（この branch の試行では履歴ファイルを持たない。記録は commit）。

次に起票する ID は **T014 以降**。

## 本線 B — Codex 公式実装との整合（2026-11-08〜）

- [x] **T013 — Codex 設定を現行仕様へ合わせ、Stop hook と厳格検査を実証して導入する**
  - なぜ: `persistent_instructions` と旧 profile 形式が現行 CLI で効かず、AGENTS.md も hooks / multi-agent / MCP の実態とずれている
  - 最小検証: `bash scripts/check-codex-config.sh` — Codex 設定と profile の厳格検査、Stop hook の読み込み、英語検出・1 回だけの継続・Claude 互換出力が通る
  - Gate: `bash scripts/check-codex-config.sh && python3 .agents/skills/progress-contract/scripts/test_report_check.py && bash scripts/skill-mirrors.sh --check` — 追跡中の Codex 設定と profile が厳格検査を通り、hook の両 runtime 出力と skill の写しが一致する
  - 再現: `REPORT_CHECKS=lang REPORT_HOOK_RUNTIME=codex python3 .agents/skills/progress-contract/scripts/report_check.py <<<'{"stop_hook_active":false,"last_assistant_message":"This deliberately long English response demonstrates that the Codex Stop hook detects a final answer written in English and requests one revision before the turn is allowed to finish normally."}'`

T001〜T012 の記録は commit 履歴にある。
