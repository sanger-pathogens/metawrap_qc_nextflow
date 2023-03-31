import pytest
from filter_reads import main
from filter_functions import FilterReads


@pytest.fixture()
def filterer():
    filterer = FilterReads("python_lib/tests/test_data/test.bmtagger.list")
    return filterer


@pytest.fixture
def human():
    filterer = FilterReads("python_lib/tests/test_data/test.bmtagger.list")
    human = filterer.load_human_reads()
    return human


def test_load_human_reads(filterer):
    assert filterer.load_human_reads() == {"R1": None, "R3": None}


def test_get_human_reads(capsys, human, filterer):
    filterer.get_human_reads("python_lib/tests/test_data/test.fastq", human)
    captured = capsys.readouterr()
    assert captured.out == "@R1/1\nCG\n+\nFF\n@R3/1\nGC\n+\nFF\n"


def test_get_non_human_reads(capsys, human, filterer):
    filterer.get_non_human_reads("python_lib/tests/test_data/test.fastq", human)
    captured = capsys.readouterr()
    assert captured.out == "@R2/1\nGC\n+\nFF\n@R4/1\nGC\n+\nFF\n"


def test_main_non_human(capsys):
    main(
        "python_lib/tests/test_data/test.bmtagger.list",
        "python_lib/tests/test_data/test.fastq",
        True,
        False,
    )
    captured = capsys.readouterr()
    assert captured.out == "@R2/1\nGC\n+\nFF\n@R4/1\nGC\n+\nFF\n"


def test_main_human(capsys):
    main(
        "python_lib/tests/test_data/test.bmtagger.list",
        "python_lib/tests/test_data/test.fastq",
        False,
        True,
    )
    captured = capsys.readouterr()
    assert captured.out == "@R1/1\nCG\n+\nFF\n@R3/1\nGC\n+\nFF\n"
