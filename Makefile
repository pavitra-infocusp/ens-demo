# Makefile for ENS Demo contracts using Docker

# Default RPC URL for local development
RPC_URL ?= http://localhost:8545

# Docker image name
IMAGE_NAME = ens-contracts

.PHONY: build test deploy seed all clean

# Build Docker image
build-image:
	@echo "Building Docker image..."
	@docker build -t $(IMAGE_NAME) ./contracts

# Build contracts
build: build-image
	@echo "Building contracts..."
	@docker run --rm $(IMAGE_NAME) build

# Run tests
test: build-image
	@echo "Running tests..."
	@docker run --rm $(IMAGE_NAME) test

# Deploy contracts
deploy: build-image
	@echo "Deploying contracts..."
	@docker run --rm $(IMAGE_NAME) script script/Deploy.s.sol --rpc-url $(RPC_URL) --broadcast
	@echo "Contracts deployed successfully."
	@echo "Copying ABIs to frontend..."
	@mkdir -p frontend/src/abis
	@cp -r contracts/out/*.json frontend/src/abis/

# Seed with example data
seed: build-image
	@echo "Seeding with example data..."
	@docker run --rm $(IMAGE_NAME) script script/Seed.s.sol --rpc-url $(RPC_URL) --broadcast

# Build, test, deploy, and seed
all: build test deploy seed

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@docker run --rm -v $(PWD):/app $(IMAGE_NAME) clean