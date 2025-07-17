#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read deployment info from contracts directory
const deploymentInfoPath = path.join(__dirname, '../contracts/deployment-info.json');
const contractsPath = path.join(__dirname, 'src/contracts.ts');

if (!fs.existsSync(deploymentInfoPath)) {
  console.error('Deployment info file not found. Please deploy contracts first.');
  process.exit(1);
}

const deploymentInfo = JSON.parse(fs.readFileSync(deploymentInfoPath, 'utf8'));

// Read current contracts.ts file
let contractsContent = fs.readFileSync(contractsPath, 'utf8');

// Update contract addresses
contractsContent = contractsContent.replace(
  /ENS_REGISTRAR: '[^']*'/,
  `ENS_REGISTRAR: '${deploymentInfo.ENSRegistrar}'`
);

contractsContent = contractsContent.replace(
  /ENS_REGISTRY: '[^']*'/,
  `ENS_REGISTRY: '${deploymentInfo.ENSRegistry}'`
);

contractsContent = contractsContent.replace(
  /ENS_RESOLVER: '[^']*'/,
  `ENS_RESOLVER: '${deploymentInfo.ENSResolver}'`
);

// Write updated file
fs.writeFileSync(contractsPath, contractsContent);

console.log('Contract addresses updated successfully!');
console.log('ENS Registry:', deploymentInfo.ENSRegistry);
console.log('ENS Resolver:', deploymentInfo.ENSResolver);
console.log('ENS Registrar:', deploymentInfo.ENSRegistrar);
