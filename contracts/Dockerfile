# Use the latest foundry image
FROM ghcr.io/foundry-rs/foundry:latest

# Set working directory
WORKDIR /app

# Copy our source code into the container
COPY . .

# Build and test the source code
RUN forge build
RUN forge test

# Set the default command
ENTRYPOINT ["forge"]