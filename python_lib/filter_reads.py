#!/usr/bin/env python3
"""This script takes in the reads that are proposed by bmtagger to be human,
   and filters for or against these reads in the original fastq file."""

from argparser import Filter_parser
from filter_functions import Filter_reads


def main(read_list, read_file, non_human, human):
    filter = Filter_reads(read_list)
    human_reads = filter.load_human_reads()
    if human:
        filter.get_human_reads(read_file, human_reads)
    if non_human:
        filter.get_non_human_reads(read_file, human_reads)


if __name__ == "__main__":
    args = Filter_parser.parse_args()
    if not args.skip_human_reads and not args.get_human_reads:
        print(
            "Please select either human or non human reads with the --skip-human-reads or --get-human-reads options"
        )
        exit(1)
    main(args.bmtagger_list, args.reads, args.skip_human_reads, args.get_human_reads)
