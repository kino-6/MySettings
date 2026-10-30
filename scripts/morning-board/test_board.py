#!/usr/bin/env python3
"""Tests for board.py. Run one class: python3 test_board.py Rows"""

from __future__ import annotations

import os
import sys
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


if __name__ == "__main__":
    unittest.main()
