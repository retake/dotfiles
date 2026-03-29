FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    less \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/claude"]
