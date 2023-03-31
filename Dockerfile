FROM ubuntu:22.04

WORKDIR /opt

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq -y && apt-get upgrade -qq -y && \
    apt-get install -y  \
      build-essential \
      pigz \
      python3 &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD python_lib .

ENV PATH=/opt:${PATH}
