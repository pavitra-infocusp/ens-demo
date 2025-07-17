# ENS Demo Project

A learning project that implements a simplified version of the Ethereum Name Service (ENS) with smart contracts and a React frontend.

## Overview

This project demonstrates how ENS works by implementing core ENS features:
- Domain registration and management
- Subdomain creation
- Forward resolution (name to address)
- Reverse resolution (address to name)

The project is structured as a monorepo containing both the smart contracts (built with Foundry) and a React-based frontend, with Docker Compose configuration for easy deployment.

## Project Structure

```
ens-demo/
├── contracts/           # Foundry project for smart contracts
│   ├── src/             # Contract source code
│   ├── test/            # Contract tests
│   └── script/          # Deployment and seeding scripts
├── frontend/            # React frontend application
│   ├── public/          # Static assets
│   └── src/             # Frontend source code
├── docker/              # Docker configuration
│   ├── anvil/           # Anvil (local Ethereum node) configuration
│   └── foundry/         # Foundry configuration for Docker
└── scripts/             # Helper scripts for development
```

## Features

- **Smart Contracts**
  - ENS Registry for domain ownership management
  - Registrar for domain registration and renewal
  - Resolver for name resolution
  - Reverse Registrar for reverse lookups

- **Frontend**
  - Wallet connection
  - Domain registration and management
  - Subdomain creation
  - Name lookup (forward and reverse resolution)
  - Transaction monitoring

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Node.js and npm (for local development)
- Foundry (for local contract development)

### Quick Start

1. Clone the repository
   ```
   git clone https://github.com/yourusername/ens-demo.git
   cd ens-demo
   ```

2. Start the application using Docker Compose
   ```
   docker-compose up
   ```

3. Open your browser and navigate to `http://localhost:3000`

## Development

For detailed development instructions, see the [Development Guide](./DEVELOPMENT.md).

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.