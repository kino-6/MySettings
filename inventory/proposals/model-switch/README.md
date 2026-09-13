# モデル切替案 — 未適用

2026-09-14 の棚卸しに伴う設定案。Local の `config.toml`、skills、既定モデルは変更していない。

## 構成

| Profile | モデル / effort | 用途 |
| --- | --- | --- |
| `fast` | GPT-5.6 Luna / low | 範囲が明確な小修正、文章整理 |
| `daily` | GPT-5.6 Terra / medium | 日常の実装・調査・設定変更の候補 |
| `deep` | GPT-6 Astra / medium | 難しい原因究明、設計判断、完了までの統合作業を明示的に依頼するとき |

この割当ては運用案であり、MySettings の実タスクで品質・消費量を比較した結果ではない。
Sol を常用したい場合は `daily.config.toml` のモデルを `gpt-5.6-sol` に変更できる。
モデル名は2026-09-14のローカルカタログと公式モデル資料で確認したが、各モデルの実行試験は行っていない。

## 今すぐ一時的に切り替える

設定ファイルを変更せずにモデルと effort を指定する例:

```bash
codex -m gpt-5.6-terra -c 'model_reasoning_effort="medium"'
codex -m gpt-5.6-luna -c 'model_reasoning_effort="low"'
codex -m gpt-6-astra -c 'model_reasoning_effort="medium"'
```

これらはモデル選択だけの例。`deep.config.toml` の追加指示は注入しない。
既存セッション内でモデルだけを切り替えても、既に読んだスキル本文は取り消されない。
コストを比較する際は、同じ短いタスク文と入力から新規セッションを開始する。

## Profile として使う場合

Codex CLI 0.134.0以降は、`~/.codex/<name>.config.toml` が切替用ファイル。
`config.toml` 内の `[profiles.<name>]` とトップレベル `profile` は新方式の選択方法ではない。
この実機のCLI 0.154.0の `--help` と[公式Profiles資料](https://learn.chatgpt.com/docs/config-file/config-advanced#profiles)で確認した。

採用時は、同名ファイルがないことを確認して3つの `.config.toml` を `~/.codex/` へ配置する。
既存の `config.toml` 全体をコピーで置換しない。配置後の起動例:

```bash
codex -p daily
codex -p fast
codex -p deep
```

Profile はユーザー基底設定より優先されるが、project設定とCLI引数より優先度が低い。
MySettingsの現状はproject側の親モデル指定がないため、その点では切替を妨げない。
他repoではproject側の `model` / `model_reasoning_effort` を確認する。

Profile を配置するだけでは、引数なしの `codex` は日常モデルにならない。
常用化する場合は、Localの基底設定の **model と model_reasoning_effort の2項目だけ** を
日常用の値へ変更し、Astraは `-p deep` で選ぶ。認証・MCP・通知・承認設定は別の管理対象。

`developer_instructions` は組込み指示への追加として使えるが、設定レイヤー間の文字列は
自動追記されない。既存値があれば採用時に統合する。`model_instructions_file` で組込み指示を
置き換える方法は今回の設計に使わない。
[設定リファレンス](https://learn.chatgpt.com/docs/config-file/config-reference)

これらのprofileは親モデルを指定する。既存の `.codex/agents/*.toml` と
`~/.codex/agents/*.toml` にある子モデルの固定値は別途見直す必要がある。
親をAstraにしただけで全子エージェントもAstraになる設計にはしない。

## 指示の分け方

- 共通 `AGENTS.md`: 作業範囲、repo固有の制約、完了条件、適切な検証、外部操作の境界。
- スキル: 共通の短い入口。標準モデルが必要なときに読める詳細手順を `references/` に維持する。
- 上位モデル補足: `deep.config.toml` の短い追加指示に集約。全スキルへAstra節を増殖させない。

標準モデルでも、毎回全資料を読む・同じ検証を繰り返す・既承認作業で承認を取り直す、という
指示は共通部分から見直す。Astraだけでその過剰さを打ち消す構成にしない。

タスク文の共通例:

```text
目的: <誰が何をできるようになるか>
対象: <変更する範囲>
完了: <成果物と確認できる受入条件>
制約: <守る条件。既存の承認範囲も含む>
```

Astraへ引き継ぐときは、目的・変更ファイル・既に通った検証・未解決の判断・終了条件を渡す。
会話全文や全スキル一覧を引き継ぎ資料へ重複して貼らない。

## 評価と戻し方

小修正、設定変更、原因究明の3タスクを固定し、現在の構成と提案構成を比較する。
各タスクの合否、人の手直し回数、不要な質問数、ツール実行数、実際に取得できる入力・出力・推論token、
経過時間を記録する。予算上限がある場合はユーザーが指定した値を使用する。
品質を維持できた条件から採用する。モデルが高価でも総作業量が減る場合があるため、単価だけで判定しない。

比較は今回未実施。API単価とChatGPT/Codex契約の利用枠は同一視しない。

`-p` を外せば基底設定で起動できる。後で基底モデルも変えた場合は、その2項目を採用前の値へ戻す。
Profile未導入時の一時切替は、次回その引数を付けずに起動すれば終了する。

構文はPythonのTOML parserで確認。実アカウントでのprofile読込・応答品質・消費tokenの試験は未実施。
