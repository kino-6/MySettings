#!/usr/bin/env bash
set -euo pipefail

section() {
  echo
  echo "=== $1 ==="
}

print_tool_status() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    printf "[OK]   %-12s %s\n" "$tool" "$(command -v "$tool")"
  else
    printf "[MISS] %-12s -\n" "$tool"
  fi
}

print_kv() {
  local key="$1"
  local value="$2"
  printf "%-14s %s\n" "$key" "$value"
}

section "OS"
if [[ -f /etc/os-release ]]; then
  grep -E '^(PRETTY_NAME|NAME|VERSION)=' /etc/os-release || true
fi

section "Kernel"
uname -a

section "Disk usage (/)"
df -h /

section "Home size"
du -sh "$HOME" 2>/dev/null || echo "Could not read home size"

section "Tool check"
for tool in git curl zsh uv python python3 pipx rg fd fdfind fzf colordiff jq tree htop tmux shellcheck; do
  print_tool_status "$tool"
done

section "Python environment"
print_kv "VIRTUAL_ENV" "${VIRTUAL_ENV:-<empty>}"

PY_CMD=""
if command -v python >/dev/null 2>&1; then
  PY_CMD="python"
elif command -v python3 >/dev/null 2>&1; then
  PY_CMD="python3"
fi

if [[ -n "$PY_CMD" ]]; then
  print_kv "python cmd" "$(command -v "$PY_CMD")"
  print_kv "python -V" "$($PY_CMD -V 2>&1)"

  echo
  echo "Import checks (non-fatal):"
  for pkg in numpy pandas requests rich tqdm matplotlib IPython; do
    if "$PY_CMD" -c "import $pkg" >/dev/null 2>&1; then
      printf "[OK]   %s\n" "$pkg"
    else
      printf "[MISS] %s\n" "$pkg"
    fi
  done
else
  print_kv "python cmd" "not found"
  print_kv "python -V" "unavailable"
  echo
  echo "Import checks skipped: python command not found"
fi

section "Mounts"
mount | head -n 40

section "APT cache"
if [[ -d /var/cache/apt/archives ]]; then
  du -sh /var/cache/apt/archives 2>/dev/null || true
else
  echo "/var/cache/apt/archives not found"
fi

section "Done"
echo "wsl-doctor completed."
