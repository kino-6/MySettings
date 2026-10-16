#!/usr/bin/env bash
# Push through the gate. Encodes the flow every change in this repo goes
# through: work on a branch, merge --no-ff into main, push, delete the branch.
#
#   bash scripts/push.sh           on main: check, push main
#                                  on a branch: check, push the branch
#   bash scripts/push.sh --merge   on a branch: check, merge --no-ff into
#                                  main, push main, delete the branch
#
# Every refusal below exists so that what was checked is exactly what is pushed.
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

merge=0
case "${1:-}" in
  "") ;;
  --merge) merge=1 ;;
  *)
    echo "usage: push.sh [--merge]" >&2
    exit 2
    ;;
esac

die() {
  echo "push: $*" >&2
  exit 1
}

if [[ -n "$(git status --porcelain)" ]]; then
  git status --short >&2
  die "uncommitted changes - commit or stash first; the checks must see exactly what is pushed"
fi

branch="$(git branch --show-current)"
[[ -n "$branch" ]] || die "detached HEAD - check out a branch first"

git fetch -q origin
if [[ -n "$(git rev-list main..origin/main 2>/dev/null)" ]]; then
  die "origin/main has commits that local main lacks - pull them into main first"
fi

if ((merge)); then
  [[ "$branch" != "main" ]] || die "--merge is for a feature branch, and this is main"
  git merge-base --is-ancestor main "$branch" \
    || die "'$branch' does not contain main - merge main into it first, or the merged result would differ from what was checked"
fi

bash scripts/check.sh

if [[ "$branch" == "main" ]]; then
  git push origin main
elif ((merge)); then
  git checkout -q main
  git merge --no-ff -q "$branch" -m "Merge branch '$branch'"
  git push origin main
  git branch -d "$branch"
else
  git push -u origin "$branch"
fi
