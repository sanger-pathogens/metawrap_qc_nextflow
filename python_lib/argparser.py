#!/usr/bin/env python3

import argparse


class Filter_parser:
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
        parser.add_argument(
            "--skip-human-reads",
            "-s",
            help="Skip human reads",
            required=False,
            default=False,
            action="store_true",
        )
        parser.add_argument(
            "--get-human-reads",
            "-g",
            help="Get human reads",
            required=False,
            default=False,
            action="store_true",
        )
        args = parser.parse_args()
        return args


class Stats_parser:
    def parse_args(args=None):
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--host-reads",
            "-hr",
            help="Number of host reads",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--non-host-reads",
            "-nr",
            help="Number of non host reads",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--total-trimmed-reads",
            "-ttr",
            help="Total number of reads after trimming",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--total-original-reads",
            "-tor",
            help="Total number of reads before trimming",
            required=True,
            type=int,
        )
        parser.add_argument(
            "--sample-id",
            "-s",
            help="Sample ID",
            required=True,
            type=str,
        )
        args = parser.parse_args()
        return args
