#!/usr/bin/env python3
"""This script takes in the reads that are proposed by bmtagger to be human,
   and filters for or against these reads in the original fastq file."""

from argparser import FilterParser
from filter_functions import FilterReads


def main(read_list: str, read_file: str, non_human: bool, human: bool):
    filterer = FilterReads(read_list)
    human_reads = filterer.load_human_reads()
    if human:
        filterer.get_human_reads(read_file, human_reads)
    if non_human:
        filterer.get_non_human_reads(read_file, human_reads)


if __name__ == "__main__":
    args = FilterParser.parse_args()
    main(args.bmtagger_list, args.reads, args.skip_human_reads, args.get_human_reads)
