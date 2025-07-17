// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ENSRegistry.sol";
import "../src/ENSResolver.sol";
import "../src/ENSRegistrar.sol";

/**
 * @title ENS Seeding Script
 * @dev Script to register example domains and set up example resolvers and records.
 */
contract SeedScript is Script {
    // Constants for node hashes
    bytes32 constant ROOT_NODE = bytes32(0);
    bytes32 constant ETH_LABEL = keccak256("eth");
    bytes32 constant ETH_NODE = keccak256(abi.encodePacked(ROOT_NODE, ETH_LABEL));
    
    // Example domain names
    string[] exampleDomains = ["example", "test", "demo", "user1", "user2"];
    
    // Registration duration (1 year)
    uint256 constant REGISTRATION_DURATION = 365 days;
    
    function run() public {
        // Read deployment addresses from the file
        string memory deploymentFile = vm.readFile("./deployment.txt");
        address registryAddress = _parseAddress(deploymentFile, "ENSRegistry=");
        address resolverAddress = _parseAddress(deploymentFile, "ENSResolver=");
        address registrarAddress = _parseAddress(deploymentFile, "ENSRegistrar=");
        
        // Get the private key from the environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Get contract instances
        ENSRegistry registry = ENSRegistry(registryAddress);
        ENSResolver resolver = ENSResolver(resolverAddress);
        ENSRegistrar registrar = ENSRegistrar(registrarAddress);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Register example domains with the simplified registrar
        for (uint i = 0; i < exampleDomains.length; i++) {
            string memory name = exampleDomains[i];
            address recordAddress = address(uint160(0x1000 + i));
            
            // Register the domain (simplified - no payment required)
            registrar.register(name, recordAddress);
            console.log("Registered domain:", string(abi.encodePacked(name, ".eth")), "to:", recordAddress);
            
            // Create a subdomain for each example domain
            string memory subName = "sub";
            address subAddress = address(uint160(0x2000 + i));
            
            // Register subdomain (only the owner can do this)
            vm.prank(recordAddress);
            registrar.registerSubdomain(subName, name, subAddress);
            console.log("Created subdomain:", string(abi.encodePacked(subName, ".", name, ".eth")), "to:", subAddress);
        }
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
        
        console.log("Seeding completed successfully");
    }
    
    /**
     * @dev Parse an address from a string.
     * @param source The source string.
     * @param key The key to look for.
     * @return The parsed address.
     */
    function _parseAddress(string memory source, string memory key) internal pure returns (address) {
        // Find the key in the source string
        bytes memory sourceBytes = bytes(source);
        bytes memory keyBytes = bytes(key);
        
        uint256 i = 0;
        bool found = false;
        
        while (i + keyBytes.length <= sourceBytes.length) {
            bool found_match = true;
            for (uint256 j = 0; j < keyBytes.length; j++) {
                if (sourceBytes[i + j] != keyBytes[j]) {
                    found_match = false;
                    break;
                }
            }
            
            if (found_match) {
                found = true;
                i += keyBytes.length;
                break;
            }
            
            i++;
        }
        
        require(found, "Key not found in source string");
        
        // Extract the address (42 characters including 0x)
        bytes memory addressBytes = new bytes(42);
        for (uint256 j = 0; j < 42; j++) {
            addressBytes[j] = sourceBytes[i + j];
        }
        
        // Convert to address
        return vm.parseAddress(string(addressBytes));
    }
}