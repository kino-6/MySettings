# MySettings

Mac と WSL の dotfiles / setup を分離して管理するためのリポジトリです。

## Philosophy

- **Mac**: 常用ユーティリティ環境（既存運用を維持、Python 常用）
- **WSL**: disposable な Assist / 工具箱（Git, shell, CLI, build, 軽い Python 補助）

## Repository Layout

```text
.
├── mac-setup.sh
├── wsl-setup.sh
├── README.md
└── settings
    ├── common
    │   ├── .vimrc
    │   └── .zshrc.common
    ├── mac
    │   ├── .zshrc
    │   ├── .nanorc
    │   └── ghostty.ini
    └── wsl
        ├── .zshrc
        └── .nanorc
```

## Mac Setup

```bash
./mac-setup.sh
```

- `settings/common/` と `settings/mac/` をホームディレクトリへ反映します。
- 既存ファイルがあり内容が異なる場合は、`<file>.bak.YYYYmmdd-HHMMSS` でバックアップしてから上書きします。
- `~/py3_11_6/bin/activate` を interactive zsh で自動 activate する運用を維持しています。

## WSL Setup (Ubuntu 24.04)

```bash
./wsl-setup.sh
```

実行内容:

1. `apt update && apt upgrade -y`
2. 基本パッケージ導入（build-essential, git, zsh, ripgrep, fd-find など）
3. `settings/common/` と `settings/wsl/` の dotfiles 反映
4. `uv` 未導入時のみインストール
5. 可能なら default shell を zsh に変更

> WSL 側は Python 仮想環境の自動 activate を行いません。

## Backup Policy

- 既存ファイルは削除せず、必ず timestamp 付きバックアップを作成します。
- 同一内容の場合はコピーせず `skip (same)` と表示します。

## Future Extensions

- `settings/common/` に共通設定を追加し、host 固有設定は `settings/mac` / `settings/wsl` に分離します。
- 必要になれば `settings/linux` などを追加して拡張できます。
