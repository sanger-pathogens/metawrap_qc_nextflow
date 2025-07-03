FROM ubuntu:22.04

WORKDIR /opt

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq -y && apt-get upgrade -qq -y && \
    apt-get --no-install-recommends --no-install-suggests install -y \
      build-essential=12.9ubuntu3 \
      pigz=2.6-1 \
      python3=3.10.6-1~22.04.1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY python_lib .

ENV PATH=/opt:${PATH}

# Create a non-root appuser (UID = 1001) belonging to group appgroup (GID = 1001)
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -s /bin/bash -m appuser

# Set permissions on the working directory (adjust as needed)
RUN chown -R appuser:appgroup /opt

# Switch to the non-root user
USER appuser