# MySettings

Mac / WSL / Windows の dotfiles と setup script、そして agent（Claude Code / Codex）で使う skill と道具を管理するリポジトリです。
最初は設定だけでしたが、後から skill が必要になり、skill library（約 100 本）と検査用の script が加わっています。

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

### push の前に

```bash
bash scripts/check.sh          # 外に出す前の関門（--offline で通信する検査を省略）
bash scripts/push.sh           # check を通してから push
bash scripts/push.sh --merge   # branch を main へ --no-ff で merge → push → branch 削除
```

`check.sh` は**オフラインの検査で止め、通信する検査は表示だけ**します。止めるのは lint・朝の 1 枚の試験・repo-preflight（秘密情報）・skill inventory・skill の写しのずれ（`~/.claude/skills` と `~/.codex/skills`）。表示だけなのは MCP の版・provenance・ツール一覧の古さ（版を上げるか、取り直すかは人の判断）。

`push.sh` は**検査した内容と push する内容を一致させる**ために、未 commit の変更があるとき・origin/main が先に進んでいるとき・`--merge` で branch が main を含んでいないときに止まります。

### ツール一覧

```bash
bash scripts/inventory.sh          # inventory/*.txt を実物のツールから作り直す
bash scripts/inventory.sh --check  # 古いものを報告するだけ
```

`$HOME` は `~` に伏字化して書きます（以前、ツール出力をそのまま貼ってアカウント名が public に出ていた）。このマシンに無いツールのファイルには触れず、ツールが失敗・空出力のときも上書きしません。

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

## Agent tooling

agent（Claude Code / Codex）まわりの道具と方針は [docs/agent-tooling.md](docs/agent-tooling.md) にまとめています。

- ECC / Codex baseline と、取り込んだ skill library（`.agents/skills/`）
- `task-queue-loop` / `progress-contract` / `repo-preflight` などの自作 skill
- MCP の版固定、取り込み元の記録（provenance）、公開前チェック

### 夜間の AI 作業を朝に見る

```bash
python3 .agents/skills/morning-board/scripts/board.py         # ~/work の全 repo。既定は昨日 18:00 以降
python3 .agents/skills/morning-board/scripts/board.py --since 2026-10-30T22:00
claude agents                                                 # Claude Code 組み込みの session 一覧（Agent View）
```

repo ごとに、動いている Claude Code の session、境界以降の commit、`[x]` になった行、
Tasks.md の `[~]`（判断待ち）・`[!]`（止まっている）・`[-]`（進行中）を出す。読むだけで、何も書き換えない。

## Future extension policy

- 共通化できる設定は `settings/common/` に集約
- host 固有設定は `settings/mac/` と `settings/wsl/` に閉じる
- 必要に応じて `settings/linux/` などを追加しやすい構成を維持
