#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
VENV_TOOLS="$HOME/.venv-tools"

PACKAGES=(
  build-essential
  pkg-config
  git
  curl
  wget
  zip
  unzip
  tar
  zsh
  nano
  vim
  ripgrep
  fd-find
  jq
  tree
  htop
  btop
  tmux
  ca-certificates
  gnupg
  lsb-release
  shellcheck
  python3
  python3-pip
  pipx
)

PYTHON_PACKAGES=(
  pandas
  numpy
  matplotlib
  requests
  rich
  tqdm
  ipython
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
  [[ -d "$base" ]] || return 0

  while IFS= read -r rel; do
    backup_and_copy "$base/$rel" "$HOME/$rel"
  done < <(cd "$base" && find . -type f | sed 's#^./##')
}

is_wsl() {
  grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null
}

if ! is_wsl; then
  echo "Warning: WSL environment was not detected from /proc/version."
fi

echo "Updating apt cache..."
sudo apt update
sudo apt upgrade -y

echo "Installing base packages..."
sudo apt install -y "${PACKAGES[@]}"

echo "Applying common settings..."
deploy_tree "$ROOT_DIR/settings/common"

echo "Applying WSL settings..."
deploy_tree "$ROOT_DIR/settings/wsl"

export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv already installed."
fi

if [[ ! -d "$VENV_TOOLS" ]]; then
  echo "Creating toolbox venv: $VENV_TOOLS"
  uv venv "$VENV_TOOLS"
else
  echo "Toolbox venv already exists: $VENV_TOOLS"
fi

echo "Installing toolbox Python packages..."
uv pip install --python "$VENV_TOOLS/bin/python" "${PYTHON_PACKAGES[@]}"

if command -v zsh >/dev/null 2>&1; then
  ZSH_PATH="$(command -v zsh)"
  CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    echo "Setting default shell to zsh..."
    chsh -s "$ZSH_PATH" "$USER" || echo "Could not change shell automatically. Run manually: chsh -s $ZSH_PATH"
  else
    echo "Default shell is already zsh."
  fi
fi

echo "Done. Run 'exec zsh' (or restart WSL) to apply shell changes."
