FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app

# Create a directory for persistent data
RUN mkdir -p /data

# Expose the default Anvil port
EXPOSE 8545

# Set the entrypoint to anvil
ENTRYPOINT ["anvil"]

# Default command arguments
CMD ["--host", "0.0.0.0"]