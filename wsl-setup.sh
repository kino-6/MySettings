#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

PACKAGES=(
  build-essential
  pkg-config
  git
  curl
  zip
  unzip
  zsh
  nano
  vim
  ripgrep
  fd-find
  jq
  tree
  htop
  ca-certificates
  gnupg
)

backup_and_copy() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      echo "skip (same): $dst"
      return
    fi

    local backup="${dst}.bak.${TIMESTAMP}"
    echo "backup: $dst -> $backup"
    mv "$dst" "$backup"
  fi

  echo "copy: $src -> $dst"
  cp "$src" "$dst"
}

deploy_tree() {
  local base="$1"
  while IFS= read -r rel; do
    backup_and_copy "$base/$rel" "$HOME/$rel"
  done < <(cd "$base" && find . -type f | sed 's#^./##')
}

echo "Updating apt cache..."
sudo apt update
sudo apt upgrade -y

echo "Installing base packages..."
sudo apt install -y "${PACKAGES[@]}"

echo "Applying common settings..."
deploy_tree "$ROOT_DIR/settings/common"

echo "Applying WSL settings..."
deploy_tree "$ROOT_DIR/settings/wsl"

if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv already installed."
fi

if command -v zsh >/dev/null 2>&1; then
  ZSH_PATH="$(command -v zsh)"
  if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    echo "Setting default shell to zsh..."
    chsh -s "$ZSH_PATH" "$USER" || echo "Could not change shell automatically. Run manually: chsh -s $ZSH_PATH"
  fi
fi

echo "Done."
