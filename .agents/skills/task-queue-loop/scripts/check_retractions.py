#!/usr/bin/env python3
"""Find retracted claims still standing, uncorrected, anywhere in the repository.

A correction usually lands in the document that was wrong and in the summary
someone was looking at. The other copies - the document the claim came from, a
checklist line, a table cell - keep saying the old thing, and the next session
copies it from there. retractions.json lists each withdrawn claim once:

  {"retractions": [{
     "id": "R1",
     "claim": "1 本(の系列)?では.{0,20}分けられない",   regex for the old wording
     "corrected_by": "docs/386_public_scale_results.md",
     "current": "冷えた条件",                              optional regex for the new wording
     "note": "one line: what was wrong"
  }], "exempt": ["TROUBLES.md"], "allow": ["docs/045_protocol.md:50"]}

A matching line is settled when any of these holds:
  - the line itself also matches `current`, or links `corrected_by`
  - the file's head (first 10 lines) links `corrected_by` - the 追記 convention
  - the file is `corrected_by`, retractions.json, or listed in `exempt`
  - the line is listed in `allow` as path:line - for a document that must not be
    edited, such as a pre-registration whose decision rule quotes the claim
Anything else is reported as path:line and the exit code is 1.

  python3 tools/check_retractions.py                      this repository
  python3 tools/check_retractions.py --root DIR --registry FILE
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys

HEAD_LINES = 10


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", default=".")
    ap.add_argument("--registry", default=None, help="default: <root>/retractions.json")
    args = ap.parse_args()
    root = os.path.abspath(args.root)
    reg_path = os.path.abspath(args.registry or os.path.join(root, "retractions.json"))
    reg = json.load(open(reg_path, encoding="utf-8"))
    exempt = reg.get("exempt", [])
    allow = set(reg.get("allow", []))
    entries = [{**e, "re": re.compile(e["claim"]), "cur": re.compile(e["current"]) if e.get("current") else None,
                "link": os.path.basename(e["corrected_by"])} for e in reg["retractions"]]

    files = subprocess.run(["git", "-C", root, "ls-files", "*.md"], capture_output=True, text=True, check=True).stdout.split()
    stale = []
    for rel in files:
        path = os.path.join(root, rel)
        if os.path.abspath(path) == reg_path or any(fnmatch.fnmatch(rel, g) for g in exempt):
            continue
        try:
            lines = open(path, encoding="utf-8").read().splitlines()
        except (OSError, UnicodeDecodeError):
            continue
        head = "\n".join(lines[:HEAD_LINES])
        for e in entries:
            if rel == e["corrected_by"] or e["link"] in head:
                continue
            for n, line in enumerate(lines, 1):
                if f"{rel}:{n}" in allow:
                    continue
                if e["re"].search(line) and not (e["link"] in line or (e["cur"] and e["cur"].search(line))):
                    stale.append((rel, n, e["id"], line.strip()))

    for rel, n, rid, text in stale:
        print(f"{rel}:{n}: {rid} still stands: {text[:120]}")
    if stale:
        print(f"\n{len(stale)} line(s) repeat a retracted claim. Add a correction note (or the new wording) "
              "where each one stands, or narrow the claim pattern if it is a different statement.")
        return 1
    print(f"OK: {len(entries)} retraction(s), no uncorrected copy.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
