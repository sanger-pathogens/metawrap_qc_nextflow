#!/usr/bin/env python3


class Filter_reads:
    def __init__(self, read_list):
        self.read_list = read_list

    def load_human_reads(self):
        """Function which loads in human reads from bmtagger list"""

        human = {}
        with open(self.read_list, "r") as f:
            data = f.readlines()
            for line in data:
                human[line.strip()] = None
        return human

    def get_human_reads(self, read_file, human):
        """Function which prints out human reads as identified by bmtagger"""

        with open(read_file, "r") as f:
            for i, line in enumerate(f):
                if i % 4 == 0:
                    get = False
                    if line[1:].split("/")[0].split()[0] in human:
                        get = True
                if get:
                    print(line.rstrip())

    def get_non_human_reads(self, read_file, human):
        """Function which prints out non-human reads as identified by bmtagger"""

        with open(read_file, "r") as f:
            for i, line in enumerate(f):
                if i % 4 == 0:
                    get = False
                    if line[1:].split("/")[0].split()[0] not in human:
                        get = True
                if get:
                    print(line.rstrip())
