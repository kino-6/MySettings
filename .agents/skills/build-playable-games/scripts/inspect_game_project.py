#!/usr/bin/env python3
"""Read-only inventory of a game repository for the build-playable-games skill.

Usage:
    python3 inspect_game_project.py <repo> [--markdown]

Prints discovered engines/runtimes, agent instruction files, gate/check
surfaces, trouble and lesson logs, and capture/self-play harnesses.
Treat the output as discovery, not truth: it names files worth reading,
it does not certify anything.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

SKIP_DIRS = {
    ".git", ".godot", "node_modules", "dist", "build", "target",
    ".venv", "venv", "__pycache__", ".import", "addons", "Library",
}
MAX_FILES = 20000

ENGINE_MARKERS = [
    ("project.godot", "Godot project"),
    ("export_presets.cfg", "Godot export presets"),
    ("Cargo.toml", "Rust (check for bevy/macroquad)"),
    ("pyproject.toml", "Python project (check for pygame/arcade)"),
    ("main.lua", "Lua entry (check for LOVE2D)"),
    ("ProjectSettings/ProjectVersion.txt", "Unity project"),
    ("index.html", "Browser entry point"),
    ("package.json", "Node project (check runtime below)"),
]
PACKAGE_HINTS = ("three", "phaser", "pixi", "babylon", "kaboom", "excalibur",
                 "playwright", "vitest", "vite", "electron", "tauri")

AGENT_DOC_NAMES = {"AGENTS.md", "CLAUDE.md", "GEMINI.md"}
TROUBLE_PAT = re.compile(
    r"(trouble|postmortem|post-mortem|audit|regression|playtest|lesson|"
    r"known[-_]defect|improve|retrospect|archive)", re.I)
GATE_PAT = re.compile(r"(gate|verify|check|selfplay|self[-_]play|smoke)", re.I)
CAPTURE_PAT = re.compile(r"(screenshot|capture|--shot|autoplay|replay|snapshot)", re.I)


def walk(root: Path):
    count = 0
    stack = [root]
    while stack:
        d = stack.pop()
        try:
            entries = sorted(d.iterdir())
        except OSError:
            continue
        for p in entries:
            if p.is_dir():
                if p.name not in SKIP_DIRS and not p.name.startswith(".git"):
                    stack.append(p)
            else:
                count += 1
                if count > MAX_FILES:
                    return
                yield p


def rel(root: Path, p: Path) -> str:
    return p.relative_to(root).as_posix()


def package_runtime_hints(root: Path) -> list[str]:
    pkg = root / "package.json"
    hints = []
    if pkg.is_file():
        try:
            text = pkg.read_text(encoding="utf-8", errors="replace")
        except OSError:
            return hints
        hints += [h for h in PACKAGE_HINTS if f'"{h}' in text]
        for m in re.finditer(r'"([\w:.-]+)"\s*:\s*"([^"]{1,120})"', text):
            name = m.group(1)
            if GATE_PAT.search(name) or name in ("play", "dev", "start"):
                hints.append(f"script {name}: {m.group(2)}")
    return hints


def inspect(root: Path) -> dict[str, list[str]]:
    found: dict[str, list[str]] = {
        "Engines / runtimes": [], "Agent instructions": [],
        "Gates and checks": [], "Trouble / lesson logs": [],
        "Capture / self-play": [], "Tests": [],
    }
    for marker, label in ENGINE_MARKERS:
        if (root / marker).exists():
            found["Engines / runtimes"].append(f"{marker} — {label}")
    found["Engines / runtimes"] += package_runtime_hints(root)

    for p in walk(root):
        r = rel(root, p)
        name = p.name
        if name in AGENT_DOC_NAMES or "/.claude/skills/" in f"/{r}" \
                or "/.agents/skills/" in f"/{r}":
            found["Agent instructions"].append(r)
        low = r.lower()
        if p.suffix in (".md", ".py", ".sh", ".gd", ".ts", ".js", ".json"):
            in_tooling = any(seg in low.split("/") for seg in
                             ("gates", "tools", "scripts", "tests", "test"))
            if GATE_PAT.search(name) and (in_tooling or p.suffix == ".md"):
                found["Gates and checks"].append(r)
            elif TROUBLE_PAT.search(name) and p.suffix == ".md":
                found["Trouble / lesson logs"].append(r)
            elif CAPTURE_PAT.search(name):
                found["Capture / self-play"].append(r)
            elif re.search(r"(^|/)(tests?|__tests__|spec)(/|$)", low) \
                    and p.suffix != ".md":
                found["Tests"].append(r)
    for key in found:
        found[key] = sorted(set(found[key]))[:60]
    return found


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("repo", type=Path)
    ap.add_argument("--markdown", action="store_true")
    args = ap.parse_args()
    root = args.repo.resolve()
    if not root.is_dir():
        print(f"error: {root} is not a directory", file=sys.stderr)
        return 2

    found = inspect(root)
    title = f"Game project inventory: {root.name}"
    if args.markdown:
        print(f"# {title}\n")
        for section, items in found.items():
            print(f"## {section}\n")
            if items:
                for i in items:
                    print(f"- `{i}`")
            else:
                print("- (none found)")
            print()
        print("_Discovery only: read the listed files; do not treat this "
              "inventory as a quality claim._")
    else:
        print(title)
        for section, items in found.items():
            print(f"\n{section}:")
            for i in items or ["(none found)"]:
                print(f"  {i}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
