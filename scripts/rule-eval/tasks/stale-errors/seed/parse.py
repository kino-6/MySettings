def parse_count(s):
    n = int(s)
    if n < 0:
        raise ValueError(f"count must be >= 0: {n}")
    return n
