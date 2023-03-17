import pytest
from filter_reads import main
from filter_functions import Filter_reads


@pytest.fixture()
def filter():
    filter = Filter_reads("test_data/test.bmtagger.list")
    return filter


@pytest.fixture
def human():
    filter = Filter_reads("test_data/test.bmtagger.list")
    human = filter.load_human_reads()
    return human


def test_load_human_reads(filter):
    assert filter.load_human_reads() == {"R1": None, "R3": None}


def test_get_human_reads(capsys, human, filter):
    filter.get_human_reads("test_data/test.fastq", human)
    captured = capsys.readouterr()
    assert captured.out == "@R1/1\nCG\n+\nFF\n@R3/1\nGC\n+\nFF\n"


def test_get_non_human_reads(capsys, human, filter):
    filter.get_non_human_reads("test_data/test.fastq", human)
    captured = capsys.readouterr()
    assert captured.out == "@R2/1\nGC\n+\nFF\n@R4/1\nGC\n+\nFF\n"


def test_main_non_human(capsys):
    main("test_data/test.bmtagger.list", "test_data/test.fastq", True, False)
    captured = capsys.readouterr()
    assert captured.out == "@R2/1\nGC\n+\nFF\n@R4/1\nGC\n+\nFF\n"


def test_main_human(capsys):
    main("test_data/test.bmtagger.list", "test_data/test.fastq", False, True)
    captured = capsys.readouterr()
    assert captured.out == "@R1/1\nCG\n+\nFF\n@R3/1\nGC\n+\nFF\n"
