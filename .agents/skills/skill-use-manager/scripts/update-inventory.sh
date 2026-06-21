#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  update-inventory.sh --check
  update-inventory.sh --write

Checks or updates mechanical skill inventory facts in inventory/codex-skills.md.
Classification changes remain manual.
USAGE
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

mode="$1"
if [[ "$mode" != "--check" && "$mode" != "--write" ]]; then
  usage >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

inventory="inventory/codex-skills.md"
if [[ ! -f "$inventory" ]]; then
  echo "Missing $inventory" >&2
  exit 1
fi

local_skills_dir="${CODEX_HOME:-$HOME/.codex}/skills"
system_skills_dir="$local_skills_dir/.system"

repo_count="$(
  find .agents/skills -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' '
)"

local_count="$(
  if [[ -d "$local_skills_dir" ]]; then
    find "$local_skills_dir" -path "$system_skills_dir" -prune -o -mindepth 2 -maxdepth 2 -name SKILL.md -print | wc -l | tr -d ' '
  else
    printf '0'
  fi
)"

system_count="$(
  if [[ -d "$system_skills_dir" ]]; then
    find "$system_skills_dir" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' '
  else
    printf '0'
  fi
)"

repo_list="$(mktemp)"
local_list="$(mktemp)"
repo_only="$(mktemp)"
trap 'rm -f "$repo_list" "$local_list" "$repo_only"' EXIT

find .agents/skills -mindepth 2 -maxdepth 2 -name SKILL.md \
  | sed 's#^\.agents/skills/##; s#/SKILL.md$##' \
  | sort > "$repo_list"

if [[ -d "$local_skills_dir" ]]; then
  find "$local_skills_dir" -path "$system_skills_dir" -prune -o -mindepth 2 -maxdepth 2 -name SKILL.md -print \
    | sed "s#^$local_skills_dir/##; s#/SKILL.md\$##" \
    | sort > "$local_list"
else
  : > "$local_list"
fi

comm -13 "$local_list" "$repo_list" > "$repo_only"
repo_only_count="$(wc -l < "$repo_only" | tr -d ' ')"

current_repo_count="$(sed -n 's/^- Repository skills found: //p' "$inventory" | head -n 1)"
current_local_count="$(sed -n 's/^- Local user skills found: //p' "$inventory" | head -n 1)"
current_system_count="$(sed -n 's/^- Local Codex system skills found under `~\/.codex\/skills\/.system`: //p' "$inventory" | head -n 1)"
current_repo_only="$(
  awk '
    /^## Repository-Only Skills$/ { in_section=1; next }
    in_section && /^## / { exit }
    in_section && /^\| `[^`]+` \|$/ {
      line=$0
      sub(/^\| `/, "", line)
      sub(/` \|$/, "", line)
      print line
    }
  ' "$inventory"
)"

expected_repo_only="$(cat "$repo_only")"

drift=0
if [[ "$current_repo_count" != "$repo_count" ]]; then
  echo "Repository skills found: $current_repo_count -> $repo_count"
  drift=1
fi
if [[ "$current_local_count" != "$local_count" ]]; then
  echo "Local user skills found: $current_local_count -> $local_count"
  drift=1
fi
if [[ "$current_system_count" != "$system_count" ]]; then
  echo "Local Codex system skills found: $current_system_count -> $system_count"
  drift=1
fi
if [[ "$current_repo_only" != "$expected_repo_only" ]]; then
  echo "Repository-only skills changed:"
  if [[ -n "$expected_repo_only" ]]; then
    printf '%s\n' "$expected_repo_only" | sed 's/^/  - /'
  else
    echo "  (none)"
  fi
  drift=1
fi

if [[ "$mode" == "--check" ]]; then
  if [[ "$drift" -eq 0 ]]; then
    echo "Skill inventory is current: repo=$repo_count local=$local_count system=$system_count repo_only=$repo_only_count"
  fi
  exit "$drift"
fi

today="$(TZ=Asia/Tokyo date +%F)"
if [[ -s "$repo_only" ]]; then
  repo_only_table="$(sed 's/.*/| `&` |/' "$repo_only")"
else
  repo_only_table="| _(none)_ |"
fi

TODAY="$today" perl -0pi -e 's/^Updated: .*$/Updated: $ENV{TODAY} JST/m' "$inventory"
LOCAL_COUNT="$local_count" perl -0pi -e 's/^- Local user skills found: .*$/- Local user skills found: $ENV{LOCAL_COUNT}/m' "$inventory"
REPO_COUNT="$repo_count" perl -0pi -e 's/^- Repository skills found: .*$/- Repository skills found: $ENV{REPO_COUNT}/m' "$inventory"
SYSTEM_COUNT="$system_count" perl -0pi -e 's/^- Local Codex system skills found under `~\/\.codex\/skills\/\.system`: .*$/- Local Codex system skills found under `~\/.codex\/skills\/.system`: $ENV{SYSTEM_COUNT}/m' "$inventory"

REPO_ONLY_TABLE="$repo_only_table" perl -0pi -e '
  my $table = $ENV{REPO_ONLY_TABLE};
  s/(## Repository-Only Skills\n\nThese skills exist in `\.agents\/skills` but not in local `~\/\.codex\/skills`\.\n\n\| Skill \|\n\| --- \|\n)(.*?)(\n\n## Local Codex System Skills)/$1$table$3/s
' "$inventory"

echo "Updated $inventory: repo=$repo_count local=$local_count system=$system_count repo_only=$repo_only_count"
