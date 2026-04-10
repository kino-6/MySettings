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
├── scripts/
│   ├── wsl-doctor.sh
│   ├── wsl-maintenance.sh
│   └── wsl-cleanup.sh
└── settings/
    ├── common/
    │   ├── .vimrc
    │   └── .zshrc.common
    ├── mac/
    │   ├── .zshrc
    │   ├── .nanorc
    │   └── ghostty.ini
    └── wsl/
        ├── .zshrc
        ├── .nanorc
        ├── .config/
        │   └── starship.toml
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

両 setup script は以下を共通方針にしています。

- `set -euo pipefail`
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
   - `~/opt/nvim/current` シンボリックリンクを更新し、`~/.zshrc` から PATH を通す
4. `starship` 未導入時のみインストール（公式 install script）
5. `settings/common/` + WSL 個別設定をホームへ反映
   - `settings/wsl/nvim/` は `~/.config/nvim/` に配置
   - `settings/wsl/.config/starship.toml` は `~/.config/starship.toml` に配置
6. `uv` 未導入時のみインストール
   - `curl -LsSf https://astral.sh/uv/install.sh | sh`
7. `~/.venv-tools` を `uv venv` で作成（未作成時）
8. `uv pip install` で以下を導入
   - `pandas`, `numpy`, `matplotlib`, `requests`, `rich`, `tqdm`, `ipython`
9. 可能なら default shell を `zsh` に変更


> Ubuntu 24.04 の `apt install neovim` では `0.9.x` 系になることがあり、最近の plugin（特に Treesitter / LSP 周辺）と噛み合わないため、このリポジトリでは apt 版 Neovim を採用しません。

WSL 用 `.zshrc` は以下を満たします。

- `~/.local/bin` を PATH に追加
- `dircolors` があれば `LS_COLORS` を初期化し、`ls/grep` は `--color=auto` で表示
- `fd-find` の補助として、`fd` 未導入時のみ `fdfind -> fd` alias
- `bat` 未導入かつ `batcat` 導入済み環境では `batcat -> bat` alias
- `eza` があれば `ls` 系 alias を `eza` ベースに置き換え（`ll`, `la`, `lt`）
- `eza` が無い場合は `ls --color=auto` ベースの fallback を維持
- `~/.venv-tools/bin/activate` を interactive shell で自動 source
- `colordiff` があれば `alias diff='colordiff'`
- `starship` があれば初期化（WSL 向け軽量 prompt）

`starship` の方針は「SFC風だが実用寄り」です。情報を盛りすぎず、`hostname / directory / git branch / python venv / 長時間コマンド時間 / prompt character` の最小構成のみ表示します。

Ubuntu では `fd` コマンドの実体が `fdfind`、`bat` コマンドの実体が `batcat` として提供される場合があるため、`.zshrc` で自然に `fd` / `bat` として使えるよう補助しています。

WSL / Windows Terminal 側の ANSI color 表示が正常であれば、色表示の体験差は主に利用コマンドによります。`cat` は plain text 表示なので Markdown の視認性は高くありません。`bat README.md` のように `bat` を使うと、README やコードを色付きで見やすく表示できます。

セットアップ後は反映のため、次のいずれかを実施してください。

- `exec zsh`
- WSL 再起動

## WSL Neovim starter (lightweight)

このリポジトリの Neovim 設定は、WSL toolbox 向けの **lightweight starter** です。
VSCode を置き換えるための IDE 化は意図していません。
前提バージョンは **Neovim 0.12+** です（release tarball で導入）。

- エントリ: `~/.config/nvim/init.lua`
- 構成: `init.lua` + `lua/mysettings/...` + `lazy-lock.json`
- Plugin manager: `lazy.nvim`
- 初回起動時に plugin install / setup が自動で走ります

`nvim-treesitter` を初回導入/更新した後は、互換性のため以下を順に実行してください。

```vim
:Lazy update nvim-treesitter
:TSUninstall all
:TSUpdate
:checkhealth nvim-treesitter
```


初回導入後の推奨操作（1回だけ）:

```vim
:Lazy sync
:TSUpdate
:checkhealth
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

## Future extension policy

- 共通化できる設定は `settings/common/` に集約
- host 固有設定は `settings/mac/` と `settings/wsl/` に閉じる
- 必要に応じて `settings/linux/` などを追加しやすい構成を維持
