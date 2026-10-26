import ast, json, sys, re
from html.parser import HTMLParser
path, task = sys.argv[1], json.load(open(sys.argv[2]))
src = open(path).read()
out = {"lines": len([l for l in src.splitlines() if l.strip() and not l.strip().startswith(("#", "<!--"))])}
if task["lang"] == "py":
    t = ast.parse(src)
    funcs = [n for n in ast.walk(t) if isinstance(n, ast.FunctionDef)]
    calls = [n.func.id for n in ast.walk(t) if isinstance(n, ast.Call) and isinstance(n.func, ast.Name)]
    handlers = [h for n in ast.walk(t) if isinstance(n, ast.Try) for h in n.handlers]
    def checks(fn):
        return sum(1 for n in ast.walk(fn) if isinstance(n, ast.Raise) or (isinstance(n, ast.Call) and isinstance(n.func, ast.Name) and n.func.id == "isinstance"))
    out |= {
        "functions": len(funcs),
        "helpers_used_once": sum(1 for f in funcs if f.name not in task["public"] and calls.count(f.name) <= 1),
        "try": sum(1 for n in ast.walk(t) if isinstance(n, ast.Try)),
        "broad_except": sum(1 for h in handlers if h.type is None or (isinstance(h.type, ast.Name) and h.type.id in ("Exception", "BaseException"))),
        "swallowed": sum(1 for h in handlers if all(isinstance(b, (ast.Pass, ast.Continue)) for b in h.body)),
        "raise": sum(1 for n in ast.walk(t) if isinstance(n, ast.Raise)),
        "isinstance": calls.count("isinstance"),
        "checks_outside_entry": sum(checks(f) for f in funcs if f.name not in task["entry"]),
        "docstrings": sum(1 for f in funcs if ast.get_docstring(f)),
    }
else:
    class P(HTMLParser):
        KEEP = {"label", "button", "title", "h1", "h2", "legend", "option"}
        def __init__(self):
            super().__init__(); self.stack = []; self.total = 0; self.extra = 0; self.hints = 0
        def handle_starttag(self, tag, attrs):
            self.stack.append(tag); a = " ".join(f"{k}={v}" for k, v in attrs if v)
            if tag in ("small", "p") or re.search(r"hint|help|note|desc", a, re.I): self.hints += 1
        def handle_endtag(self, tag):
            if tag in self.stack: self.stack = self.stack[:len(self.stack) - self.stack[::-1].index(tag) - 1]
        def handle_data(self, d):
            if any(s in ("style", "script") for s in self.stack): return
            n = len(re.sub(r"\s", "", d)); self.total += n
            if not any(s in self.KEEP for s in self.stack): self.extra += n
    p = P(); p.feed(src)
    out |= {"visible_text": p.total, "extra_text": p.extra, "hint_elements": p.hints}
print(json.dumps(out))
