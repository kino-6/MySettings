#!/usr/bin/env bash
# usage: run.sh <task> <arm:base|rules> <rep>   -> one JSON line on stdout
set -uo pipefail
E="$(cd "$(dirname "$0")" && pwd)"
task=$1
arm=$2
rep=$3
T="$E/tasks/$task"
d="$E/runs/$task-$arm-$rep"
rm -rf "$d"
mkdir -p "$d"
cd "$d" || exit 1
[[ -d "$T/seed" ]] && cp "$T/seed/"* .
[[ "$arm" == rules ]] && cp "$E/candidate.md" CLAUDE.md
claude -p "$(cat "$T/prompt.txt")" --allowedTools Read Write Edit --permission-mode acceptEdits \
  --output-format json >agent.json 2>agent.err
cp "$T/test_hidden.py" .
python3 - "$d" "$T" "$E" "$task" "$arm" "$rep" <<'PY'
import json, subprocess, sys, os
d, T, E, task, arm, rep = sys.argv[1:]
spec = json.load(open(f"{T}/task.json"))
try: a = json.load(open(f"{d}/agent.json"))
except Exception: a = {}
out = {"task": task, "arm": arm, "rep": int(rep), "duration_s": round(a.get("duration_ms", 0) / 1000, 1),
       "cost_usd": a.get("total_cost_usd"), "turns": a.get("num_turns"), "asked": "?" in a.get("result", "")}
f = f"{d}/{spec['file']}"
if os.path.exists(f):
    out |= json.loads(subprocess.run(["python3", f"{E}/measure.py", f, f"{T}/task.json"], capture_output=True, text=True).stdout or "{}")
    out |= json.loads(subprocess.run(["python3", f"{E}/runtests.py"], cwd=d, capture_output=True, text=True).stdout or "{}")
else:
    out["error"] = "file not written"
print(json.dumps(out, ensure_ascii=False))
PY
