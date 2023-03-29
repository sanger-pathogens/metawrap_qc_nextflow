#!/usr/bin/env python3

import argparse


class FilterParser:
    def parse_args(args=None):
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--bmtagger_list",
            "-b",
            help="Bmtagger read list e.g. bmreads.list",
            required=True,
        )
        parser.add_argument(
            "--reads",
            "-r",
            help="Read file e.g. reads_1.fastq",
            required=True,
        )
        group = parser.add_mutually_exclusive_group(required=True)
        group.add_argument(
            "--skip-human-reads",
            "-s",
            help="Skip human reads",
            action="store_true",
        )
        group.add_argument(
            "--get-human-reads",
            "-g",
            help="Get human reads",
            action="store_true",
        )
        args = parser.parse_args()
        return args


class StatsParser:
    def parse_args(args=None):
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--host-reads",
            help="Number of host reads",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--non-host-reads",
            help="Number of non host reads",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--total-trimmed-reads",
            help="Total number of reads after trimming",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--total-original-reads",
            help="Total number of reads before trimming",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--sample-id",
            help="Sample ID",
            required=True,
        )
        args = parser.parse_args()
        return args
