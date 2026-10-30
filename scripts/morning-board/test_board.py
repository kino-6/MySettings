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


class Shapes(unittest.TestCase):
    def setUp(self):
        self.rows = {r.id: r.title for r in board.read_rows(os.path.join(FIX, "shapes.md"))}

    def test_priority_and_second_id_leave_the_title(self):
        self.assertEqual(self.rows["S12"], "人物の一致を直す。")
        self.assertEqual(self.rows["AS02"], "敵の接地を仕上げる。")

    def test_owner_mark_and_bold_leave_the_title(self):
        self.assertTrue(self.rows["T772"].startswith("石碑が低い"), self.rows["T772"])
        self.assertTrue(self.rows["T373"].startswith("appid 待ち"), self.rows["T373"])

    def test_check_counts_nothing_here(self):
        self.assertEqual(board.malformed(board.read_rows(os.path.join(FIX, "shapes.md"))), [])

    def test_check_catches_a_title_that_starts_with_its_id(self):
        bad = [board.Row("-", "S1", "S1 / P0 — x"), board.Row("~", None, "no id"), board.Row("x", None, "done, no id")]
        self.assertEqual(len(board.malformed(bad)), 2)


class Archive(unittest.TestCase):
    def setUp(self):
        self.repo = tempfile.mkdtemp(prefix="board-")
        subprocess.run(["git", "init", "-q", self.repo], check=True)
        for k, v in (("user.name", "t"), ("user.email", "t@example.invalid"), ("commit.gpgsign", "false")):
            subprocess.run(["git", "-C", self.repo, "config", k, v], check=True)
        os.makedirs(os.path.join(self.repo, "docs"))
        commit(self.repo, "2026-10-30T12:00:00", "before", {"Tasks.md": "- [ ] **T050 — a**\n", "docs/TASKS-ARCHIVE.md": "# a\n"})
        commit(self.repo, "2026-10-31T01:00:00", "after", {"docs/TASKS-ARCHIVE.md":
               "# a\n\n## T041〜T043、T046\n\n## 2026-10-31: S12 人物の一致\n\n## 2026-08-22 実プレイで出た 12 件\n"})

    def tearDown(self):
        shutil.rmtree(self.repo, ignore_errors=True)

    def test_upper_case_archive_ranges_and_date_first_headings(self):
        r = board.scan(self.repo, "2026-10-30T18:00", [])
        self.assertEqual(sorted(r.done), ["S12", "T041", "T042", "T043", "T046"])


class Agents(unittest.TestCase):
    def setUp(self):
        self.agents = board.load_agents(os.path.join(FIX, "agents.json"))

    def test_session_belongs_to_the_repo_it_runs_under(self):
        self.assertEqual(sorted(a["name"] for a in board.sessions_under("/work/repo-a", self.agents)), ["repo-a-1", "repo-a-2"])

    def test_prefix_of_a_name_is_not_under_it(self):
        self.assertEqual([a["name"] for a in board.sessions_under("/work/repo-ab", self.agents)], ["repo-ab-1"])

    def test_same_basename_elsewhere_is_not_under_it(self):
        self.assertEqual(board.sessions_under("/work/repo-b", self.agents), [])

    def test_report_shows_status(self):
        repo = board.scan(os.path.join(FIX, "repo-a"), None, self.agents, root="/work")
        out = board.render([repo], None)
        self.assertIn("repo-a-1（busy", out)
        self.assertIn("repo-a-2（idle", out)


if __name__ == "__main__":
    unittest.main()
