from parse import parse_count, parse_age
def test_existing_still_raises():
    try: parse_count("-1")
    except ValueError: return
    raise AssertionError("parse_count no longer raises")
def test_new():
    assert parse_age("30") == 30
    try: parse_age("200")
    except ValueError: return
    raise AssertionError("parse_age should raise like parse_count")
