#!/usr/bin/env python3
"""Verify vendored skills against the upstream revision recorded in provenance.json.

Invoked by scripts/check-provenance.sh. Exits 1 when anything drifted.

Vendoring used to copy LICENSE and record nothing about *which* revision the copy
came from, so upstream could move and the local copy would quietly go stale. The
first run of this check found exactly that: mattpocock's domain-modeling had
renamed CONTEXT.md to GLOSSARY.md and the local copy still taught the old name.

Only read-only raw.githubusercontent.com fetches are made; nothing is written.
"""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys

SKILLS = pathlib.Path(".agents/skills")
RAW = "https://raw.githubusercontent.com"


def fetch(url: str) -> bytes | None:
    out = subprocess.run(["curl", "-sfL", url], capture_output=True)
    return out.stdout if out.returncode == 0 else None


def check(manifest: pathlib.Path) -> tuple[bool, list[str]]:
    """Return (ok, lines-to-print) for one provenance manifest."""
    skill_dir = manifest.parent
    m = json.loads(manifest.read_text())

    upstream = m["upstream"].rstrip("/")
    if not upstream.startswith("https://github.com/"):
        return True, [f"[SKIP]  {skill_dir.name}  unsupported upstream host: {upstream}"]

    slug = upstream[len("https://github.com/"):]
    rev = m["revision"]
    base = f"{RAW}/{slug}/{rev}"

    problems: list[str] = []
    for local, info in m["files"].items():
        lp = skill_dir / local
        if not lp.is_file():
            problems.append(f"  [GONE]   {local} is recorded but missing locally")
            continue
        local_sha = hashlib.sha256(lp.read_bytes()).hexdigest()
        if local_sha != info["sha256"]:
            problems.append(
                f"  [EDITED] {local} no longer matches its recorded digest (local edit?)"
            )
            continue
        body = fetch(f"{base}/{info['source']}")
        if body is None:
            problems.append(
                f"  [404]    upstream path gone at this revision: {info['source']}"
            )
            continue
        if hashlib.sha256(body).hexdigest() != local_sha:
            problems.append(f"  [DRIFT]  {local} differs from upstream at {rev[:12]}")

    if problems:
        return False, [f"[FAIL]  {skill_dir.name}  @ {rev[:12]}"] + problems
    return True, [f"[OK]    {skill_dir.name}  @ {rev[:12]}"]


def main(argv: list[str]) -> int:
    strict = "--check" in argv

    manifests = sorted(SKILLS.glob("*/provenance.json"))
    if not manifests:
        print("No provenance.json found under .agents/skills/.")
        print("Vendored skills without one cannot be checked; record provenance at import time.")
        return 0

    drift = False
    for manifest in manifests:
        ok, lines = check(manifest)
        for line in lines:
            print(line)
        if not ok:
            drift = True

    print()
    print(f"Checked {len(manifests)} vendored skill(s) against their recorded revisions.")

    if strict:
        if drift:
            print(
                "Drift found. Decide per skill: re-vendor from the newer upstream, "
                "or pin deliberately and say why in provenance.json."
            )
            return 1
        print("No drift.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
