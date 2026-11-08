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
import os
from pathlib import Path
import shlex
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

    hook_file = Path(os.environ["CODEX_HOME"]) / "hooks.json"
    declaration = json.loads(hook_file.read_text(encoding="utf-8"))
    commands = [
        hook["command"]
        for group in declaration["hooks"]["Stop"]
        for hook in group["hooks"]
        if hook["type"] == "command"
    ]
    if len(commands) != 1:
        raise RuntimeError(f"expected one registered Stop command; found {len(commands)}")

    tokens = shlex.split(commands[0])
    hook_env = os.environ.copy()
    while tokens and "=" in tokens[0] and not tokens[0].startswith(("/", "~")):
        key, value = tokens.pop(0).split("=", 1)
        hook_env[key] = value
    if len(tokens) != 2 or tokens[0] != "python3":
        raise RuntimeError(f"unexpected Stop command shape: {tokens}")

    isolated_home = Path(os.environ["CODEX_HOME"]).parent / "home"
    deployed_script = isolated_home / ".codex/skills/progress-contract/scripts/report_check.py"
    deployed_script.parent.mkdir(parents=True)
    deployed_script.write_bytes(
        (Path(cwd) / ".agents/skills/progress-contract/scripts/report_check.py").read_bytes()
    )
    hook_env["HOME"] = str(isolated_home)
    if tokens[1] != "~/.codex/skills/progress-contract/scripts/report_check.py":
        raise RuntimeError(f"unexpected Stop hook target: {tokens[1]}")
    tokens[1] = str(deployed_script)
    hook_input = {
        "stop_hook_active": False,
        "last_assistant_message": (
            "This deliberately long English response verifies that the registered "
            "Codex Stop hook command selects the Codex continuation response format."
        ),
    }
    hook_result = subprocess.run(
        tokens,
        input=json.dumps(hook_input),
        text=True,
        capture_output=True,
        check=True,
        env=hook_env,
    )
    hook_output = json.loads(hook_result.stdout)
    if hook_output.get("decision") != "block" or not hook_output.get("reason"):
        raise RuntimeError(f"registered Stop command did not block: {hook_output}")
finally:
    process.terminate()
    process.wait(timeout=5)
PY
python3 .agents/skills/progress-contract/scripts/test_report_check.py >/dev/null

echo "Codex config, profiles, and Stop hook passed."
