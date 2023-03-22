import pytest
from generate_stats import generate_stats
import logging


def test_generate_stats(capsys):
    generate_stats("sample_id", 233300, 17, 233317, 243300)
    captured = capsys.readouterr()
    assert (
        captured.out == "sample_id,233300,17,233317,99.99271,0.00729,243300,4.10316\n"
    )


def test_generate_stats_incorrect_reads(caplog, capsys):
    with pytest.raises(SystemExit) as exit_info:
        with caplog.at_level(logging.ERROR):
            generate_stats("sample_id", 100, 10, 100, 120)
    assert (
        "The number of host and non host reads does not equal the total number of reads, please investigate!"
        in caplog.text
    )
    assert exit_info.value.code == 1
