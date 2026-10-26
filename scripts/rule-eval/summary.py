import json, sys
from collections import defaultdict
rows = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
PY_KEYS = ["lines", "functions", "helpers_used_once", "try", "broad_except", "swallowed",
           "raise", "isinstance", "checks_outside_entry", "docstrings",
           # stale-* tasks: which convention the new code followed, and side effects
           "follows_code", "follows_doc", "rewrote_existing", "reported"]
HTML_KEYS = ["lines", "visible_text", "extra_text", "hint_elements"]
def avg(xs): return sum(xs) / len(xs) if xs else float("nan")
by = defaultdict(list)
for r in rows: by[(r["task"], r["arm"])].append(r)
tasks = sorted({r["task"] for r in rows})
print(f"runs={len(rows)}  errors={sum('error' in r for r in rows)}")
for t in tasks:
    b, r = by[(t, "base")], by[(t, "rules")]
    keys = HTML_KEYS if t == "form" else PY_KEYS
    print(f"\n[{t}]  tests passed: base {sum(x.get('tests_fail',1)==0 and 'tests_ok' in x for x in b)}/{len(b)}  rules {sum(x.get('tests_fail',1)==0 and 'tests_ok' in x for x in r)}/{len(r)}"
          f"   asked: base {sum(x['asked'] for x in b)} rules {sum(x['asked'] for x in r)}")
    for k in keys:
        vb, vr = [x[k] for x in b if k in x], [x[k] for x in r if k in x]
        if not vb and not vr: continue
        mb, mr = avg(vb), avg(vr)
        if mb == 0 and mr == 0: continue
        print(f"  {k:22} base {mb:6.1f}   rules {mr:6.1f}   ({'↓' if mr < mb else '↑' if mr > mb else '='})   base={vb} rules={vr}")
c = [r["cost_usd"] or 0 for r in rows]; d = [r["duration_s"] for r in rows]
print(f"\ncost(API換算) total ${sum(c):.2f}  per run ${avg(c):.3f}   time total {sum(d)/60:.1f} min")
