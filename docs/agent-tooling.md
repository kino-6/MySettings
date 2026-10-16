# Agent tooling
> [README](../README.md) に戻る。ここは agent（Claude Code / Codex）まわりの道具と方針。
> 設定と setup script は README 側にある。

## ECC / Codex baseline

2026-09-14: [Local / MySettingsの棚卸し](../inventory/2026-09-14-astra-stocktake.md)と、
[日常モデル・Astraの切替設定案](../inventory/proposals/model-switch/README.md)を追加しました。
運用設定には未適用です。現行CLIではprofileは `~/.codex/<name>.config.toml` に分けます。

このリポジトリは [affaan-m/ECC](https://github.com/affaan-m/ECC) の Codex 向け baseline を project-local に取り込んでいます。

- `.codex/config.toml`: Codex CLI 用の sandbox / MCP / multi-agent baseline
- `.codex/agents/`: `explorer`, `reviewer`, `docs-researcher` の role 定義
- `.codex/AGENTS.md`: Codex 向け ECC 補助指示
- `.agents/skills/`: Codex が auto-load する project-local skills
- `.agents/plugins/marketplace.json`: ECC plugin metadata
- `.agents/ecc-workflow/`: 外部 agent harness の設計から着想を得た軽量 task / spec / journal workflow

既存のローカル skill は保持し、ECC upstream 由来の不足 skill だけを add-only で追加しています。`notify` は macOS/WSL 両対応のため project baseline では無効化し、必要な host だけ `~/.codex/config.toml` で有効化する方針です。

追加で、`hirokita117/yaml-to-html-skill` 由来の explainer workflow を project-local skill として取り込んでいます。

- `generate-explainer-yaml`: ドキュメント / PR / README / 仕様などを `core.yaml` と `view.yaml` に整理
- `generate-explainer-html`: その YAML から、ライト / ダーク切り替え付きのオフライン HTML explainer bundle を生成

取り込み元は MIT License のため、各 skill directory に upstream `LICENSE` を同梱しています。

さらに、[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) の production engineering workflow skills 24 個を repo と local `~/.codex/skills/` の両方に取り込んでいます。

- `using-agent-skills`: Addy pack 側の meta router。既存の `skill-use-manager` をこの repo の daily router として維持し、こちらは参照用に保持
- lifecycle skills: `interview-me`, `idea-refine`, `spec-driven-development`, `planning-and-task-breakdown`, `incremental-implementation`, `test-driven-development`, `code-review-and-quality`, `git-workflow-and-versioning`, `shipping-and-launch` など
- production quality skills: `source-driven-development`, `doubt-driven-development`, `security-and-hardening`, `performance-optimization`, `frontend-ui-engineering`, `browser-testing-with-devtools`, `ci-cd-and-automation`, `observability-and-instrumentation` など

Standalone Codex skill として参照が切れないよう、upstream root の `references/` や `agents/` を必要な skill directory に寄せています。

また、[mattpocock/skills](https://github.com/mattpocock/skills) から design grilling 一式を add-only で取り込んでいます（MIT License のため各 skill directory に upstream `LICENSE` を同梱）。

- `grill-with-docs`: user 明示呼び出し専用の composite entry point。単体では何もせず `grilling` と `domain-modeling` を呼ぶだけなので、3 つセットで維持する
- `grilling`: 決定木の frontier を 1 round ずつ潰していく質問攻め。各質問に推奨解を添え、user の回答を待ってから次の round に進む
- `domain-modeling`: 用語のブレを潰して `GLOSSARY.md`（glossary）と `docs/adr/`（ADR）に落とす。format は同梱の `GLOSSARY-FORMAT.md` / `ADR-FORMAT.md`

この 3 つはローカルの全プロジェクトから参照できるよう、repo に加えて `~/.codex/skills/`（Codex CLI）と `~/.claude/skills/`（Claude Code）の両方にミラーしています。Claude Code は `~/.codex/skills` を読まないため、user-level skill を両 runtime で使う場合は両方へ配置する方針です。

### Tasks.md の運用を skill 化（task-queue-loop）

ローカルの 11 リポジトリ（`steering-health-intelligence`, `rustbound`, `black-stela`, `cdda-musou`, `ecliptica`, `virtual-ecu-peripheral-harness`, `watchless-notes`, `AutoRogue`, `codex-game-test` ほか）で実際に動いている `Tasks.md` 運用を収集し、`task-queue-loop` として 1 本にまとめています。「Tasks.md は todo list ではなく loop の状態で、1 周 = 1 タスクを未着手から緑の Gate + commit まで運ぶ」という形に整理したものです。

- `SKILL.md`: 1 周の手順（入口で キュー + 憲章 を読む → 上から 1 件 → Gate を先に書く → 赤いことを確かめる → 実装と自己検証 → commit → 別視点の監査 → 同じ編集で整備）、状態記号、完了の 4 条件、ファイルの不変条件（200 行上限・置き場所の地図・次の ID の宣言）
- `references/gates.md`: 落とせる Gate の書き方。曖昧語を数値とキー名へ落とす、修正前に赤を確認する、機械判定が書けない場合の扱い
- `references/gate-audit-loop.md`: **別視点エージェントによる Gate 監査ループ**。差分ではなく Gate を攻める（差分を戻して赤くなるか、挙動を壊して赤くなるか、assertion が実際に走ったか）。判定は `GATE_VALID` / `GATE_BROKEN` / `EVIDENCE_MISSING` の固定書式で返し、refactoring 案は **Gate 付きの行**としてキューへ積む。自動化は subagent への dispatch と、キューファイルへの `PostToolUse` hook（監査記録の無い `[x]` を拒否）の 2 段
- `references/collected-practice.md`: どの規則をどのリポジトリから取ったかの対応表と、規則が答えている実際の失敗例
- `templates/`: `Tasks.md`（READ FIRST ヘッダ入りのキュー）、`work-rules.md`（規律の実体）、`CHARTER.md`、`Tasks-archive.md`、`gate-auditor.md`（`.claude/agents/` へ置く監査 subagent 定義）、`Tasks.lock.json` と `hooks/`（pre-commit / pre-push）
- `scripts/check_tasks_lock.py`: 着手済みの行の最小検証と Gate を `Tasks.lock.json` に封印し、**緩めるには理由つきの amendment を要求**する。Tasks.md は人が読む表示、lock は agent が黙って変えられない封印（lockfile と同じ関係）

行の列は「何を・なぜ・**最小検証**・Gate・状態」。最小検証は Gate と同じ契約（コマンド + 条件 + 落とせること）を負い、違うのは頻度だけです（最小検証は毎回・秒で、Gate は commit 直前に一度）。実測では絞った 1 本が 1 秒 / 3 tests に対しフル Gate は 914 tests で、反復のたびにフル Gate を回すのが遅さの主因でした。並列化は**絞ったあとの第二の梃子**として、効く場合と効かない場合を併記しています。

規律の実体は `Tasks.md` ではなく `work-rules.md` 側に置いています。収集した 5 本のうち**行数が最も多い 2 本（197 行 / 178 行）が、ヘッダが最も薄い（8 行）**という関係があり、ヘッダの重さと行の余地は直接トレードオフになるためです（初版は 64 行ヘッダで、200 行上限の 3 割を貼った時点で消費していました）。

必要になったときだけ読む subskill を 2 本内蔵しています（どちらもほぼ汎用なので別 skill に切らず、router 側に個別の trigger 行を置いて到達性だけ確保しています）。

- `references/runtime-contract.md`: **agent が操作できる runtime の契約**。単一の起動入口（help をコードから導出して嘘をつかせない）、排他ロックと run-scope 分離、プレイ中でも検証を回す shadow tree、**Agent レーンは headless のみ**（macOS でウィンドウを作ると約 0.5 秒前面化する実測つき）とそれを落とす検査、ウィンドウ無しの実画素 capture、seed 指定、**版と seed を画面内に焼く**（タイトルバーとログはスクリーンショットに写らない）、録画は人が明示したときだけの隔離レーン
- `references/trouble-registry.md`: **過去トラの型への汎化**。個別の事象ではなく「型」を回数つきで持つ（最多 11 回）。登録は pre-commit hook が自動で未分類節へ追記し、**型への振り分けが済むまで commit を止める**。SessionStart hook で型一覧を文脈に入れ、結論を書く前に通すチェックリスト skill と対にする。機械で判定できる型は機械へ移し、人の判断が要る一覧を短く保つ

実例は `cdda-musou/run.sh` + `docs/LEARNED.md`（33件）+ `gate` skill、`black-stela/run.sh`、`ecliptica/run.sh`、`rustbound/Run.sh` + `tools/shadow.sh` + `docs/trouble-log.md`、`steering-health-intelligence/TROUBLES.md`（46 型）+ `sync_troubles.py` + `check_repo.py` から取っています。

Gate を書いた本人が完了も判定する自己承認が構造的な穴だったため、監査を「工程」ではなく **loop の一部**にしています（監査の出力が次の周のタスクになる）。テンプレートは実際の対象リポジトリに合わせて日本語、`SKILL.md` と `references/` は他の skill と揃えて英語です。

### Structured agent workflow

外部 agent harness 本体はまだ導入せず、衝突しにくい軽量 workflow だけを `.agents/ecc-workflow/` に置いています。

- `spec/`: repo 固有の永続ルールや再利用する判断材料
- `templates/task/`: `prd.md`, `implement.md`, `check.md`, `journal.md` の雛形
- `tasks/`: 複数 file / 複数 session / agent 挙動変更など、文脈を残したい作業の artifact
- `workspace/`: local journal 用。private / host-specific な内容を含み得るため gitignore

関連 skill:

- `ecc-task-workflow`: 大きめの作業を始めるとき、必要なら task artifact を作る
- `ecc-final-check`: substantial な変更の最後に diff / scope / verification を確認
- `ecc-finish-work`: 作業終了時に check 更新、resume notes、再利用できる学びの昇格を行う
- `observable-development-loop`: diff だけで判断できない出力に対して、観察方法・固定の比較条件・機械的な検証・残す証拠を Observability Contract として決める

この workflow は vendor 固有の workflow directory を作らず、外部 harness の init command も実行しません。将来フル導入を試す場合は、一時 branch か scratch repo で generated diff を確認してから取り込む方針です。

## 公開前チェック（repo-preflight）

private で作業していると事故が表に出ないので、**公開する・新しい remote を足す・誰かに渡す前**に、秘密情報・個人情報・危ないファイルを洗い出す skill です。

```bash
python3 .agents/skills/repo-preflight/scripts/preflight.py            # 追跡中 + 未追跡
python3 .agents/skills/repo-preflight/scripts/preflight.py --history  # 全 commit も
```

**報告だけで、何も変更しません。** 提案する対処（ignore 行の追加・伏字化・追跡解除・失効）は、すべてユーザの確認後にだけ行います。

**`.gitignore` で防げるのは未追跡のファイルだけ**です。commit 済みのものには効かず、履歴にも残ります。なので状態ごとに対処を分けます。

| 状態 | ignore で防げるか | 提案する対処 |
|---|---|---|
| 未追跡 | 防げる | ignore 行を追加 |
| 追跡済み（秘密情報） | 防げない | `git rm --cached` + ignore（履歴には残る） |
| 追跡済み（個人情報） | 防げない | **その場で伏字化**（ファイル自体は残す） |
| 履歴のみ | 防げない | **失効・再発行が先**。履歴の書き換えは別途確認 |

**一度でも commit した秘密情報は漏れたものとして扱い、失効させます。** 追跡を外しても漏洩は取り消せません。

検出した値は先頭 4 文字と長さだけ表示します（報告から会話ログへ再流出させないため）。標準ライブラリだけで、通信もしません。`gitleaks` / `trufflehog` の方が対応形式は広いですが、導入はユーザの判断です。


## 応答の作法（progress-contract）

「黙って裏で数分やって回答が来る。酷い時は 1 時間続けて、その合間に返す」という指摘（2026-10-16）を汎化した skill です。**問題は作業量ではなく、作業中に何も返らないこと** —— 十分やってから答えるのは、遅いのではなく「居ない」。

`observable-development-loop` と対になります。あちらは **agent が自分の出力を見る**側、こちらは **人が agent を見る**側です。

- `SKILL.md`: 待っている人に対して負っているもの 4 つ（いま何をしているか / あとどれくらいか / どの依頼が進行中か / 結果は都度）と、**閾値**
- `templates/response-cadence.md`: 常時読まれるファイルへ貼る設置物
- `references/collected-practice.md`: 元の指摘と、添えられた一幕から数えた失敗（依頼 4 件に着手宣言ゼロ / tool 呼び出し 8 連続で文章なし / 背景実行に回したのを言っていない 等）

**過剰な narration も失敗**として扱っています。1 手ごとに書くと全部読み飛ばされ、肝心の 1 行も飛ばされるので、閾値の表には**「何も言わない」が正解の行**を入れてあります。単位は手ではなく**判断と待ち**です。

**skill だけでは効きません。** skill は description が引っかかったときだけ読まれるのに対し、これは毎ターン効く必要があります。実際、指摘の出どころである `~/work/layered_dreams` には `CLAUDE.md` が 1 つも無く、user レベルの指示面も無かったため、**あの repo では何も効いていませんでした** —— 足りなかったのは規則ではなく**置き場所**です。

なので skill は判断を持ち、設置物は常時読まれる場所に置きます。この環境では `settings/common/.claude/CLAUDE.md` がその実体で、`deploy_tree` が `~/.claude/CLAUDE.md` へ配置します（hidden dir も展開するため setup script の変更は不要）。

**強制はできません。** hook はコマンドを実行する仕組みで、発話させる手段がないため、これは指示にとどまります。

## 取り込み元の記録（provenance）

新しく vendor した skill は、`LICENSE` の隣に `provenance.json` を置きます。記録するのは **upstream の repo / 取得した正確な revision / ファイルごとの sha256 / 検証日**です。

```bash
bash scripts/check-provenance.sh          # 記録した revision と突き合わせて報告
bash scripts/check-provenance.sh --check  # drift / ローカル改変 / upstream 消失があれば exit 1
```

LICENSE を同梱するだけでは「どの時点のコピーか」が残らず、upstream が動いても気づけません。実際に初回実行で、`mattpocock/skills` が **`CONTEXT.md` を `GLOSSARY.md` にリネーム**していたことが判明し、手元の `domain-modeling` は upstream が捨てた名前を教え続けていました。3 つを `6fd94792` で取り直し、この repo 側の記述も揃えています。

既存の取り込み（ECC / Addy pack / yaml-to-html-skill）には `provenance.json` がありません。取得 revision が記録されておらず、推測で埋めるのは正直な欠落より悪いので、意図的に再 vendor するときに付けます。

考え方は [Alder](https://github.com/mk3008/alder) から借りました（同梱の参照コピーを digest で固定している）。それ以外は採用していません。

## MCP の版固定とセキュリティ方針

`.codex/config.toml` と `~/.codex/config.toml` の MCP server は**正確な版に固定**し、`@latest` は使いません（2026-10-06 固定）。

`npx -y <pkg>` は**起動ごとに npm が返したものを無審査で実行**するため、固定していないと「信頼された名前 + 新しい版」だけで任意コードが agent の環境で動きます。実際に `book-to-skill` では、名前を模した再アップロードがウォレットデータを外部送信する事例が起きています（公式 repo の `SECURITY-NOTICE.md`）。

更新は自動化せず、各自が手で実施します。古さの把握だけを script に任せます。

```bash
bash scripts/mcp-doctor.sh          # pin と latest の比較、各 pin が何日古いか
bash scripts/mcp-doctor.sh --check  # 閾値超過があれば exit 1
```

- 閾値は「latest の公開が pin より **120 日**以上新しい」。`MCP_STALE_DAYS` で変更可
- script は**報告のみ**。install も編集もしません。取得するのは npm の読み取り専用メタデータだけ
- `--check` が非ゼロのとき、agent は**どの pin が何日古いかを伝えて止まる**。版を上げるのは upstream の changelog を読んだ上での user の判断で、agent が勝手に pin を上げたり `@latest` へ戻したりはしません（[CLAUDE.md](../CLAUDE.md) / [.codex/AGENTS.md](../.codex/AGENTS.md) に明記）

セキュリティ監査そのものも、**外部ツールを導入せず**この repository 内の読めるコマンドで行う方針です。スキャナを落としてきて走らせる手順は、そのスキャナの信頼を丸ごと取り込むためです。
