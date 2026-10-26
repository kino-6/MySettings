from ingest import load_orders, total
def test_basic(tmp_path):
    p = tmp_path / "o.csv"; p.write_text("id,qty,price\nA1,2,1.5\nB2,3,2\n")
    o = load_orders(str(p))
    assert o == [{"id": "A1", "qty": 2, "price": 1.5}, {"id": "B2", "qty": 3, "price": 2.0}]
    assert total(o) == 9.0
