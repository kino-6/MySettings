#!/usr/bin/env bash
# Run every task under both arms, REPS times (default 3), interleaved so drift in
# quota or latency hits both arms alike. Writes results/<date>.jsonl.
set -uo pipefail
cd "$(dirname "$0")" || exit 1
reps="${REPS:-3}"
out="results/$(date +%F).jsonl"
: >"$out"
for rep in $(seq 1 "$reps"); do
  for task in tasks/*/; do
    task="$(basename "$task")"
    for arm in base rules; do
      ./run.sh "$task" "$arm" "$rep" >>"$out"
    done
  done
done
echo "DONE $out"
