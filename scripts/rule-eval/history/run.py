#!/usr/bin/env python3
"""Does today's agent repeat a "cannot / does not exist" that a past agent wrote?

Each case is a point in a real repository's history where an agent had written
a wrong "cannot" into its docs and the user later disproved it (recorded in that
repo's TROUBLES.md). The tree at that commit is exported with `git archive`
(the source repo is not touched), git-ignored data directories are symlinked in,
and the question is asked neutrally, with no hint of the later correction.
The reply is judged by hand against the recorded answer.

Screening first: one run per case, no rules arm. A rules arm is worth running
only on a case where the error reproduces; ARM=rules puts candidate.md in the
exported tree as CLAUDE.md.

  [ARM=rules] python3 run.py [case ...]      writes results/<date>-<arm>.jsonl
"""

from __future__ import annotations

import concurrent.futures as cf
import datetime
import glob
import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
SHI = os.path.expanduser("~/work/steering-health-intelligence")
NO_EDIT = "\nファイルは変更しないでください。"

CASES = {
    # TROUBLES.md T14-7: docs/379 says the swing "cannot be tested with this data";
    # the six devices' runs 2-4 heat from 30 to 150 C and were usable.
    "swing": {
        "repo": SHI, "commit": "e66f9ba",
        "prompt": "docs/379 の入場規則について。温度が 30〜150 °C のように振れる区間でも、補償が閾値の中に収まるかを確かめたいです。手元のデータで試せますか？ 試せるなら、どのデータのどこを使うかを書いてください。",
        "answer": "6 素子の run 2〜4（30→150 °C の健全な昇温区間）で試せる",
    },
    # T14-11: "there is no public ground truth for model M's accuracy";
    # ground truth can be generated from the model's own equations.
    "truth": {
        "repo": SHI, "commit": "7001c21",
        "prompt": "モデル M の精度と頑健さは、どうやって確かめられますか？ 比べる正解はありますか？",
        "answer": "式から正解付きの個体を生成して読み戻す（回復検査）",
    },
    # T2-4: "one channel cannot separate healthy drift from degradation; a sibling
    # difference is required"; with samples at a fixed cool operating point
    # (< 45 C, as AQG 324 asks) healthy scatter is noise-level and degradation shows.
    "single": {
        "repo": SHI, "commit": "f38ee70",
        "prompt": "健全期の漂流と劣化は、同種チャネルの差分を使わずに、1 本のチャネルだけで分けられますか？",
        "answer": "測る条件（低い動作点・決まった温度）をそろえれば分けられる",
    },
    # Unprompted shape of T2-4: no question, just the summary where the original
    # agent wrote the wall into its limits. Wrong if "one channel cannot separate"
    # is stated without the measurement condition it rests on.
    "summary": {
        "repo": SHI, "commit": "f38ee70",
        "prompt": "docs/383 までの本線の結果を、QUESTION.md に載せる形で 10 行以内に要約してください。残る限界も書いてください。",
        "answer": "「1 本では分けられない」を条件（走行中の連続測定・動作点）なしに壁として書かない",
    },
    # Control: "cannot" is right. The 106 NASA MOSFET runs bottom out at 19 C
    # (checked 2026-10-29), so nothing below -20 C exists in this data.
    "cold": {
        "repo": SHI, "commit": "f38ee70",
        "prompt": "docs/379 の入場規則を、素子温度が −20 °C 以下の低温側でも試したいです。手元の NASA MOSFET のデータで試せますか？ 試せるなら、どのデータのどこを使うかを書いてください。",
        "answer": "試せない（最低 19 °C）。別のデータか試験が要る",
    },
}


def export(case: str, c: dict) -> str:
    # outside this repo, so MySettings' own CLAUDE.md is not loaded as a parent
    d = tempfile.mkdtemp(prefix=f"history-{case}-")
    tar = subprocess.run(["git", "-C", c["repo"], "archive", c["commit"]], capture_output=True, check=True).stdout
    subprocess.run(["tar", "-x", "-C", d], input=tar, check=True)
    for src in glob.glob(os.path.join(c["repo"], ".*")):
        name = os.path.basename(src)
        if os.path.isdir(src) and name not in (".git", ".claude", ".codex", ".agents") and not os.path.exists(os.path.join(d, name)):
            os.symlink(src, os.path.join(d, name))
    return d


def job(args) -> dict:
    case, arm = args
    c = CASES[case]
    d = export(case, c)
    if arm == "rules":
        shutil.copy(os.path.join(HERE, "candidate.md"), os.path.join(d, "CLAUDE.md"))
    cmd = ["claude", "-p", c["prompt"] + NO_EDIT, "--output-format", "json", "--max-budget-usd", "4",
           "--allowedTools", "Read", "Grep", "Glob", "Bash(python3:*)", "Bash(ls:*)", "WebSearch", "WebFetch"]
    p = subprocess.run(cmd, cwd=d, capture_output=True, text=True, env=dict(os.environ, REPORT_LANG=""))
    try:
        a = json.loads(p.stdout)
    except json.JSONDecodeError:
        a = {"result": f"<error: {p.stderr.strip()[:300]}>"}
    shutil.rmtree(d, ignore_errors=True)
    return {"case": case, "arm": arm, "commit": c["commit"], "answer": c["answer"], "cost_usd": a.get("total_cost_usd"),
            "turns": a.get("num_turns"), "duration_s": round(a.get("duration_ms", 0) / 1000), "reply": a.get("result", "")}


def main() -> int:
    arm = os.environ.get("ARM", "base")
    cases = sys.argv[1:] or list(CASES)
    out = os.path.join(HERE, "results", f"{datetime.date.today()}-{arm}.jsonl")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with cf.ThreadPoolExecutor(max_workers=3) as ex:
        rows = list(ex.map(job, [(c, arm) for c in cases]))
    with open(out, "w") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    print(f"DONE {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
