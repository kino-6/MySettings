# MySettings

Mac と WSL の dotfiles / setup を整理し、再構築しやすく保つためのリポジトリです。

- **Mac**: 既存の常用運用を維持する便利ツール環境
- **WSL**: 開発特化型 CLI 環境（toolbox / Assist 用）
- **Python 方針**: WSL でも `uv` ベースの常用補助環境を使い、使い捨てスクリプトをすぐ書ける状態にする
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
        └── .nanorc
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
2. 基本パッケージ導入（`fzf`, `colordiff` を含む軽量構成）
3. `settings/common/` + `settings/wsl/` をホームへ反映
4. `uv` 未導入時のみインストール
   - `curl -LsSf https://astral.sh/uv/install.sh | sh`
5. `~/.venv-tools` を `uv venv` で作成（未作成時）
6. `uv pip install` で以下を導入
   - `pandas`, `numpy`, `matplotlib`, `requests`, `rich`, `tqdm`, `ipython`
7. 可能なら default shell を `zsh` に変更

WSL 用 `.zshrc` は以下を満たします。

- `~/.local/bin` を PATH に追加
- `fd-find` の補助として、`fd` 未導入時のみ `fdfind -> fd` alias
- `~/.venv-tools/bin/activate` を interactive shell で自動 source
- `colordiff` があれば `alias diff='colordiff'`
- `starship` があれば初期化

Ubuntu では `fd` コマンドの実体が `fdfind` パッケージ名で提供されるため、`.zshrc` で自然に `fd` として使えるように補助しています。

セットアップ後は反映のため、次のいずれかを実施してください。

- `exec zsh`
- WSL 再起動

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
