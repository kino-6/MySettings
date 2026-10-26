from pipeline import run
def test_basic():
    assert run({"user_id": 1, "items": [{"name": "a", "qty": 2}, {"name": "b", "qty": 1}]}) == {"user_id": 1, "total": 300}
