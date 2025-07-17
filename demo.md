# ENS Demo - Core Functionality

This simplified ENS demo showcases the core functionality of the Ethereum Name Service using clean, focused contracts:

## Contract Structure
- **ENSRegistry** - Core ENS registry for domain ownership
- **ENSResolver** - Resolves names to addresses and vice versa  
- **ENSRegistrar** - Simplified registrar for core functionality

## Features Implemented

### 1. Register a Name
```solidity
registrar.register("alice", aliceAddress);
```
- Registers "alice.eth" to the specified address
- Sets up resolution from name to address
- Sets up reverse resolution from address to name

### 2. Register a Subdomain
```solidity
// Alice can create subdomains under her name
registrar.registerSubdomain("www", "alice", bobAddress);
```
- Creates "www.alice.eth" owned by Bob
- Only the owner of the parent domain can create subdomains

### 3. Transfer a Name
```solidity
// Alice transfers her name to Bob
registrar.transfer("alice", bobAddress);
```
- Transfers ownership of "alice.eth" to Bob
- Updates both forward and reverse resolution

### 4. Lookup Name to Address
```solidity
address owner = registrar.resolve("alice");
```
- Returns the address that owns "alice.eth"

### 5. Reverse Lookup Address to Name
```solidity
string memory name = registrar.reverseLookup(aliceAddress);
```
- Returns the name owned by the given address

## Test Results

All core functionality tests pass:
- ✅ Register names
- ✅ Register subdomains
- ✅ Transfer names
- ✅ Forward resolution (name → address)
- ✅ Reverse resolution (address → name)
- ✅ Authorization checks
- ✅ Complete workflow integration

## Running the Demo

```bash
# Build and test
make build

# Run specific tests
cd contracts && forge test --match-contract ENSRegistrarTest -vv

# Run all tests
cd contracts && forge test -v
```

The simplified implementation removes complex features like:
- Pricing and payments
- Expiration dates
- Complex authorization hierarchies
- Reverse registrar complexity

This focuses on the core ENS functionality that demonstrates how decentralized naming works.
