#!/usr/bin/env bash
# Regenerate inventory/*.txt from the tools actually installed on this machine.
#
# Why: these used to be pasted by hand, so they went stale silently, and raw tool
# output leaked the local account name into this public repo (found by
# repo-preflight, 2026-10-16). Every line now passes through redaction, so the
# leak cannot come back with the next regeneration.
#
# A tool that is not installed here leaves its file untouched - running this on
# a machine without brew must not blank out the Mac inventory.
#
#   bash scripts/inventory.sh          rewrite inventory/*.txt
#   bash scripts/inventory.sh --check  report which files are stale; changes nothing
set -euo pipefail

mode="write"
case "${1:-}" in
  "") ;;
  --check) mode="check" ;;
  -h | --help)
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "usage: inventory.sh [--check]" >&2
    exit 2
    ;;
esac

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root/inventory"

# Replace this machine's home directory with ~ so no account name is written.
redact() {
  local home_re
  home_re="$(printf '%s' "$HOME" | sed 's/[][\.*^$/]/\\&/g')"
  sed "s#${home_re}#~#g"
}

# file|tool|command
targets=(
  "brew-leaves.txt|brew|brew leaves"
  "brew-casks.txt|brew|brew list --cask"
  "npm-global.txt|npm|npm ls -g --depth=0"
  "pipx-list.txt|pipx|pipx list"
  "uv-tool-list.txt|uv|uv tool list"
  "rustup-show.txt|rustup|rustup show"
)

stale=0
for t in "${targets[@]}"; do
  IFS='|' read -r file tool cmd <<<"$t"
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf '%-20s skip  (%s not installed here; file left as is)\n' "$file" "$tool"
    continue
  fi
  old="$(cat "$file" 2>/dev/null || true)"
  # A tool that exists but fails must never blank its file. Capture the exit
  # status separately - `cmd | redact || true` would hide the failure.
  # shellcheck disable=SC2086 # cmd is a fixed command line from the table above
  if ! raw="$($cmd 2>/dev/null)"; then
    printf '%-20s FAILED (%s exited non-zero; file left as is)\n' "$file" "$tool"
    stale=1
    continue
  fi
  if [[ -z "$raw" && -n "$old" ]]; then
    printf '%-20s EMPTY  (%s printed nothing; file left as is)\n' "$file" "$tool"
    stale=1
    continue
  fi
  new="$(printf '%s' "$raw" | redact)"
  if [[ "$new" == "$old" ]]; then
    printf '%-20s current\n' "$file"
    continue
  fi
  if [[ "$mode" == "check" ]]; then
    printf '%-20s STALE\n' "$file"
    stale=1
  else
    printf '%s\n' "$new" >"$file"
    printf '%-20s updated\n' "$file"
  fi
done

if [[ "$mode" == "check" && "$stale" -eq 1 ]]; then
  echo "Run: bash scripts/inventory.sh"
  exit 1
fi
