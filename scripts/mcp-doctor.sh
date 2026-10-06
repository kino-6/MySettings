#!/usr/bin/env bash
# MCP pin doctor.
#
# Why pins exist: `npx -y <pkg>` and `<pkg>@latest` fetch and execute whatever
# npm serves at launch, with no review step. A trusted package name plus a new
# release is enough to run arbitrary code in the agent's environment. So
# .codex/config.toml pins exact versions, and updating is a deliberate act.
#
# This script does not update anything. It reports how stale each pin is, so a
# human (or an agent, as a suggestion) can decide. Only read-only npm metadata
# is fetched; nothing is installed.
#
#   bash scripts/mcp-doctor.sh            report
#   bash scripts/mcp-doctor.sh --check    exit 1 if any pin is past the threshold
#
# Threshold: a pin is STALE once the latest release is more than
# MCP_STALE_DAYS (default 120) days newer than the pinned release.
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  mcp-doctor.sh [--check]

Compares the versions pinned in .codex/config.toml against the npm registry.
Reports only; never installs or edits. --check exits 1 when a pin is stale.
USAGE
}

mode="report"
if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
elif [[ $# -eq 1 ]]; then
  case "$1" in
    --check) mode="check" ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

config=".codex/config.toml"
if [[ ! -f "$config" ]]; then
  echo "Missing $config" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found; cannot query the registry." >&2
  exit 1
fi

stale_days="${MCP_STALE_DAYS:-120}"

# Pinned entries, from the active (non-commented) args lines only.
# "@scope/name@version" and "name@version" both reduce to pkg + version.
pinned="$(
  grep -E '^args = \["-y"' "$config" \
    | grep -oE '"(@[a-z0-9._-]+/)?[a-z0-9._-]+@[0-9][0-9A-Za-z.+-]*"' \
    | tr -d '"' \
    | sort -u
)"

if [[ -z "$pinned" ]]; then
  echo "No pinned MCP packages found in $config."
  echo "Every npx entry is unpinned - that is the condition this script exists to prevent."
  exit 1
fi

epoch_of() { # ISO8601 -> epoch seconds, portable between BSD and GNU date
  local iso="${1%%T*}"
  if date -j -f "%Y-%m-%d" "$iso" "+%s" 2>/dev/null; then
    return 0
  fi
  date -d "$iso" "+%s" 2>/dev/null || echo 0
}

now="$(date +%s)"
stale=0
unknown=0

printf "%-52s %-13s %-13s %s\n" "PACKAGE" "PINNED" "LATEST" "STATUS"

while IFS= read -r entry; do
  [[ -n "$entry" ]] || continue
  # split on the LAST @ so scoped names survive
  pkg="${entry%@*}"
  ver="${entry##*@}"

  latest="$(npm view "$pkg" version 2>/dev/null || true)"
  if [[ -z "$latest" ]]; then
    printf "%-52s %-13s %-13s %s\n" "$pkg" "$ver" "-" "[?]    registry lookup failed"
    unknown=1
    continue
  fi

  if [[ "$latest" == "$ver" ]]; then
    printf "%-52s %-13s %-13s %s\n" "$pkg" "$ver" "$latest" "[OK]   current"
    continue
  fi

  # Per-version publish time. `npm view <pkg>@<ver> time.modified` is the WRONG
  # field - it returns the package's last-modified time regardless of the
  # version asked for, so every gap comes out as 0 days.
  pinned_time="$(npm view "$pkg" "time[$ver]" 2>/dev/null || true)"
  latest_time="$(npm view "$pkg" "time[$latest]" 2>/dev/null || true)"
  if [[ -z "$pinned_time" || -z "$latest_time" ]]; then
    printf "%-52s %-13s %-13s %s\n" "$pkg" "$ver" "$latest" "[!]    behind (age unknown)"
    stale=1
    continue
  fi

  pe="$(epoch_of "$pinned_time")"
  le="$(epoch_of "$latest_time")"
  gap_days=$(((le - pe) / 86400))
  age_days=$(((now - pe) / 86400))

  if ((gap_days > stale_days)); then
    printf "%-52s %-13s %-13s %s\n" "$pkg" "$ver" "$latest" \
      "[STALE] latest is ${gap_days}d newer (pin is ${age_days}d old)"
    stale=1
  else
    printf "%-52s %-13s %-13s %s\n" "$pkg" "$ver" "$latest" \
      "[behind] latest is ${gap_days}d newer"
  fi
done <<<"$pinned"

echo
echo "Threshold: STALE when the latest release is more than ${stale_days}d newer than the pin (MCP_STALE_DAYS)."

if [[ "$mode" == "check" ]]; then
  if ((stale == 1)); then
    echo "At least one pin is stale. Read the upstream changelog, then edit the pin in $config by hand."
    exit 1
  fi
  if ((unknown == 1)); then
    echo "Some lookups failed; re-run when the registry is reachable."
    exit 1
  fi
  echo "All pins within threshold."
fi

exit 0
