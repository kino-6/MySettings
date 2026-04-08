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
for tool in git curl zsh uv python3 pipx rg fd fdfind jq tree htop tmux shellcheck; do
  print_tool_status "$tool"
done

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
