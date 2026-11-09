#!/usr/bin/env bash
# Tests for scripts/skill-mirrors.sh against temporary mirror roots only.
#   bash scripts/test-skill-mirrors.sh
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
sm=scripts/skill-mirrors.sh
skill=morning-board
work="$(mktemp -d "${TMPDIR:-/tmp}/skill-mirrors-test.XXXXXX")"
trap 'rm -rf "$work" "$work".*' EXIT
fail=0

fresh() { # a temp root holding an exact copy of the skill
  local root="$work/$1"
  mkdir -p "$root"
  cp -R ".agents/skills/$skill" "$root/"
  find "$root" -name __pycache__ -type d -prune -exec rm -rf {} +
  printf '%s' "$root"
}
expect() { # expect <exit code> <label> <command...>
  local want="$1" label="$2" got=0
  shift 2
  "$@" >/dev/null 2>&1 || got=$?
  if [[ "$got" != "$want" ]]; then
    echo "FAIL $label: exit $got, want $want"
    fail=1
  fi
}

r="$(fresh same)"
expect 0 "identical copy passes" env SKILL_MIRROR_ROOTS="$r" bash "$sm" --check

r="$(fresh nested)"
echo x >>"$r/$skill/scripts/board.py"
expect 1 "drift below the top level is found" env SKILL_MIRROR_ROOTS="$r" bash "$sm" --check

r="$(fresh extra)"
mkdir "$r/$skill/d" && echo q >"$r/$skill/d/f"
expect 1 "a directory only in the mirror is found" env SKILL_MIRROR_ROOTS="$r" bash "$sm" --check
expect 0 "--write succeeds" env SKILL_MIRROR_ROOTS="$r" bash "$sm" --write
expect 0 "one --write converges" env SKILL_MIRROR_ROOTS="$r" bash "$sm" --check
if ! ls "$r".bak/*/"$skill"/d/f >/dev/null 2>&1; then
  echo "FAIL --write keeps the old copy outside the root"
  fail=1
fi

expect 1 "a named root with nothing to compare fails" env SKILL_MIRROR_ROOTS="$work/missing" bash "$sm" --check

((fail == 0)) && echo "skill-mirrors tests OK"
exit "$fail"
