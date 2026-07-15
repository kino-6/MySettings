#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

shell_files=(
  "$ROOT_DIR/mac-setup.sh"
  "$ROOT_DIR/wsl-setup.sh"
)

while IFS= read -r file; do
  shell_files+=("$file")
done < <(find "$ROOT_DIR/scripts" -type f -name '*.sh' | sort)

missing=0
for tool in shellcheck shfmt; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf '[MISS] %s is required for repo linting.\n' "$tool" >&2
    missing=1
  fi
done

if [[ "$missing" == "1" ]]; then
  printf 'Install with Homebrew on macOS or rerun wsl-setup.sh on WSL.\n' >&2
  exit 127
fi

printf 'Running shellcheck...\n'
shellcheck "${shell_files[@]}"

printf 'Checking shell formatting with shfmt...\n'
shfmt -d -i 2 -ci -bn "${shell_files[@]}"

printf 'Lint checks passed.\n'
