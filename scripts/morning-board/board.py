#!/usr/bin/env python3
"""One page for the morning: what the agents did overnight, repo by repo.

Reads, never writes. For each repository directly under --root that has a
Tasks.md (or TASKS.md), it lists the rows waiting on a human ([~]), blocked
([!]) and in progress ([-]).

  python3 board.py [--root DIR]
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass

QUEUE_NAMES = ("Tasks.md", "TASKS.md", "tasks.md")
ID = re.compile(r"[A-Z]{1,3}-?\d+[a-z]?")
BULLET = re.compile(r"^- \[([ x~!-])\] (.*)$")  # top level only: nested ones are a row's breakdown
TABLE = re.compile(r"^\|\s*\[([ x~!-])\]\s*\|(.*)$")
SHOWN = (("~", "判断待ち"), ("!", "止まっている"), ("-", "進行中"))


@dataclass
class Row:
    mark: str
    id: str | None
    title: str


@dataclass
class Repo:
    name: str
    rows: list[Row]


def _bullet_title(text: str) -> tuple[str | None, str]:
    m = re.match(r"\*\*(.+?)\*\*", text)
    head = m.group(1) if m else text
    m = re.match(rf"({ID.pattern})\s*[—:-]\s*(.*)", head)
    if m:
        return m.group(1), m.group(2).strip()
    m = ID.search(head)
    return (m.group(0) if m else None), head.strip()


def read_rows(path: str) -> list[Row]:
    """Rows with a status mark, from both the bullet and the table layout."""
    rows = []
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        if m := BULLET.match(line):
            rid, title = _bullet_title(m.group(2))
            rows.append(Row(m.group(1), rid, title))
        elif m := TABLE.match(line):
            cells = [c.strip() for c in m.group(2).split("|")]
            i = next((k for k, c in enumerate(cells) if ID.fullmatch(c.strip("*`"))), None)
            if i is None:
                rows.append(Row(m.group(1), None, cells[0] if cells else ""))
            else:
                title = cells[i + 1] if i + 1 < len(cells) else ""
                rows.append(Row(m.group(1), cells[i].strip("*`"), title.strip("*")))
    return rows


def queue_file(path: str) -> str | None:
    names = set(os.listdir(path))
    return next((os.path.join(path, n) for n in QUEUE_NAMES if n in names), None)


def scan(path: str, since: str | None, agents: list[dict]) -> Repo:
    """Collect what the board shows for one repository."""
    q = queue_file(path)
    return Repo(os.path.basename(path), read_rows(q) if q else [])


def render(repos: list[Repo], since: str | None) -> str:
    """Markdown, busiest repositories first; quiet ones on one line at the end."""
    out, quiet = ["# 朝の 1 枚", ""], []
    for r in repos:
        parts = []
        for mark, label in SHOWN:
            hit = [x for x in r.rows if x.mark == mark]
            if hit:
                parts.append(f"- {label}:")
                parts += [f"  - {x.id or '?'} {x.title[:60]}" for x in hit]
        if parts:
            out += [f"## {r.name}", "", *parts, ""]
        else:
            quiet.append(r.name)
    if quiet:
        out.append("動きなし: " + ", ".join(quiet))
    return "\n".join(out).rstrip() + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", default=os.path.expanduser("~/work"))
    args = ap.parse_args()
    dirs = sorted(os.path.join(args.root, d) for d in os.listdir(args.root)
                  if os.path.isdir(os.path.join(args.root, d)) and not d.startswith((".", "!")))
    repos = [scan(d, None, []) for d in dirs if queue_file(d)]
    sys.stdout.write(render(repos, None))
    return 0


if __name__ == "__main__":
    sys.exit(main())
