FROM ubuntu:22.04

WORKDIR /opt

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq -y && apt-get upgrade -qq -y && \
    apt-get install -y \
      build-essential \
      pigz \
      python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD python_lib .

ENV PATH=/opt:${PATH}

# Create a non-root appuser (UID = 1001) belonging to group appgroup (GID = 1001)
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -s /bin/bash -m appuser

# Set permissions on the working directory/software
RUN chown -R appuser:appgroup /opt

# Switch to the non-root user
USER appuser