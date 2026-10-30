#!/usr/bin/env python3
"""One page for the morning: what the agents did overnight, repo by repo.

Reads, never writes. For each repository directly under --root that has a
Tasks.md (or TASKS.md), it lists the rows waiting on a human ([~]), blocked
([!]) and in progress ([-]). With a boundary time it adds the commits after it
and the rows that became [x] after it - found in the git diff, because a
finished row is soon moved out of the queue. Running Claude Code sessions
come from `claude agents --json` (the built-in agent view), matched by cwd.

  python3 board.py [--root DIR] [--since 2026-10-30T18:00]   default: yesterday 18:00
"""

from __future__ import annotations

import argparse
import datetime
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass

QUEUE_NAMES = ("Tasks.md", "TASKS.md", "tasks.md")
ID = re.compile(r"[A-Z]{1,3}-?\d+[a-z]?")
BULLET = re.compile(r"^- \[([ x~!-])\] (.*)$")  # top level only: nested ones are a row's breakdown
TABLE = re.compile(r"^\|\s*\[([ x~!-])\]\s*\|(.*)$")
ARCHIVE_HEAD = re.compile(r"^#{2,4}\s+(" + ID.pattern + r")\b")
EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
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
    commits: list[str]
    done: list[str]
    sessions: list[dict]


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
    return _parse(open(path, encoding="utf-8").read().splitlines())


def _parse(lines: list[str]) -> list[Row]:
    rows = []
    for line in lines:
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


def git(path: str, *args: str) -> str:
    p = subprocess.run(["git", "-C", path, *args], capture_output=True, text=True)
    return p.stdout if p.returncode == 0 else ""


def _done_ids(lines: list[str]) -> set[str]:
    ids = set()
    for line in lines:
        if m := ARCHIVE_HEAD.match(line):
            ids.add(m.group(1))
        elif (m := BULLET.match(line) or TABLE.match(line)) and m.group(1) == "x":
            ids |= {r.id for r in _parse([line]) if r.id}
    return ids


def finished_since(path: str, queue: str, since: str) -> tuple[list[str], list[str]]:
    """Commits after `since`, and IDs that became [x] (or were archived) after it."""
    commits = git(path, "log", f"--since={since}", "--format=%h %s").splitlines()
    if not commits:
        return [], []
    base = git(path, "rev-list", "-1", f"--before={since}", "HEAD").strip() or EMPTY_TREE
    rel = os.path.relpath(queue, path)
    diff = git(path, "diff", "-U0", base, "HEAD", "--", rel, ":(glob)**/*[Aa]rchive*.md")
    added = [l[1:] for l in diff.splitlines() if l.startswith("+") and not l.startswith("+++")]
    before = git(path, "show", f"{base}:{rel}").splitlines() if base != EMPTY_TREE else []
    return commits, sorted(_done_ids(added) - _done_ids(before))


def load_agents(path: str | None) -> list[dict]:
    """Sessions from a saved JSON file, or live from `claude agents --json`."""
    if path:
        return json.load(open(path, encoding="utf-8"))
    try:
        p = subprocess.run(["claude", "agents", "--json"], capture_output=True, text=True, timeout=30)
        return json.loads(p.stdout) if p.returncode == 0 else []
    except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError):
        return []  # no claude on PATH, or it did not answer: the board still shows the queues


def sessions_under(repo: str, agents: list[dict]) -> list[dict]:
    """Sessions whose working directory is the repository or inside it."""
    repo = os.path.normpath(repo)
    return [a for a in agents if os.path.normpath(a.get("cwd", "")) == repo
            or os.path.normpath(a.get("cwd", "")).startswith(repo + os.sep)]


def scan(path: str, since: str | None, agents: list[dict], root: str | None = None) -> Repo:
    """Collect what the board shows for one repository. `root` stands in for the
    parent directory when matching session cwds (tests run on copies elsewhere)."""
    q = queue_file(path)
    rows = read_rows(q) if q else []
    commits, done = finished_since(path, q, since) if q and since else ([], [])
    name = os.path.basename(path)
    return Repo(name, rows, commits, done, sessions_under(os.path.join(root, name) if root else path, agents))


def render(repos: list[Repo], since: str | None) -> str:
    """Markdown, busiest repositories first; quiet ones on one line at the end."""
    out, quiet = ["# 朝の 1 枚", ""] + ([f"{since} 以降", ""] if since else []), []
    for r in repos:
        parts = []
        if r.sessions:
            parts.append("- 動いている session: " + ", ".join(f"{a.get('name', '?')}（{a.get('status', '?')}, {a.get('kind', '?')}）"
                                                           for a in r.sessions))
        if r.commits:
            parts.append(f"- commit {len(r.commits)} 件: " + " / ".join(c.split(" ", 1)[1][:50] for c in r.commits[:3])
                         + (" ほか" if len(r.commits) > 3 else ""))
        if r.done:
            parts.append("- 終わった: " + ", ".join(r.done))
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
    ap.add_argument("--since", help="ISO time; default yesterday 18:00 local")
    ap.add_argument("--agents-json", help="saved `claude agents --json` output instead of asking claude")
    args = ap.parse_args()
    since = args.since or (datetime.date.today() - datetime.timedelta(days=1)).isoformat() + "T18:00"
    dirs = sorted(os.path.join(args.root, d) for d in os.listdir(args.root)
                  if os.path.isdir(os.path.join(args.root, d)) and not d.startswith((".", "!")))
    agents = load_agents(args.agents_json)
    repos = [scan(d, since, agents) for d in dirs if queue_file(d)]
    sys.stdout.write(render(repos, since))
    return 0


if __name__ == "__main__":
    sys.exit(main())
