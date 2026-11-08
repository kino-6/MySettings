# Check

## Diff Scope

- Codex の追跡設定から廃止項目と無効な profile table を除去した。
- `strict` / `yolo` を Codex が読む user-level config layer として追加した。
- 既存の最終返答検査を Codex の Stop hook に対応させ、互換試験を追加した。
- strict config、profile、hook discovery を `scripts/check-codex-config.sh` で検査し、
  通常の `scripts/check.sh` に組み込んだ。
- 実装と食い違っていた Codex の説明を更新した。

## Verification Run

- 当初の最小検証は実装前に test file 不在で終了 2、実装後は 4 test が合格した。
- Gate audit で廃止設定の復活を当初の最小検証が見落としたため、amendment を記録して
  `bash scripts/check-codex-config.sh` へ広げた。
- 行の Gate は 2026-11-08 に合格した。
- `bash scripts/check.sh --offline` は `CHECK OK` で完了した。
- Codex CLI 0.167.0 の `app-server --strict-config --print-startup-config` で
  active config を検証した。
- `codex -p strict` と `codex -p yolo` で両 profile の読み込みを確認した。

## Evidence Produced

- `hooks/list` は Stop hook を 1 件返し、warning / error なし、active user config
  では `trustStatus: trusted` を返した。
- 英語のみで 120 words 以上を返す実 Codex turn は agent message を 2 件生成した。
  1 件目で Stop hook が継続を要求し、2 件目は `stop_hook_active` により終了したため、
  1 回だけの再実行と無限ループ防止を同時に確認できた。
- 配置後の `~/.codex/{AGENTS.md,hooks.json,strict.config.toml,yolo.config.toml}` は
  追跡中のコピーと一致し、active config に旧 key は残っていない。

## Findings

- `persistent_instructions` は strict config で未知の field として拒否された。
- `[profiles.<name>]` は現行 Codex では profile として読まれず、個別の
  `$CODEX_HOME/<name>.config.toml` が必要だった。
- `agents.max_threads` は互換 alias だが、現行名は
  `max_concurrent_threads_per_session` だった。
- hooks と multi-agent の説明は、現行実装と追跡設定の双方に合っていなかった。

## Known Blind Spots

- 実 Codex turn は Stop hook の継続回数を観察したが、返答本文の意味品質までは
  自動判定していない。
- hook の trust hash は machine-local state なので repository では再現しない。
- `tool-inventory` は既存の `brew-leaves.txt` と `npm-global.txt` を stale と報告したが、
  offline check の成否には影響しなかった。

## Residual Risk

- command hook は異常終了時に処理を許す場合があるため、安全機能には使えない。
- 実 Codex turn で既存の `computer-use` MCP / `legacy_notify` / notify command の
  file-not-found warning が出た。今回の設定移行とは独立した user-level state である。

## Follow-Ups

- `computer-use` と通知 command の古い参照は、別タスクで user config と plugin cache
  の所有関係を確認してから整理する。

## Gate Audit

- 初回 verdict: `GATE_BROKEN`。Codex 出力分岐の変異は Gate / 最小検証とも赤だったが、
  `persistent_instructions` の復活は Gate だけが赤だった。
- 対応: 最小検証を、hook test を内包する `scripts/check-codex-config.sh` へ広げた。
- 2 回目 verdict: `GATE_BROKEN`。`hooks.json` の runtime を `claude` へ変えても、
  hook discovery と本体の直接試験が別々に通り、誤配線を見落とした。
- 対応: 登録 command を隔離 HOME へ配置した script に対して実行し、Codex の
  `decision: "block"` と `reason` が返ることを最小検証へ追加した。
- 最終 verdict: `GATE_VALID`。実装差分の取り消し、Codex 出力分岐の破壊、
  `persistent_instructions` の復活、runtime の `codex` から `claude` への誤配線で、
  最小検証と Gate はすべて赤になった。逐語の再現は `decision: "block"` を返した。
