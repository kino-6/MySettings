#!/usr/bin/env python3
"""Compatibility tests for the shared Claude Code and Codex Stop hook."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import sys
import unittest


SCRIPT = Path(__file__).with_name("report_check.py")
ENGLISH = (
    "This deliberately long English response demonstrates that the Stop hook "
    "detects a final answer written in English and requests one revision before "
    "the turn is allowed to finish normally."
)
JAPANESE = "これは日本語で書かれた最終返答です。" * 12


def run_hook(runtime: str, message: str, *, active: bool = False) -> dict:
    env = os.environ.copy()
    env.update({"REPORT_CHECKS": "lang", "REPORT_HOOK_RUNTIME": runtime})
    result = subprocess.run(
        [sys.executable, str(SCRIPT)],
        input=json.dumps(
            {
                "stop_hook_active": active,
                "last_assistant_message": message,
            }
        ),
        text=True,
        capture_output=True,
        check=True,
        env=env,
    )
    return json.loads(result.stdout) if result.stdout else {}


class ReportCheckCompatibilityTest(unittest.TestCase):
    def test_codex_requests_one_revision_for_english(self) -> None:
        output = run_hook("codex", ENGLISH)
        self.assertEqual(output["decision"], "block")
        self.assertIn("日本語で書かれていない", output["reason"])

    def test_codex_allows_japanese(self) -> None:
        self.assertEqual(run_hook("codex", JAPANESE), {})

    def test_codex_retry_guard_prevents_a_loop(self) -> None:
        self.assertEqual(run_hook("codex", ENGLISH, active=True), {})

    def test_claude_output_remains_compatible(self) -> None:
        output = run_hook("claude", ENGLISH)
        hook_output = output["hookSpecificOutput"]
        self.assertEqual(hook_output["hookEventName"], "Stop")
        self.assertIn("日本語で書かれていない", hook_output["additionalContext"])


if __name__ == "__main__":
    unittest.main()
