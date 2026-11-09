#!/usr/bin/env bash
# The user-level skill roots hold copies of .agents/skills/<name>. A copy left
# behind after the repo changes, or edited in place from another repository's
# session, drifts silently. --check lists every mirrored skill whose content
# differs; --write moves each drifted copy to <root>.bak/<stamp>/ (outside the
# root, so no runtime loads it as a skill) and copies the repo version in its
# place. A default root missing on this host is skipped; a root named in
# SKILL_MIRROR_ROOTS that yields nothing to compare is an error.
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
compared=0

IFS=: read -ra dirs <<<"$roots"
for root in "${dirs[@]}"; do
  [[ -d "$root" ]] || continue
  for mirror in "$root"/*/; do
    name="$(basename "$mirror")"
    src=".agents/skills/$name"
    [[ -d "$src" ]] || continue
    compared=$((compared + 1))
    if ! out="$(command diff -rq "${excl[@]}" "$src" "$mirror" 2>&1)"; then
      if [[ "$mode" == "--write" ]]; then
        bak="${root%/}.bak/$stamp"
        mkdir -p "$bak"
        mv "${mirror%/}" "$bak/$name"
        cp -R "$src" "${mirror%/}"
        find "${mirror%/}" -name __pycache__ -type d -prune -exec rm -rf {} +
        echo "synced $mirror (old copy: $bak/$name)"
      else
        drift=1
        echo "drift: $mirror"
        printf '%s\n' "$out" | head -5 | sed 's/^/  /'
      fi
    fi
  done
done

if [[ -n "${SKILL_MIRROR_ROOTS:-}" ]] && ((compared == 0)); then
  echo "no mirrored skill found under SKILL_MIRROR_ROOTS=$SKILL_MIRROR_ROOTS" >&2
  exit 1
fi
if ((drift)); then
  echo "If the copy holds the newer edit, bring it into $PWD/.agents/skills first; then run: bash scripts/skill-mirrors.sh --write" >&2
  exit 1
fi
