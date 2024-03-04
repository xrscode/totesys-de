from src.functions import get_bucket_names


def test_returns_a_dictionary():
    invoke = isinstance(get_bucket_names(), dict)
    assert invoke == True
