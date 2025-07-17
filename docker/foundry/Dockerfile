FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app

# Install dependencies
RUN apk add --no-cache bash curl jq

# Copy scripts
COPY ./scripts /app/scripts

# Set entrypoint to bash
ENTRYPOINT ["/bin/bash"]