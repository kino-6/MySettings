#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
VENV_TOOLS="$HOME/.venv-tools"
NEOVIM_VERSION="${NEOVIM_VERSION:-v0.12.1}"
NEOVIM_INSTALL_ROOT="$HOME/opt/nvim"
NEOVIM_TARBALL_NAME="nvim-linux-x86_64"
TREE_SITTER_MIN_VERSION="0.26.1"

PACKAGES=(
  build-essential
  clang
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
  bat
  fzf
  colordiff
  eza
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

deploy_tree_to() {
  local base="$1"
  local dst_root="$2"
  [[ -d "$base" ]] || return 0

  while IFS= read -r rel; do
    backup_and_copy "$base/$rel" "$dst_root/$rel"
  done < <(cd "$base" && find . -type f | sed 's#^./##')
}

version_ge() {
  local lhs="$1"
  local rhs="$2"
  [[ "$(printf '%s\n' "$rhs" "$lhs" | sort -V | tail -n1)" == "$lhs" ]]
}

install_neovim_release() {
  local version="$1"
  local install_root="$2"
  local version_dir="$install_root/$version"
  local current_link="$install_root/current"
  local nvim_bin="$version_dir/$NEOVIM_TARBALL_NAME/bin/nvim"

  mkdir -p "$install_root"

  if [[ -x "$nvim_bin" ]]; then
    echo "Neovim $version already installed: $nvim_bin"
  else
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local tarball="$tmp_dir/${NEOVIM_TARBALL_NAME}.tar.gz"
    local url="https://github.com/neovim/neovim/releases/download/${version}/${NEOVIM_TARBALL_NAME}.tar.gz"

    echo "Installing Neovim $version from release tarball..."
    echo "download: $url"
    curl -fL "$url" -o "$tarball"

    tar -xzf "$tarball" -C "$tmp_dir"

    rm -rf "$version_dir"
    mkdir -p "$version_dir"
    mv "$tmp_dir/$NEOVIM_TARBALL_NAME" "$version_dir/$NEOVIM_TARBALL_NAME"

    rm -rf "$tmp_dir"
    echo "Installed: $nvim_bin"
  fi

  ln -sfn "$version_dir/$NEOVIM_TARBALL_NAME" "$current_link"
  echo "Updated symlink: $current_link -> $version_dir/$NEOVIM_TARBALL_NAME"
}

install_nvim_shim() {
  local current_nvim="$NEOVIM_INSTALL_ROOT/current/bin/nvim"
  local shim_dir="$HOME/.local/bin"
  local shim="$shim_dir/nvim"

  mkdir -p "$shim_dir"

  if [[ ! -x "$current_nvim" ]]; then
    echo "ERROR: expected Neovim binary does not exist: $current_nvim"
    return 1
  fi

  ln -sfn "$current_nvim" "$shim"
  echo "Updated symlink: $shim -> $current_nvim"
}

install_or_update_rustup() {
  export PATH="$HOME/.cargo/bin:$PATH"

  if ! command -v rustup >/dev/null 2>&1; then
    echo "Installing rustup (stable toolchain)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  else
    echo "rustup already installed."
  fi

  export PATH="$HOME/.cargo/bin:$PATH"
  rustup install stable
  rustup default stable
}

install_tree_sitter_cli() {
  export PATH="$HOME/.cargo/bin:$PATH"

  local current_version=""
  if command -v tree-sitter >/dev/null 2>&1; then
    current_version="$(tree-sitter --version | awk '{print $2}')"
  fi

  if [[ -n "$current_version" ]] && version_ge "$current_version" "$TREE_SITTER_MIN_VERSION"; then
    echo "tree-sitter CLI already satisfies requirement: $current_version >= $TREE_SITTER_MIN_VERSION"
    return
  fi

  echo "Installing/upgrading tree-sitter CLI with cargo --locked..."
  cargo install --locked tree-sitter-cli

  local installed_version
  installed_version="$(tree-sitter --version | awk '{print $2}')"
  echo "tree-sitter CLI installed: $installed_version"
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

install_neovim_release "$NEOVIM_VERSION" "$NEOVIM_INSTALL_ROOT"
install_nvim_shim

install_or_update_rustup
install_tree_sitter_cli

if ! command -v starship >/dev/null 2>&1; then
  echo "Installing starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
else
  echo "starship already installed."
fi

echo "Applying common settings..."
deploy_tree_to "$ROOT_DIR/settings/common" "$HOME"

echo "Applying WSL settings..."
backup_and_copy "$ROOT_DIR/settings/wsl/.zshrc" "$HOME/.zshrc"
backup_and_copy "$ROOT_DIR/settings/wsl/.nanorc" "$HOME/.nanorc"
backup_and_copy "$ROOT_DIR/settings/wsl/.config/starship.toml" "$HOME/.config/starship.toml"
deploy_tree_to "$ROOT_DIR/settings/wsl/nvim" "$HOME/.config/nvim"

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/opt/nvim/current/bin:$PATH"
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

echo "Smoke checks:"
command -v nvim || true
nvim --version | head -n 1 || true
command -v tree-sitter || true
tree-sitter --version || true

echo "Done. Run 'exec zsh' (or restart WSL) to apply shell changes."
