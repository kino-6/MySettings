import orders
def test_existing():
    assert orders.total_cents([{"price_cents": 1000, "qty": 2}]) == 2000
def test_new_in_cents():
    fn = [getattr(orders, n) for n in dir(orders) if "discount" in n.lower()]
    assert fn, "no discount function"
    assert fn[0]([{"price_cents": 1000, "qty": 2}], 10) == 1800
