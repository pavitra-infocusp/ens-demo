// Contract ABIs for our simplified ENS contracts
export const ENS_REGISTRAR_ABI = [
  {
    "type": "function",
    "name": "register",
    "inputs": [
      {"name": "name", "type": "string"},
      {"name": "nameOwner", "type": "address"}
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "registerSubdomain",
    "inputs": [
      {"name": "subdomain", "type": "string"},
      {"name": "parentName", "type": "string"},
      {"name": "subdomainOwner", "type": "address"}
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "transfer",
    "inputs": [
      {"name": "name", "type": "string"},
      {"name": "newOwner", "type": "address"}
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "resolve",
    "inputs": [{"name": "name", "type": "string"}],
    "outputs": [{"name": "", "type": "address"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "reverseLookup",
    "inputs": [{"name": "addr", "type": "address"}],
    "outputs": [{"name": "", "type": "string"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "owner",
    "inputs": [{"name": "name", "type": "string"}],
    "outputs": [{"name": "", "type": "address"}],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "NameRegistered",
    "inputs": [
      {"name": "name", "type": "string", "indexed": true},
      {"name": "owner", "type": "address", "indexed": true}
    ]
  },
  {
    "type": "event",
    "name": "SubdomainRegistered",
    "inputs": [
      {"name": "subdomain", "type": "string", "indexed": true},
      {"name": "parentName", "type": "string", "indexed": true},
      {"name": "owner", "type": "address", "indexed": true}
    ]
  },
  {
    "type": "event",
    "name": "NameTransferred",
    "inputs": [
      {"name": "name", "type": "string", "indexed": true},
      {"name": "previousOwner", "type": "address", "indexed": true},
      {"name": "newOwner", "type": "address", "indexed": true}
    ]
  }
] as const;

// Contract addresses (these will be updated after deployment)
export const CONTRACT_ADDRESSES = {
  ENS_REGISTRAR: '0x0000000000000000000000000000000000000000', // Update after deployment
  ENS_REGISTRY: '0x0000000000000000000000000000000000000000',  // Update after deployment
  ENS_RESOLVER: '0x0000000000000000000000000000000000000000'   // Update after deployment
} as const;
