#!/usr/bin/env bash
# The gate before anything leaves this machine.
#
# Offline checks block. Network checks and inventory staleness only report:
# bumping an MCP pin or re-vendoring a skill is the user's decision, and a
# freshly installed tool is not a reason to refuse a push.
#
#   bash scripts/check.sh            everything
#   bash scripts/check.sh --offline  skip the network checks
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

offline=0
case "${1:-}" in
  "") ;;
  --offline) offline=1 ;;
  *)
    echo "usage: check.sh [--offline]" >&2
    exit 2
    ;;
esac

fail=0

# name, mode (block|note), command...
step() {
  local name="$1" mode="$2" out
  shift 2
  printf '%-16s ' "$name"
  if out="$("$@" 2>&1)"; then
    echo "ok"
    return
  fi
  if [[ "$mode" == "block" ]]; then
    echo "FAIL"
    fail=1
  else
    echo "note"
  fi
  printf '%s\n' "$out" | tail -12 | sed 's/^/    /'
}

step lint block bash scripts/lint.sh
step preflight block python3 .agents/skills/repo-preflight/scripts/preflight.py
step skill-inventory block bash .agents/skills/skill-use-manager/scripts/update-inventory.sh --check
step tool-inventory note bash scripts/inventory.sh --check
if ((offline == 0)); then
  step mcp-pins note bash scripts/mcp-doctor.sh --check
  step provenance note bash scripts/check-provenance.sh --check
fi

if ((fail)); then
  echo "CHECK FAIL"
  exit 1
fi
echo "CHECK OK"
