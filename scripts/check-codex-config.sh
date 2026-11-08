#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! command -v codex >/dev/null 2>&1; then
  echo "[MISS] codex is required to validate Codex configuration." >&2
  exit 127
fi

task_tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$task_tmp_dir"' EXIT

if rg -n '^(persistent_instructions|max_threads)[[:space:]]*=|^\[profiles\.' .codex/config.toml; then
  echo "Legacy Codex configuration remains in .codex/config.toml." >&2
  exit 1
fi

validate_config() {
  local name="$1" source="$2" codex_dir="$task_tmp_dir/$1"
  mkdir -p "$codex_dir"
  cp "$source" "$codex_dir/config.toml"
  if [[ "$name" == "base" ]]; then
    cp -R .codex/agents "$codex_dir/agents"
  fi
  env CODEX_HOME="$codex_dir" \
    codex app-server --strict-config --print-startup-config >/dev/null
}

validate_config base .codex/config.toml
validate_config strict settings/common/.codex/strict.config.toml
validate_config yolo settings/common/.codex/yolo.config.toml

python3 -m json.tool settings/common/.codex/hooks.json >/dev/null
cp settings/common/.codex/hooks.json "$task_tmp_dir/base/hooks.json"
env CODEX_HOME="$task_tmp_dir/base" python3 - "$repo_root" <<'PY'
import json
import subprocess
import sys


cwd = sys.argv[1]
process = subprocess.Popen(
    ["codex", "app-server", "--listen", "stdio://"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
    bufsize=1,
)


def send(value: dict) -> None:
    process.stdin.write(json.dumps(value) + "\n")
    process.stdin.flush()


def response(request_id: int) -> dict:
    while True:
        line = process.stdout.readline()
        if not line:
            raise RuntimeError(process.stderr.read())
        value = json.loads(line)
        if value.get("id") == request_id:
            return value


try:
    send(
        {
            "id": 1,
            "method": "initialize",
            "params": {
                "clientInfo": {"name": "config-check", "version": "1"},
                "capabilities": {"experimentalApi": True},
            },
        }
    )
    initialized = response(1)
    if "error" in initialized:
        raise RuntimeError(initialized["error"])
    send({"method": "initialized", "params": {}})
    send({"id": 2, "method": "hooks/list", "params": {"cwds": [cwd]}})
    listed = response(2)
    if "error" in listed:
        raise RuntimeError(listed["error"])
    entries = listed["result"]["data"]
    errors = [error for entry in entries for error in entry["errors"]]
    warnings = [warning for entry in entries for warning in entry["warnings"]]
    stop_hooks = [
        hook
        for entry in entries
        for hook in entry["hooks"]
        if hook["eventName"] == "stop"
    ]
    if errors or warnings or len(stop_hooks) != 1:
        raise RuntimeError(
            f"expected one Stop hook without diagnostics; "
            f"hooks={len(stop_hooks)} warnings={warnings} errors={errors}"
        )
finally:
    process.terminate()
    process.wait(timeout=5)
PY
python3 .agents/skills/progress-contract/scripts/test_report_check.py >/dev/null

echo "Codex config, profiles, and Stop hook passed."
