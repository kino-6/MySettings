from html.parser import HTMLParser
class P(HTMLParser):
    def __init__(self): super().__init__(); self.tags = []
    def handle_starttag(self, t, a): self.tags.append((t, dict(a)))
def test_basic():
    p = P(); p.feed(open("form.html").read())
    tags = p.tags
    assert any(t == "form" for t, _ in tags)
    assert any(t == "input" and a.get("type") == "email" for t, a in tags)
    assert any(t == "input" and a.get("type") == "password" for t, a in tags)
    assert any((t == "button") or (t == "input" and a.get("type") == "submit") for t, a in tags)
