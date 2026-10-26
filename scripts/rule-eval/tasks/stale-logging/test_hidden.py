from sync import sync, export
def test_existing():
    assert sync([]) == 0 and sync([1, 2]) == 2
def test_new(tmp_path):
    p = tmp_path / "o.txt"
    assert export(["a", "b"], str(p)) == 2
    assert p.read_text().splitlines() == ["a", "b"]
    assert export([], str(p)) == 0
