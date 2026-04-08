#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

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

echo "Applying common settings..."
deploy_tree "$ROOT_DIR/settings/common"

echo "Applying mac settings..."
deploy_tree "$ROOT_DIR/settings/mac"

echo "Done."
