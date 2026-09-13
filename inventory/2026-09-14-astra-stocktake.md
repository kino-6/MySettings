# Local / MySettings 棚卸し — 通常モデルを基準に、Astraを選択利用

実施日: 2026-09-14 JST。**棚卸しと設定案の作成まで完了。運用設定の変更・スキル削除・同期は未実施。**

推奨は「モデル共通の小さい基盤 + 必要時だけ読む詳細手順 + 上位モデル用の短い追加指示」。
モデルの切替と、読み込む指示量の削減は別々に扱う。Astra専用への全面移行はしない。

参考記事は、descriptionの短縮と適用条件の明確化、詳細の段階的読込、AGENTS.mdの再評価を勧めている。
標準モデルとAstraで適切な手順の細かさが異なる点も明記されており、共通基盤を維持する設計と整合する。
[Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra)

## 調査範囲と限界

| 対象 | 実施内容 |
| --- | --- |
| `~/.codex/skills/` / `.agents/skills/` | 全非systemスキルの名前・description・本文サイズ・同名比較。共通directory内の参照ファイルも内容比較 |
| `~/.codex/AGENTS.md` / `.codex/AGENTS.md` | 全文確認、モデル指定・重複・読込位置・承認境界の確認 |
| Local / projectの `config.toml`、agent role | 必要な設定項目を抽出。モデル、profile、MCP一覧、指示キーを確認 |
| inventory / workflow docs | 個数、差分、routing、完了処理の整合確認 |
| Claude Code | user/project設定のキー構造と3つのミラースキルの配置を確認。Claude用設定の全面監査は対象外 |
| system / plugin | 別管理面として存在を確認。systemスキルは6個。pluginキャッシュ内の全スキルの品質監査は対象外 |
| CLI / 公式資料 | CLI 0.154.0、help、モデルカタログ、prompt-input診断、profiles・skills・AGENTSの仕様を確認 |

**全件の構造棚卸しと、常用ワークフローの重点レビュー**である。
全94種類それぞれのAPI例・依存package・外部サービスの動作まで検証したFull Stocktakeではない。
10個の重点スキルは独立した読み取り専用レビューも実施した。

`~/.codex/observations.jsonl` は存在しなかった。7日/30日利用数は不明であり、0回扱いにしない。
scan.shは欠測を0として返すため、[全件一覧TSV](2026-09-14-skill-scan.tsv)では `unknown` とした。
セッション履歴・認証情報は調査していない。診断出力はgitignoredなworkspaceに保持する。

## 数量と差分

| 項目 | 結果 |
| --- | ---: |
| Local非systemスキル | 93 |
| MySettingsスキル | 93 |
| 同名の共通スキル | 92 |
| 種類数の和集合 | 94 |
| 共通92個のうちSKILL.mdが同一 | 91 |
| 共通92個のうち参照ファイルも含めて同一 | 89 |
| repo description合計 | 21,966文字 |
| descriptionが200文字超 | 66 / 93 |
| SKILL.mdが300行超 | 18 / 93 |
| Local / project AGENTS.md | 98行 / 159行 |

200文字・300行は探索用の目印であり、公式の上限や合否基準ではない。
本文は必要時に読み込むため、全本文量を毎回の入力token量とは扱わない。

| 差分 | 内容 | 判断 |
| --- | --- | --- |
| repoのみ | `eval-bottleneck-reduction` | repo限定という既存方針を維持 |
| Localのみ | `sprite-gen` | 自動取り込み対象にしない。公開可能な設定・資産・依存を別途確認する |
| `external-ai-tools/SKILL.md` | Localは7月追加のツールとrouting記述が不足 | repoを正本候補として差分同期を計画 |
| `api-design/references/full-guide.md` | Localには古い認証例のプレースホルダー表記 | 本文だけの同期では取りこぼす。参照ファイルも差分対象にする |
| `security-review/references/full-guide.md` | 参照本文の2行に差分 | 上と同じ。実鍵の漏えいと判定したものではない |

既存 `inventory/codex-skills.md` のLocal 92個、Local-only 0個、差分がskill-stocktakeだけという説明は古い。
`inventory/skill-use-classification.md` のrepo 90 / Local 89も古い。今回のスナップショットを最新の参照先とする。

## 優先度の高い発見

### P0 — 日常モデルへの切替口がない

Localの基底設定は `gpt-6-astra` / `high`。profile用の別ファイルは存在しなかった。
repo側は親モデル未指定なので、MySettingsから起動してもLocalの選択を軽くする設定はない。

提案はTerra / mediumを日常候補、Luna / lowを小作業候補、Astra / mediumを明示選択にすること。
これは比較実験前の候補であり、品質を測ってSolなどに調整できるようにする。
価格と能力の位置づけは[公式モデル比較](https://developers.openai.com/api/docs/models/compare)、
[Terra](https://developers.openai.com/api/docs/models/gpt-5.6-terra)、
[Luna](https://developers.openai.com/api/docs/models/gpt-5.6-luna)を参照した。
契約上の利用枠の節約量や、タスクあたりのtoken削減率は未測定。

[切替用設定案と手順](proposals/model-switch/README.md)を作成済み。Localへは未配置。

### P0 — 子エージェントのGPT-5.4固定が実際に失敗する

`.codex/agents/{explorer,reviewer,docs-researcher}.toml` は `gpt-5.4` 固定。
Local/projectのAGENTSにも全作業でGPT 5.4を推奨する表がある。
今回reviewer roleの起動は、ChatGPTアカウントで当該モデルを利用できないというエラーで失敗した。
これはこのアカウント/実行面での観測であり、GPT-5.4の全提供面での廃止を意味しない。

ローカルカタログには `gpt-6-astra`、`gpt-5.6-sol`、`gpt-5.6-terra`、`gpt-5.6-luna` などを確認した。
roleのモデルは利用できるものへ更新し、日常の探索・レビューに適する設定を個別に選ぶ。
親Astraの無条件継承や、全roleのAstra固定はコスト方針に合わない。
**親用profileを追加するだけではrole固定値は直らない。**

### P1 — 旧profile形式と現行CLIが合わない

`.codex/config.toml` は `[profiles.strict]` / `[profiles.yolo]` を持つが、CLI 0.154.0の `-p` は
`~/.codex/<name>.config.toml` を読む。公式資料では0.134.0以降の変更と明示されている。
旧形式のまま切替機能を増やすと動かない構成になる。
[公式Profiles資料](https://learn.chatgpt.com/docs/config-file/config-advanced#profiles)

### P1 — 指示の置き場所と、設定キーの有効性に問題がある

repo固有ルールは `.codex/AGENTS.md` にある一方、repo rootに `AGENTS.md` がない。
rootから実行した `codex debug prompt-input` ではLocal AGENTSの本文は含まれたが、
project固有の「Agent Change Discipline」は含まれなかった。
通常の探索はrepo rootからcwdへ至るdirectory上のAGENTSであり、`.codex/AGENTS.md` を
repo rootルールとして自動的に読む設計ではない。
[公式AGENTS探索規則](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

採用時はrepo固有の短いルールをrootの `AGENTS.md` へ置く。
159行をそのままrootへ移して常時入力を増やすのではなく、スキル一覧や旧機能説明はREADMEへ寄せる。
このCodexアプリのセッションは独自に渡された指示もあるため、CLI診断の結果と同一視しない。

Local/projectの `persistent_instructions` は取得した公式schemaに存在せず、その文字列も
CLIのprompt診断に現れなかった。コメントには組込み指示とAGENTSの置換について矛盾もある。
追加指示が必要なら現行の `developer_instructions` を確認して使う。
[設定リファレンス](https://learn.chatgpt.com/docs/config-file/config-reference)

### P1 — LIBRARY分類だけでは二重掲載を止められない

Localとrepoには同名92個があり、このアプリのセッションの利用可能スキル一覧にも多数の重複掲載がある。
descriptionの末尾が省略された項目も多く、適用条件を読む前に切れる。
同名スキルは自動統合されないと公式資料にも記載されている。
[スキルの保存場所・検出](https://learn.chatgpt.com/docs/build-skills#where-to-save-skills)

`DAILY / CONDITIONAL / LIBRARY` は文書上のrouting方針であり、スキルの物理的な検出除外設定ではない。
repoを保守上の正本、Localを必要分の配布先とし、MySettings実行時にはLocal側の同名コピーを
runtimeの対応する設定で選択的に無効化する案が有力。ファイルを削除しなくてもよい。
ただし選択的除外のproject適用範囲・plugin併存・実際の一覧変化は採用前に新規セッションで検証する。

通常のCodex skill仕様では `policy.allow_implicit_invocation: false` は自動呼出を抑え、明示呼出を残す。
`enabled=false` との目的の違いを区別する。前者による常時metadata削減は保証しない。
[スキル設定](https://learn.chatgpt.com/docs/build-skills)

`~/.agents/skills` はこの実機には存在しない。現行ドキュメントが挙げるuser保存先と、
このアプリが掲載する `~/.codex/skills` の違いもあるため、移設を一括実行せず利用runtimeを先に確認する。

### P1 — 一律ワークフローが検証と承認を重ねる

`skill-use-manager` のDAILYにはverification、自分のレビュー、stocktake等が並ぶ。
そこへ `ecc-final-check` → `ecc-finish-work` と専用review skillが加わると同じ差分・テストを再確認しやすい。
全モデル共通で「既にある検証を再利用し、差分や未解決リスクがある場合に追加する」に揃える。
外部操作の承認境界は保ち、依頼済みのローカル調査・実装・修正で再承認を必須にしない。

## 重点スキルの判定と具体的な修正候補

判定は変更案。削除・統合・本文変更は未実施。本文根拠は `.agents/skills/<name>/SKILL.md`。
7日/30日利用数はいずれも不明であり、利用頻度による廃止判定はしていない。

| Skill | 判定 | 具体的な変更 |
| --- | --- | --- |
| `skill-use-manager` | Improve | 28行以降のDAILYを縮小。stocktakeは棚卸し時だけ。111行以降のinventory checkを通常routingから分離 |
| `using-agent-skills` | Merge候補 | 発見手順を上のrouterへ集約。全スキルを支配する説明、曖昧さで毎回停止する66行以降を参照用の入口へ縮小。呼出元確認後に統合判断 |
| `agent-self-review` | Keep | 14行以降の一回限り・任意の追加reviewという方針は基盤に適する。既存検証を再利用する点を明記 |
| `verification-loop` | Update | 19行以降をrepoに存在するコマンドの選択へ変更。一律80%・15分ごと実行・固定HEAD~1比較を除去候補に。pipeの終了コードと秘密値出力を改善 |
| `code-review-and-quality` | Improve | 181行以降の別モデルreviewを必要性と予算で選択。通常の自己レビューと専用reviewの境界を明確にし、長い例はreferencesへ |
| `test-driven-development` | Improve | 全挙動変更でtest-first必須という入口を限定。331行以降の再現テスト用subagentを任意に。実装後の有効な挙動検証は維持 |
| `tdd-workflow` | Keep / metadata整合 | 明示的なstrict TDDというdescriptionを維持。AGENTSの常用80% coverageという紹介を合わせる |
| `doubt-driven-development` | Improve | 18行以降の広すぎる対象を重大な未解決判断に限定。毎cycleの別モデル提案と毎回の再承認、追加review連鎖を減らす |
| `context-engineering` | Improve | 258行の一律行数上限を観測ベースへ。新sessionだけで自動発火しない説明にし、判断に影響しない不足情報で停止しない |
| `spec-driven-development` | Improve | 22/197行の実装前承認を既存の依頼範囲に対応。全6節、5ファイル上限、163行のskill連鎖を小規模作業へ強制しない |
| `continuous-learning-v2` | Update | Claude hook実装とCodex手動運用を区別。100%取得などの保証、固定observerモデル、無訂正を承認と扱う記述を再評価 |
| `ecc-task-workflow` | Keep | 小作業はtask folder省略という分岐を維持。必要なcontextだけ残す |
| `ecc-final-check` | Keep | diff・scope・検証確認の最終チェック担当として維持。自己review済みの証拠を使う |
| `ecc-finish-work` | Improve | final-checkの同じ手順を再実行するのでなく、結果参照と引継ぎ更新に絞る |
| `skill-stocktake` | Improve | 利用記録なしを0回と区別。本文だけでなくrefs差分も対象。全件subagent reviewを必須にせず、構造scanと重点reviewを選択可能に |
| `external-ai-tools` | Update | Localとの具体的な差分を解消。全外部ツールの導入は別作業とする |

`verification-loop` のコマンド例は出力を `head` / `tail` にpipeし、元コマンド失敗を見落とし得る。
また秘密値の文字列検索をそのまま出力する例がある。単なるtoken削減より先に検証の信頼性を直す。

## descriptionを先に縮める候補

下記は文字数とtriggerを全件確認したうえでの書換え案。本文の詳細を捨てず、適用条件を先頭へ置く。

| Skill | 現在の文字数 | 入口の案 |
| --- | ---: | --- |
| `generate-explainer-html` | 687 | Build an offline HTML explainer from core.yaml and view.yaml. Use to create or extend that explainer bundle. |
| `build-playable-games` | 597 | Build or improve playable games. Use for gameplay, game feel, game presentation, or a playable vertical slice. |
| `generate-explainer-yaml` | 571 | Create or revise core.yaml and view.yaml for the HTML explainer workflow. |
| `interview-me` | 485 | Clarify a materially underspecified goal through a focused interview. Use when requested or when missing requirements block progress. |
| `strategic-ai-wall-partner` | 442 | Stress-test strategic ideas, assumptions, and decisions through structured dialogue. Use when the user wants a thinking partner. |
| `browser-testing-with-devtools` | 326 | Inspect browser behavior with Chrome DevTools MCP. Use for DOM, console, network, performance, or visual runtime diagnosis. |
| `documentation-lookup` | — | Verify a library API, setup step, or version-sensitive behavior with current official documentation. |
| `git-workflow-and-versioning` | — | Manage commits, branches, versioning, and conflict resolution. Use when these operations are part of the task. |

例をそのまま一括適用する前に、既存の明示呼出・類似スキルとの区別を維持できるか確認する。
特にgame、frontend、researchの専門スキルは存在するだけで不要とは判定しない。

## 採用する順序

1. **切替口を用意**: [3つのprofile案](proposals/model-switch/README.md)を確認し、採用時にLocalへ配置。日常の既定値は別途2項目だけ変更する。
2. **壊れた参照を修復**: roleのGPT-5.4固定、旧profiles、無効な指示キー、repo AGENTSの配置を調整する。
3. **共通基盤を整理**: 検証と承認の重複、routerの競合、広すぎるdescriptionを重点スキルから直す。標準モデルにも必要な詳細はreferencesに残す。
4. **配布を整理**: 全directoryの差分を基にLocalへ必要分だけ反映し、MySettings実行時の二重掲載を選択的に抑える。自動削除しない。
5. **実タスクで比較**: 同じ小修正・設定変更・原因究明で品質と総tokenを比較する。上位モデル補足は選択時だけ読み込む。

更新後も、ブラウザや生成物の実観察、securityやmigrationの固有制約、外部操作の境界は維持する。
「モデルが上位だから必要な検証を省略する」という判定にはしない。

## 今回の成果物・検証

- 全94種類の構造一覧: [TSV](2026-09-14-skill-scan.tsv)。scope、同名本文差分、サイズ、利用数欠測を記録。
- 切替案: [説明と3つのTOML](proposals/model-switch/README.md)。共通基盤とAstra追加指示の分離を具体化。
- 既存inventoryに今回の参照先を追加。過去時点の監査記録は保持。
- scanの個数、directory比較、公式仕様とCLI helpの整合、TOML構文、追加ファイルのリンク、diffの範囲を確認。
- Local設定・既存skill本文・agent roleの適用変更、モデル別の応答/消費量比較、commit/pushは未実施。

`codex --strict-config` は `features` と `debug` では未対応と返ったため、これをschema検証成功とは扱っていない。
通常の `debug prompt-input` は成功した。profileの配置後の読込試験は採用時の確認事項。
