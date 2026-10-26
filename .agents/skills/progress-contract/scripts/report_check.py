#!/usr/bin/env python3
"""Claude Code Stop hook: send an over-long, over-structured report back once.

Reads the hook input on stdin. Uses `last_assistant_message` (the turn's final
text) and `stop_hook_active` (true when already continuing because of a stop
hook). Only high-precision signals are checked - length, headings, phrasing and
language - because every trigger costs the user one extra model turn. Emphasis
(bold) is deliberately not checked: the user does not mind it.

One-shot: if stop_hook_active is true, it always lets the turn end, so a report
the agent decides to keep (because the length was asked for) is not looped on.

Thresholds (env): REPORT_MAX_CHARS=1500 REPORT_MAX_HEADINGS=4
REPORT_MAX_DASH=1 REPORT_MAX_DEWANAKU=2 REPORT_LANG=ja (empty disables language)

  report_check.py --audit <transcript.jsonl>   how many past reports would trip
"""

from __future__ import annotations

import json
import os
import re
import sys


def measure(text: str) -> dict:
    body = re.sub(r"```.*?```", "", text, flags=re.S)
    body = re.sub(r"`[^`\n]+`", "", body)
    letters = len(re.findall(r"[A-Za-z]", body))
    cjk = len(re.findall(r"[぀-ヿ一-鿿]", body))
    return {
        "chars": len(re.sub(r"\s", "", body)),
        "headings": len(re.findall(r"(?m)^#{1,3} ", text)),
        # translationese: "——" insertions, and "X ではなく Y" used as a refrain
        "dash": len(re.findall(r"——|—", body)),
        "dewanaku": len(re.findall(r"ではなく|じゃなく", body)),
        # a CJK character carries about as much as four Latin letters
        "ja_ratio": cjk / max(1.0, cjk + letters / 4),
    }


def problems(m: dict, env=os.environ) -> list[str]:
    # REPORT_CHECKS picks which checks run (comma list of length, headings,
    # dash, dewanaku, lang). Default: all of them.
    on = set((env.get("REPORT_CHECKS") or "length,headings,dash,dewanaku,lang").split(","))
    out = []
    max_chars = int(env.get("REPORT_MAX_CHARS", 1500))
    if "length" in on and m["chars"] > max_chars:
        out.append(f"長い（{m['chars']} 字。目安 {max_chars} 字）")
    if "headings" in on and m["headings"] > int(env.get("REPORT_MAX_HEADINGS", 4)):
        out.append(f"見出しが多い（{m['headings']} 個）")
    if "dash" in on and m["dash"] > int(env.get("REPORT_MAX_DASH", 1)):
        out.append(f"「——」での挿入（{m['dash']} 箇所。平易な文に直す）")
    if "dewanaku" in on and m["dewanaku"] > int(env.get("REPORT_MAX_DEWANAKU", 2)):
        out.append(f"「ではなく」の繰り返し（{m['dewanaku']} 回）")
    if "lang" in on and env.get("REPORT_LANG", "ja") == "ja" and m["chars"] > 100 and m["ja_ratio"] < 0.3:
        out.append("日本語で書かれていない")
    return out


def audit(path: str) -> int:
    """Replay a transcript: how many end-of-turn reports would be sent back."""
    from collections import Counter
    reports, why = 0, Counter()
    for line in open(path, encoding="utf-8"):
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        if d.get("type") != "assistant":
            continue
        text = "".join(c.get("text", "") for c in d.get("message", {}).get("content", [])
                       if isinstance(c, dict) and c.get("type") == "text")
        m = measure(text)
        if m["chars"] <= 400:  # status lines, not reports
            continue
        reports += 1
        for f in problems(m):
            why[f.split("（")[0]] += 1
        why["_sent_back"] += bool(problems(m))
    sent = why.pop("_sent_back", 0)
    print(f"reports={reports} sent_back={sent} ({sent * 100 // max(1, reports)}%)  {dict(why)}")
    return 0


def main() -> int:
    if len(sys.argv) == 3 and sys.argv[1] == "--audit":
        return audit(sys.argv[2])
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0  # never break a turn over malformed input
    if data.get("stop_hook_active"):
        return 0  # already revising because of a stop hook: let it end
    text = data.get("last_assistant_message") or ""
    found = problems(measure(text))
    if not found:
        return 0
    reason = (
        "直前の報告を読み手の負担が減る形に直してください: " + " / ".join(found) + "。"
        "最初の 1〜2 文で答え、通った検査や作業の一覧は削り、commit やファイル名は最後に 1 行。"
        "倒置・対句・体言止め・「——」での挿入を使わず、平易な日本語で。"
        "依頼が詳しさや英語を求めていたなら、そのままでかまいません（再検査はしません）。"
    )
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "Stop", "additionalContext": reason}},
                     ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
