#!/usr/bin/env python3

import logging

from argparser import StatsParser


def generate_stats(
    sample_id: str,
    host_reads: int,
    non_host_reads: int,
    total_trimmed_reads: int,
    total_original_reads: int,
):
    if host_reads + non_host_reads != total_trimmed_reads:
        logging.error(
            "The number of host and non host reads does not equal the total number of reads, please investigate!"
        )
        raise SystemExit(1)
    percentage_host_reads = round(((host_reads / total_trimmed_reads) * 100), 5)
    percentage_non_host_reads = round(((non_host_reads / total_trimmed_reads) * 100), 5)
    percentage_reads_trimmed = round(((total_original_reads - total_trimmed_reads) / total_original_reads) * 100, 5)
    stats_string = (
        f"{sample_id},{host_reads},{non_host_reads},{total_trimmed_reads},"
        f"{percentage_host_reads},{percentage_non_host_reads},{total_original_reads},"
        f"{percentage_reads_trimmed}"
    )
    print(stats_string)


if __name__ == "__main__":
    args = StatsParser.parse_args()
    generate_stats(
        args.sample_id,
        args.host_reads,
        args.non_host_reads,
        args.total_trimmed_reads,
        args.total_original_reads,
    )
