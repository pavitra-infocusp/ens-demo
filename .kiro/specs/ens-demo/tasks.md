# Implementation Plan

- [x] 1. Set up project structure
  - Create the monorepo directory structure following the design document
  - Initialize git repository
  - Create initial README.md with project overview
  - _Requirements: 3.1_

- [ ] 2. Set up Foundry project for smart contracts
  - [ ] 2.1 Initialize Foundry project in the contracts directory
    - Run forge init to create the basic structure
    - Configure foundry.toml with appropriate settings
    - _Requirements: 3.2_
  
  - [ ] 2.2 Create interfaces for ENS contracts
    - Create IENSRegistry.sol interface
    - Create IRegistrar.sol interface
    - Create IResolver.sol interface
    - Create IReverseRegistrar.sol interface
    - _Requirements: 1.1_

- [ ] 3. Implement core ENS contracts
  - [ ] 3.1 Implement ENSRegistry contract
    - Implement owner, resolver, and TTL mappings
    - Implement setOwner, setSubnodeOwner, setResolver, and setTTL functions
    - Add appropriate events for state changes
    - Write unit tests for ENSRegistry
    - _Requirements: 1.1, 1.6_
  
  - [ ] 3.2 Implement Resolver contract
    - Implement address and name resolution functionality
    - Implement setAddr and setName functions
    - Implement supportsInterface for ERC-165 compliance
    - Write unit tests for Resolver
    - _Requirements: 1.4, 1.5, 1.6_
  
  - [ ] 3.3 Implement Registrar contract
    - Implement domain registration with payment
    - Implement domain renewal functionality
    - Implement expiration logic
    - Implement availability checking
    - Write unit tests for Registrar
    - _Requirements: 1.2, 1.7_
  
  - [ ] 3.4 Implement ReverseRegistrar contract
    - Implement reverse lookup functionality
    - Implement setName function for setting reverse records
    - Write unit tests for ReverseRegistrar
    - _Requirements: 1.5_

- [ ] 4. Create deployment and seeding scripts
  - [ ] 4.1 Create Deploy.s.sol script
    - Implement script to deploy all contracts in the correct order
    - Set up initial ENS registry configuration
    - _Requirements: 1.1_
  
  - [ ] 4.2 Create Seed.s.sol script
    - Implement script to register example domains
    - Set up example resolvers and records
    - _Requirements: 1.8_

- [ ] 5. Set up React frontend project
  - [ ] 5.1 Initialize React project with TypeScript
    - Create project using Create React App or Vite
    - Configure TypeScript
    - Set up project structure following the design
    - _Requirements: 2.1, 3.3_
  
  - [ ] 5.2 Set up Viem and Wagmi integration
    - Install Viem and Wagmi libraries
    - Configure Wagmi for wallet connections
    - Create contract interaction utilities with Viem
    - _Requirements: 2.6, 2.9_

- [ ] 6. Implement frontend core components
  - [ ] 6.1 Implement WalletConnector component
    - Create component for connecting to MetaMask or other wallets
    - Implement account display and connection status
    - Add disconnect functionality
    - _Requirements: 2.1, 2.6_
  
  - [ ] 6.2 Implement DomainRegistration component
    - Create form for domain registration
    - Implement name availability checking
    - Implement registration transaction submission
    - Add loading and success/error states
    - _Requirements: 2.2, 2.7, 2.8_
  
  - [ ] 6.3 Implement DomainManager component
    - Create component to display owned domains
    - Implement domain selection functionality
    - Create domain details view
    - _Requirements: 2.3_
  
  - [ ] 6.4 Implement SubdomainCreator component
    - Create form for subdomain creation
    - Implement subdomain creation transaction submission
    - Add loading and success/error states
    - _Requirements: 2.3, 1.3_
  
  - [ ] 6.5 Implement NameLookup component
    - Create form for forward resolution (name to address)
    - Create form for reverse resolution (address to name)
    - Display resolution results
    - _Requirements: 2.4, 2.5_
  
  - [ ] 6.6 Implement TransactionMonitor component
    - Create component to display pending transactions
    - Implement transaction status tracking
    - Display success/error messages
    - _Requirements: 2.7, 2.8_

- [ ] 7. Implement frontend data hooks
  - [ ] 7.1 Implement Wagmi hooks for wallet connection
    - Configure Wagmi client and providers
    - Use Wagmi's useAccount and useConnect hooks
    - Set up network detection and switching
    - _Requirements: 2.1, 2.6_
  
  - [ ] 7.2 Implement ENS contract interactions with Viem
    - Create custom hooks using Viem for contract interactions
    - Implement domain registration, renewal, and management functions
    - Implement name resolution functions
    - _Requirements: 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 7.3 Implement useTransactions hook
    - Create hook for transaction tracking
    - Implement transaction submission and monitoring
    - Store transaction history
    - _Requirements: 2.7, 2.8_

- [ ] 8. Implement utility functions
  - [ ] 8.1 Implement namehash utility
    - Create function to convert domain names to ENS node hashes
    - Add validation for domain name format
    - _Requirements: 1.4, 2.4_
  
  - [ ] 8.2 Implement formatters and validators
    - Create functions for formatting addresses and names
    - Implement input validation functions
    - _Requirements: 2.2, 2.4, 2.5_

- [ ] 9. Set up Docker environment
  - [-] 9.1 Create Dockerfile for Anvil
    - Create Dockerfile for running Anvil node
    - Configure persistent storage for blockchain state
    - _Requirements: 4.1, 4.5_
  
  - [ ] 9.2 Create Dockerfile for frontend
    - Create Dockerfile for running React development server
    - Configure hot-reloading
    - _Requirements: 4.2, 5.3_
  
  - [ ] 9.3 Create docker-compose.yml
    - Configure services for Anvil, contract deployment, and frontend
    - Set up networking between containers
    - Configure environment variables
    - Set up shared volumes
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.6, 4.7_

- [ ] 10. Create helper scripts
  - [ ] 10.1 Create setup.sh script
    - Implement script to install dependencies for both contracts and frontend
    - _Requirements: 3.4_
  
  - [ ] 10.2 Create deploy-contracts.sh script
    - Implement script to build and deploy contracts to local node
    - _Requirements: 5.5_
  
  - [ ] 10.3 Create update-abis.sh script
    - Implement script to copy contract ABIs to frontend
    - _Requirements: 3.5_
  
  - [ ] 10.4 Create start-dev.sh script
    - Implement script to start the development environment
    - _Requirements: 5.2_

- [ ] 11. Write comprehensive documentation
  - [ ] 11.1 Update README.md with detailed instructions
    - Add project overview
    - Add setup instructions
    - Add usage instructions
    - Add development workflow
    - _Requirements: 5.1_
  
  - [ ] 11.2 Add code comments and documentation
    - Add comments to smart contracts
    - Add comments to frontend components
    - Create API documentation
    - _Requirements: 5.1, 5.7_

# Frontend testing skipped for this learning project

- [ ] 13. Implement responsive design
  - [ ] 13.1 Add responsive styles
    - Implement mobile-friendly layout
    - Test on different screen sizes
    - _Requirements: 5.6_
  
  - [ ] 13.2 Add loading indicators and error messages
    - Implement loading spinners for async operations
    - Create user-friendly error messages
    - _Requirements: 2.7, 2.8_