#!/usr/bin/env python3
"""Tests for board.py. Run one class: python3 test_board.py Rows"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import board  # noqa: E402

FIX = os.path.join(HERE, "fixtures")


class Rows(unittest.TestCase):
    def test_bullets(self):
        rows = board.read_rows(os.path.join(FIX, "repo-a", "Tasks.md"))
        got = {(r.mark, r.id) for r in rows}
        self.assertEqual(got, {("~", "T101"), ("!", "T102"), ("-", "T103"), (" ", "T104"), ("x", "T100")})
        self.assertEqual(next(r.title for r in rows if r.id == "T101"), "配る時期を決める")

    def test_table(self):
        rows = board.read_rows(os.path.join(FIX, "repo-b", "TASKS.md"))
        self.assertEqual({(r.mark, r.id) for r in rows}, {("~", "V-6"), ("-", "E-1"), (" ", "E-2")})
        self.assertEqual(next(r.title for r in rows if r.id == "V-6"), "漂流の形を決める")

    def test_nested_breakdown_is_not_a_row(self):
        rows = board.read_rows(os.path.join(FIX, "repo-a", "Tasks.md"))
        self.assertEqual(sum(1 for r in rows if r.id is None), 0)

    def test_report_groups_by_state(self):
        out = board.render([board.scan(os.path.join(FIX, "repo-a"), None, [])], None)
        for want in ("判断待ち", "T101", "止まっている", "T102", "進行中", "T103"):
            self.assertIn(want, out)
        self.assertNotIn("T104", out)


def commit(repo: str, when: str, msg: str, files: dict[str, str]) -> None:
    for name, text in files.items():
        with open(os.path.join(repo, name), "w", encoding="utf-8") as f:
            f.write(text)
    env = dict(os.environ, GIT_AUTHOR_DATE=when, GIT_COMMITTER_DATE=when)
    subprocess.run(["git", "-C", repo, "add", "-A"], check=True)
    subprocess.run(["git", "-C", repo, "commit", "-q", "-m", msg], check=True, env=env)


class Since(unittest.TestCase):
    def setUp(self):
        self.repo = tempfile.mkdtemp(prefix="board-")
        subprocess.run(["git", "init", "-q", self.repo], check=True)
        for k, v in (("user.name", "t"), ("user.email", "t@example.invalid"), ("commit.gpgsign", "false")):
            subprocess.run(["git", "-C", self.repo, "config", k, v], check=True)
        commit(self.repo, "2026-10-30T12:00:00", "before: set up", {
            "Tasks.md": "- [x] **T1 — done long ago**\n- [ ] **T2 — tonight**\n- [ ] **T3 — archived tonight**\n",
            "Tasks-archive.md": "# archive\n"})
        commit(self.repo, "2026-10-31T01:00:00", "feat: T2 closed", {
            "Tasks.md": "- [x] **T1 — done long ago**\n- [x] **T2 — tonight**\n- [ ] **T3 — archived tonight**\n"})
        commit(self.repo, "2026-10-31T02:00:00", "chore: T3 moved to archive", {
            "Tasks.md": "- [x] **T2 — tonight**\n",
            "Tasks-archive.md": "# archive\n\n### T3 — archived tonight\n\n- 完了: 2026-10-31\n"})

    def tearDown(self):
        shutil.rmtree(self.repo, ignore_errors=True)

    def test_commits_after_the_boundary_only(self):
        r = board.scan(self.repo, "2026-10-30T18:00", [])
        self.assertEqual([c.split(" ", 1)[1] for c in r.commits], ["chore: T3 moved to archive", "feat: T2 closed"])

    def test_done_rows_after_the_boundary_only(self):
        r = board.scan(self.repo, "2026-10-30T18:00", [])
        self.assertEqual(sorted(r.done), ["T2", "T3"])

    def test_boundary_after_everything_shows_nothing(self):
        r = board.scan(self.repo, "2026-11-01T00:00", [])
        self.assertEqual((r.commits, r.done), ([], []))

    def test_report_lists_them(self):
        out = board.render([board.scan(self.repo, "2026-10-30T18:00", [])], "2026-10-30T18:00")
        for want in ("commit 2 件", "終わった", "T2", "T3", "2026-10-30T18:00"):
            self.assertIn(want, out)
        self.assertNotRegex(out, r"\bT1\b")


if __name__ == "__main__":
    unittest.main()
