from wordcount import count_words, top
def test_basic(tmp_path):
    p = tmp_path / "t.txt"; p.write_text("The cat the dog\nthe Cat\n")
    c = count_words(str(p))
    assert c == {"the": 3, "cat": 2, "dog": 1}
    assert top(c, 2) == [("the", 3), ("cat", 2)]
