// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ENSRegistry.sol";
import "../src/ENSResolver.sol";
import "../src/ENSRegistrar.sol";

/**
 * @title ENS Deployment Script
 * @dev Script to deploy all ENS contracts in the correct order and set up initial configuration.
 */
contract DeployScript is Script {
    // Constants for node hashes
    bytes32 constant ROOT_NODE = bytes32(0);
    bytes32 constant ETH_LABEL = keccak256("eth");
    bytes32 constant ETH_NODE = keccak256(abi.encodePacked(ROOT_NODE, ETH_LABEL));
    
    function run() public {
        // Get the private key from the environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ENS Registry
        ENSRegistry registry = new ENSRegistry();
        console.log("ENSRegistry deployed at:", address(registry));
        
        // Deploy ENSResolver with the registry address
        ENSResolver resolver = new ENSResolver(address(registry));
        console.log("ENSResolver deployed at:", address(resolver));
        
        // Deploy ENSRegistrar for .eth
        ENSRegistrar registrar = new ENSRegistrar(address(registry), address(resolver), ETH_NODE);
        console.log("ENSRegistrar deployed at:", address(registrar));
        
        // Create the .eth TLD and give it to the registrar
        registry.setSubnodeOwner(ROOT_NODE, ETH_LABEL, msg.sender);
        registry.setOwner(ETH_NODE, address(registrar));
        console.log("Created .eth TLD and transferred ownership to the registrar");
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
        
        // Save the deployment addresses to a file
        string memory deploymentInfo = string(abi.encodePacked(
            "ENSRegistry=", vm.toString(address(registry)), "\n",
            "ENSResolver=", vm.toString(address(resolver)), "\n",
            "ENSRegistrar=", vm.toString(address(registrar))
        ));
        
        vm.writeFile("./deployment.txt", deploymentInfo);
        console.log("Deployment information saved to deployment.txt");
    }
}