# MySettings

Mac と WSL の dotfiles / setup を整理し、再構築しやすく保つためのリポジトリです。

- **Mac**: 既存の常用運用を維持する便利ツール環境
- **WSL**: 開発特化型 CLI 環境（toolbox / Assist 用）
- **Python 方針**: WSL でも `uv` ベースの常用補助環境を使い、使い捨てスクリプトをすぐ書ける状態にする
- **Neovim 方針**: WSL CLI 上で素早く編集するための軽量サブエディタ（VSCode 置き換え目的ではない）
- **GPU / 重い ML**: Windows 側で実行（WSL では実施しない）

## Directory Layout

```text
.
├── README.md
├── mac-setup.sh
├── wsl-setup.sh
├── windows-setup.ps1
├── scripts/
│   ├── wsl-doctor.sh
│   ├── wsl-maintenance.sh
│   ├── mac-maintenance.sh
│   ├── lint.sh
│   └── wsl-cleanup.sh
└── settings/
    ├── common/
    │   ├── .vimrc
    │   ├── .zshrc.common
    │   └── .config/
    │       └── starship.toml
    ├── mac/
    │   ├── .zshrc
    │   ├── .nanorc
    │   └── ghostty.ini
    ├── windows/
    │   └── Microsoft.PowerShell_profile.ps1
    ├── windows-terminal/
    │   └── settings.json
    └── wsl/
        ├── .zshrc
        ├── .nanorc
        └── nvim/
            ├── init.lua
            ├── lazy-lock.json
            └── lua/
                └── mysettings/
                    ├── core/
                    │   ├── keymaps.lua
                    │   └── options.lua
                    └── plugins/
                        ├── init.lua
                        └── spec.lua
```

## Setup scripts

各 setup script は以下を共通方針にしています。

- `set -euo pipefail`（`windows-setup.ps1` は `Set-StrictMode -Version Latest` + `$ErrorActionPreference = 'Stop'`）
- 既存ファイルがあれば `*.bak.YYYYmmdd-HHMMSS` で退避してから上書き
- 同一内容ならスキップして壊れにくくする（idempotent）
- destructive な削除はしない

### Mac setup

```bash
./mac-setup.sh
```

- `settings/common/` と `settings/mac/` をホームへ反映
- 既存の Mac 側 `.zshrc` の思想（既存 Python 常用環境自動 activate 運用）を維持

必要なら実行後に:

```bash
exec zsh
```

### WSL setup (Ubuntu 24.04 想定)

```bash
./wsl-setup.sh
```

WSL は「開発特化型 CLI 環境」として、日常の Git / CLI / grep / 軽い Python / ビルド用途に最適化します。
GPU を使う重い ML ワークロード（例: torch / tensorflow を使う学習・推論）は Windows 側で実行する前提です。

実行内容:

1. `sudo apt update && sudo apt upgrade -y`
2. 基本パッケージ導入（`bat`, `fzf`, `colordiff`, `eza` を含む軽量構成）
3. **Neovim は apt 版を使わず**、公式 GitHub release tarball を `~/opt/nvim/<version>/` に導入
   - 既定: `v0.12.1`（`NEOVIM_VERSION` で変更可能）
   - `~/opt/nvim/current` シンボリックリンクを更新
   - `~/.local/bin/nvim -> ~/opt/nvim/current/bin/nvim` のシンボリックリンクを作成し、`/usr/bin/nvim` より優先されるようにする
   - setup script 内で `verify_nvim_runtime` を実行し、shim が正しい実体を指すことを確認（不一致なら終了）
   - 設定配置の**後**に `verify_interactive_nvim_runtime` を実行し、`zsh -ic` で実際の対話シェルが `~/.local/bin/nvim` を解決することを確認（不一致なら終了）
4. Rust toolchain を `rustup` で stable に更新し、`cargo install --locked tree-sitter-cli` を実行
   - `tree-sitter-cli` は **0.26.1+ 必須**（`nvim-treesitter` 互換のため）
   - `build-essential`, `clang` も同時に導入
5. `starship` 未導入時のみインストール（公式 install script）
6. `oh-my-zsh` 未導入時のみインストール
   - `KEEP_ZSHRC=yes` 必須（既定では installer が `~/.zshrc` を置き換えてしまい、このリポジトリが配置する設定が失われるため）
   - `INSTALL_OH_MY_ZSH=0` でスキップ可能
7. `settings/common/` + WSL 個別設定をホームへ反映
   - `settings/wsl/nvim/` は `~/.config/nvim/` に配置
   - `settings/common/.config/starship.toml` は `~/.config/starship.toml` に配置（Mac / Windows と共通）
8. `uv` 未導入時のみインストール
   - `curl -LsSf https://astral.sh/uv/install.sh | sh`
9. `~/.venv-tools` を `uv venv` で作成（未作成時）
10. `uv pip install` で以下を導入
    - `pandas`, `numpy`, `matplotlib`, `requests`, `rich`, `tqdm`, `ipython`
11. 可能なら default shell を `zsh` に変更


> Ubuntu 24.04 の `apt install neovim` では `0.9.x` 系になることがあり、最近の plugin（特に Treesitter / LSP 周辺）と噛み合わないため、このリポジトリでは apt 版 Neovim を採用しません。

WSL 用 `.zshrc` は以下を満たします。

- `~/.cargo/bin` / `~/opt/nvim/current/bin` / `~/.local/bin` を PATH 先頭側に追加
- `~/.local/bin/nvim` symlink を優先して tarball 版 Neovim を利用
- interactive shell 起動時に `rehash` を実行し、コマンドハッシュの古い解決結果を避ける
- `dircolors` があれば `LS_COLORS` を初期化し、`ls/grep` は `--color=auto` で表示
- `fd-find` の補助として、`fd` 未導入時のみ `fdfind -> fd` alias
- `bat` 未導入かつ `batcat` 導入済み環境では `batcat -> bat` alias
- `eza` があれば `ls` 系 alias を `eza` ベースに置き換え（`ll`, `la`, `lt`）
- `eza` が無い場合は `ls --color=auto` ベースの fallback を維持
- `~/.venv-tools/bin/activate` を interactive shell で自動 source
- `colordiff` があれば `alias diff='colordiff'`
- `~/.oh-my-zsh` があれば読み込み（無ければ何もしない）
  - **エイリアス定義より前**に source する。oh-my-zsh は独自に `ll` / `la` / `l` を定義するため、後ろに置くと eza ベースのエイリアスが上書きされる
  - `ZSH_THEME=""`（prompt は starship が担当。テーマを有効にすると競合する）
  - plugin は `git` のみ。`fzf` plugin は**使わない**（キーバインドは後述の自前ブロックが担当）
  - 起動時間は概ね 0.2〜0.3 秒増加する
- `fzf` があればキーバインドを設定（Tab 補完 / `Ctrl+R` / `Ctrl+T` / `Alt+C`）
  - fzf 0.48+ は `fzf --zsh`、Ubuntu 24.04 の 0.44 は同梱の example ファイルを source
  - `FZF_DEFAULT_COMMAND` の `fd` 解決には zsh の `$commands` を使う（`fd -> fdfind` alias は fzf が内部で使う `sh` には存在しないため）
- `starship` があれば初期化（WSL / Mac / Windows 共通 prompt）

`starship` の方針は「SFC風だが実用寄り」です。情報を盛りすぎず、`hostname / directory / git branch / python venv / 長時間コマンド時間 / prompt character` の最小構成のみ表示します。

Ubuntu では `fd` コマンドの実体が `fdfind`、`bat` コマンドの実体が `batcat` として提供される場合があるため、`.zshrc` で自然に `fd` / `bat` として使えるよう補助しています。

WSL / Windows Terminal 側の ANSI color 表示が正常であれば、色表示の体験差は主に利用コマンドによります。`cat` は plain text 表示なので Markdown の視認性は高くありません。`bat README.md` のように `bat` を使うと、README やコードを色付きで見やすく表示できます。


セットアップ後の最低限 smoke test（ローカル実機で確認）:

```bash
which nvim
nvim --version | head -n 1
tree-sitter --version
nvim --headless "+q"
```

期待値の例:

- `which nvim` が `~/.local/bin/nvim` を返す
- `nvim --version | head -n 1` が `NVIM v0.12.1`（または指定した `NEOVIM_VERSION`）を返す

追加確認（plugin/ネットワーク依存のためローカル確認推奨）:

```vim
:TSUpdate
:checkhealth nvim-treesitter
```

セットアップ後は反映のため、次のいずれかを実施してください。

- `exec zsh`
- WSL 再起動

既に開いている shell で古い解決結果（`/usr/bin/nvim` など）が残る場合は、次も実行してください。

- bash: `hash -r`
- zsh: `rehash`

### Windows setup

```powershell
powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1
```

Windows ネイティブ側（PowerShell / Windows Terminal）の設定ファイルを配置します。
`mac-setup.sh` / `wsl-setup.sh` と同じく「同一内容ならスキップ、差分があれば `*.bak.YYYYmmdd-HHMMSS` に退避してから上書き」で冪等です。

配置先:

| リポジトリ | 配置先 |
| --- | --- |
| `settings/windows/Microsoft.PowerShell_profile.ps1` | `Documents\WindowsPowerShell\`（Windows PowerShell 5.1） |
| 同上 | `Documents\PowerShell\`（PowerShell 7、`pwsh` 導入時のみ） |
| `settings/common/.config/starship.toml` | `~/.config/starship.toml`（WSL / Mac と共通の prompt 定義） |
| `settings/windows-terminal/settings.json` | Windows Terminal の `LocalState\`（`-SkipTerminal` で除外可） |

オプション:

- `-DryRun`: 書き込まずに差分だけ表示
- `-SkipTerminal`: Windows Terminal の `settings.json` に触れない
- `-ImportTerminal`: **逆方向**。実機の `settings.json` をリポジトリへ取り込み、他は何もしない（`-SkipTerminal` とは排他）

#### Windows Terminal 設定の運用

Windows Terminal は GUI で設定を変えるたびに自分で `settings.json` を書き換えます。この点だけ他の設定ファイルと性質が違うため、**実機を正とし `-ImportTerminal` で吸い上げる**方針を採ります。設定変更は GUI で行い、リポジトリは追従させます。

```powershell
# 通常運用: GUI で変えた設定をリポジトリへ（実機 -> リポジトリ）
powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1 -ImportTerminal
git diff settings/windows-terminal/settings.json   # 内容を確認してからコミット

# 新しいマシンのセットアップ時など、リポジトリを正として流し込む場合（リポジトリ -> 実機）
powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1
```

日常的に `windows-setup.ps1` を引数なしで実行すると GUI 変更が巻き戻るため、PowerShell profile や starship の更新だけを流したい場面では `-SkipTerminal` を付けます。

`-ImportTerminal` はバイト単位のコピーです。整形は Windows Terminal 側が持つため、ここで正規化しても次にアプリが書き戻した時点で差分になるだけだからです。リポジトリ側に `.bak` は作りません（git が履歴を持つため、リポジトリ内に退避ファイルが増えるとコミット対象に紛れ込みます）。

取り込み時、`source` を持つプロファイル（WSL ディストリ、Visual Studio、Azure Cloud Shell など Windows Terminal が自動生成するもの）が**新たに増えていれば警告します**。これらはマシン固有で放っておいても再生成されるため、通常はコミットしない方が無難です。

> Documents の場所は `[Environment]::GetFolderPath('MyDocuments')` で解決するため、OneDrive リダイレクト環境でも正しい位置に配置されます。

**パッケージ導入は行いません**（設定ファイル配置のみ）。`wsl-setup.sh` のような apt 相当の処理は含めず、Windows 側は winget で個別に導入する方針です。

PowerShell profile は WSL の `.zshrc` と同じ思想で、外部コマンドを**すべて存在確認してから使う**ため、何も入っていないマシンでもエラーなく読み込めます。導入済みのものだけ機能が有効になります。

- 履歴: `MaximumHistoryCount 10000` / 重複除去 / ↑↓ で前方一致検索（`.zshrc.common` の `HISTSIZE` 設定と対応）
- 補完予測: PSReadLine 2.1+ のときのみ `PredictionSource History` を有効化（5.1 同梱の 2.0.0 では自動的にスキップ）
- `eza` があれば `ll` / `la` / `lt`、無ければ `Get-ChildItem` fallback
  - Windows 版 `eza` は**パスを省略すると何も出力しない**（Linux 版のようにカレントへ fallback しない）ため、実在パスが引数に無いときは `.` を補っている
- `rg` があれば `grep`、無ければ `Select-String` ベースの fallback
- `nvim` があれば `v` と `$EDITOR`
- `git` shorthand: `gs` / `gd` / `gb` / `gl`
- `fzf` + `PSFzf` があれば `Ctrl+t` / `Ctrl+r`（zsh 側と同じキー割り当て）
- `starship` があれば prompt を初期化（WSL / Mac と同じ prompt engine）
- Chocolatey の tab 補完、Kiro の shell integration

> profile は **ASCII のみ**で記述しています。Windows PowerShell 5.1 は BOM 無しファイルを ANSI codepage として解釈するため、日本語コメントを入れると文字化けします。

## WSL Neovim starter (lightweight)

このリポジトリの Neovim 設定は、WSL toolbox 向けの **lightweight starter** です。
VSCode を置き換えるための IDE 化は意図していません。
前提バージョンは **Neovim 0.12+** です（release tarball で導入）。Ubuntu 24.04 の apt 版 `neovim` は `0.9.x` で止まることがあるため採用しません。

- エントリ: `~/.config/nvim/init.lua`
- 構成: `init.lua` + `lua/mysettings/...` + `lazy-lock.json`
- Plugin manager: `lazy.nvim`
- 初回起動時に plugin install / setup が自動で走ります

`nvim-treesitter` は `branch = "main"` を使用し、初回起動時の失敗率を下げるため parser 自動インストールは無効化しています。

初回導入後の推奨操作（1回だけ）:

```vim
:Lazy sync
:TSUpdate
:checkhealth nvim-treesitter
```

`tree-sitter --version` が `0.26.1` 未満の場合は、WSL setup を再実行するか、以下を手動で実行してください。

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup install stable
rustup default stable
cargo install --locked tree-sitter-cli
```

含まれる plugin（最小セット）:

- `lazy.nvim`
- `nvim-treesitter`（`python`, `bash`, `json`, `lua`, `markdown`）
- `nvim-lspconfig`
- `nvim-cmp`
- `cmp-nvim-lsp`
- `LuaSnip`
- `telescope.nvim`
- `plenary.nvim`
- `nvim-web-devicons`
- `lualine.nvim`

基本キーバインド:

- `<leader>ff`: Telescope でファイル検索
- `<leader>fg`: Telescope で文字列検索（live grep）
- `<leader>w`: 保存
- `<leader>q`: 終了

メモ:

- LSP / completion は「後で伸ばすための基盤」だけを用意
- 今後 `pyright` / `bashls` などを段階的に追加しやすい構成
- Mason / formatter / gitsigns などは今回は入れていません

## WSL maintenance scripts

### Doctor

```bash
bash scripts/wsl-doctor.sh
```

表示内容:

- OS / kernel 情報
- `/` のディスク使用量
- `$HOME` のサイズ
- 主要ツール有無（git, curl, zsh, uv, python/python3, pipx, rg, fd, fdfind, fzf, colordiff, jq, tree, htop, tmux, shellcheck など）
- Python 常用環境の状態（`VIRTUAL_ENV`, `which python`, `python -V`）
- 主要 Python パッケージ import check（`numpy`, `pandas`, `requests`, `rich`, `tqdm`, `matplotlib`, `IPython`）
- mount 状態
- apt cache サイズ

## Repo quality checks

このリポジトリは shell script が主な実行面なので、`shellcheck` と `shfmt` で軽く確認します。

```bash
bash scripts/lint.sh
```

Mac 側は `Brewfile` に `shellcheck` / `shfmt` を含めています。WSL 側は `wsl-setup.sh` で導入します。

### Maintenance (安全側)

```bash
bash scripts/wsl-maintenance.sh
```

実行内容:

- `sudo apt update`
- `sudo apt upgrade -y`
- `sudo apt autoremove -y`
- `sudo apt autoclean -y`

### Cleanup (強めの掃除)

```bash
bash scripts/wsl-cleanup.sh
```

`cleanup` は `maintenance` より強めの掃除です。
容量削減を重視して以下を実行します。

- `sudo apt autoremove -y`
- `sudo apt clean`
- `pip cache purge`（存在時）
- `uv cache clean`（存在時）
- `docker system prune -f`（docker 存在時）

失敗しても致命傷になりにくいよう、必要箇所は `|| true` で継続します。

## ECC / Codex baseline

2026-09-14: [Local / MySettingsの棚卸し](inventory/2026-09-14-astra-stocktake.md)と、
[日常モデル・Astraの切替設定案](inventory/proposals/model-switch/README.md)を追加しました。
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
- `domain-modeling`: 用語のブレを潰して `CONTEXT.md`（glossary）と `docs/adr/`（ADR）に落とす。format は同梱の `CONTEXT-FORMAT.md` / `ADR-FORMAT.md`

この 3 つはローカルの全プロジェクトから参照できるよう、repo に加えて `~/.codex/skills/`（Codex CLI）と `~/.claude/skills/`（Claude Code）の両方にミラーしています。Claude Code は `~/.codex/skills` を読まないため、user-level skill を両 runtime で使う場合は両方へ配置する方針です。

### Tasks.md の運用を skill 化（task-queue-loop）

ローカルの 11 リポジトリ（`steering-health-intelligence`, `rustbound`, `black-stela`, `cdda-musou`, `ecliptica`, `virtual-ecu-peripheral-harness`, `watchless-notes`, `AutoRogue`, `codex-game-test` ほか）で実際に動いている `Tasks.md` 運用を収集し、`task-queue-loop` として 1 本にまとめています。「Tasks.md は todo list ではなく loop の状態で、1 周 = 1 タスクを未着手から緑の Gate + commit まで運ぶ」という形に整理したものです。

- `SKILL.md`: 1 周の手順（入口で キュー + 憲章 を読む → 上から 1 件 → Gate を先に書く → 赤いことを確かめる → 実装と自己検証 → commit → 別視点の監査 → 同じ編集で整備）、状態記号、完了の 4 条件、ファイルの不変条件（200 行上限・置き場所の地図・次の ID の宣言）
- `references/gates.md`: 落とせる Gate の書き方。曖昧語を数値とキー名へ落とす、修正前に赤を確認する、機械判定が書けない場合の扱い
- `references/gate-audit-loop.md`: **別視点エージェントによる Gate 監査ループ**。差分ではなく Gate を攻める（差分を戻して赤くなるか、挙動を壊して赤くなるか、assertion が実際に走ったか）。判定は `GATE_VALID` / `GATE_BROKEN` / `EVIDENCE_MISSING` の固定書式で返し、refactoring 案は **Gate 付きの行**としてキューへ積む。自動化は subagent への dispatch と、キューファイルへの `PostToolUse` hook（監査記録の無い `[x]` を拒否）の 2 段
- `references/collected-practice.md`: どの規則をどのリポジトリから取ったかの対応表と、規則が答えている実際の失敗例
- `templates/`: `Tasks.md`（READ FIRST ヘッダ入り）、`CHARTER.md`、`Tasks-archive.md`、`gate-auditor.md`（`.claude/agents/` へ置く監査 subagent 定義）

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

## Future extension policy

- 共通化できる設定は `settings/common/` に集約
- host 固有設定は `settings/mac/` と `settings/wsl/` に閉じる
- 必要に応じて `settings/linux/` などを追加しやすい構成を維持
