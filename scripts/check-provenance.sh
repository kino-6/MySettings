#!/usr/bin/env bash
# Verify vendored skills against the upstream revision recorded in provenance.json.
#
# Why this exists: vendoring copies LICENSE but used to record nothing about
# *which* revision the copy came from, so upstream could move and the local copy
# would quietly go stale. The first run found exactly that - mattpocock's
# domain-modeling had renamed CONTEXT.md to GLOSSARY.md and the local copy still
# taught the old name.
#
# Thin wrapper; the work is in scripts/check_provenance.py. Only read-only
# raw.githubusercontent.com fetches are made and nothing is written.
#
#   bash scripts/check-provenance.sh          report
#   bash scripts/check-provenance.sh --check  exit 1 on any drift
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  check-provenance.sh [--check]

Compares each .agents/skills/*/provenance.json against its upstream revision.
Reports only. --check exits 1 when a file drifted, was edited locally, or its
recorded upstream path no longer exists.
USAGE
}

mode=""
if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
elif [[ $# -eq 1 ]]; then
  case "$1" in
    --check) mode="--check" ;;
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

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; cannot verify provenance." >&2
  exit 1
fi

exec python3 scripts/check_provenance.py ${mode:+"$mode"}
