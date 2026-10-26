def total_cents(items):
    return sum(i["price_cents"] * i["qty"] for i in items)
