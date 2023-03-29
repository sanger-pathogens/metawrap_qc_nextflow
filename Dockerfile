FROM ubuntu:22.04

WORKDIR /opt

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq -y && apt-get upgrade -qq -y && \
    apt-get install -y  \
      build-essential \
      pigz \
      python3 \
      python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install pytest

ADD python_lib .

WORKDIR /opt/tests
# run tests
RUN python3 -m pytest .

WORKDIR /opt

ENV PATH=/opt:${PATH}
