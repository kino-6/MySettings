from stats import report, mean
def test_basic():
    assert report([1, 2, 3, 4]) == {"mean": 2.5, "median": 2.5, "min": 1, "max": 4, "count": 4}
    assert report([5, 1, 3]) == {"mean": 3, "median": 3, "min": 1, "max": 5, "count": 3}
    assert mean([2, 4]) == 3
