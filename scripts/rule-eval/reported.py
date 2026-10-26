"""Shared by the stale-* checks: did the final reply name the doc/code conflict?"""
import json, re
def reported():
    try: text = json.load(open("agent.json")).get("result", "")
    except Exception: return False
    return bool(re.search(r"CLAUDE\.md|inconsisten|conflict|mismatch|outdated|stale|contradict|disagree|食い違|矛盾|古い", text, re.I))
