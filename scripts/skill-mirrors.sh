#!/usr/bin/env bash
# The user-level skill roots hold copies of .agents/skills/<name>. A copy left
# behind after the repo changes, or edited in place from another repository's
# session, drifts silently. --check lists every mirrored skill whose content
# differs; --write copies the repo version over it, keeping a .bak of what it
# replaces. A root that does not exist on this host is skipped.
#   bash scripts/skill-mirrors.sh --check | --write
set -euo pipefail

mode="${1:-}"
[[ "$mode" == "--check" || "$mode" == "--write" ]] || {
  echo "usage: $0 --check | --write" >&2
  exit 2
}
cd "$(git rev-parse --show-toplevel)"
roots="${SKILL_MIRROR_ROOTS:-$HOME/.claude/skills:${CODEX_HOME:-$HOME/.codex}/skills}"
excl=(-x __pycache__ -x .DS_Store -x '*.bak.*')
stamp="$(date +%Y%m%d-%H%M%S)"
drift=0

IFS=: read -ra dirs <<<"$roots"
for root in "${dirs[@]}"; do
  [[ -d "$root" ]] || continue
  for mirror in "$root"/*/; do
    name="$(basename "$mirror")"
    src=".agents/skills/$name"
    [[ -d "$src" ]] || continue
    if ! out="$(command diff -rq "${excl[@]}" "$src" "$mirror" 2>&1)"; then
      if [[ "$mode" == "--write" ]]; then
        rsync -a --delete --exclude __pycache__ --exclude .DS_Store --exclude '*.bak.*' \
          --backup --suffix=".bak.$stamp" "$src/" "$mirror"
        echo "synced $mirror"
      else
        drift=1
        echo "drift: $mirror"
        printf '%s\n' "$out" | head -5 | sed 's/^/  /'
      fi
    fi
  done
done

if ((drift)); then
  echo "If the copy holds the newer edit, bring it into $PWD/.agents/skills first; then run: bash scripts/skill-mirrors.sh --write" >&2
  exit 1
fi
