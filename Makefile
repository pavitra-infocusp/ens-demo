# Makefile for ENS Demo contracts using Forge/Anvil

# Default RPC URL for local development
RPC_URL ?= http://localhost:8545

# Default private key for local development
PRIVATE_KEY ?= 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

.PHONY: anvil deploy seed all clean build

# Start Anvil local node
anvil:
	@echo "Starting Anvil..."
	@anvil --host 0.0.0.0 --port 8545

# Build contracts
build:
	@echo "Building contracts..."
	@cd contracts && forge build

# Deploy contracts
deploy: build
	@echo "Deploying contracts..."
	@cd contracts && forge script script/Deploy.s.sol --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 2>&1 | tee deploy.log
	@echo "Extracting contract addresses..."
	@grep 'DEPLOYMENT_ADDRESSES:' -A 1 contracts/deploy.log | tail -1 > frontend/src/ENSContracts/addresses.json || echo '{}' > frontend/src/ENSContracts/addresses.json
	@rm -f contracts/deploy.log
	@echo "Contracts deployed successfully."

# Seed contracts with test data
seed: build
	@echo "Seeding contracts..."
	@cd contracts && forge script script/Seed.s.sol --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

# Build, test, deploy, and seed
all: deploy seed

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@cd contracts && forge clean
