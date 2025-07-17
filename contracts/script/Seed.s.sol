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
        // Read deployment addresses from the JSON file
        string memory addressesFile = vm.readFile("../frontend/src/ENSContracts/addresses.json");

        // Parse JSON to get contract addresses
        address registryAddress = vm.parseJsonAddress(addressesFile, ".ENSRegistry");
        address resolverAddress = vm.parseJsonAddress(addressesFile, ".ENSResolver");
        address registrarAddress = vm.parseJsonAddress(addressesFile, ".ENSRegistrar");

        // Get contract instances
        ENSRegistry registry = ENSRegistry(registryAddress);
        ENSResolver resolver = ENSResolver(resolverAddress);
        ENSRegistrar registrar = ENSRegistrar(registrarAddress);

        // Start broadcasting transactions (uses private key from command line)
        vm.startBroadcast();

        // Register example domains with the simplified registrar
        for (uint256 i = 0; i < exampleDomains.length; i++) {
            string memory name = exampleDomains[i];
            address recordAddress = address(uint160(0x1000 + i));

            // Register the domain (simplified - no payment required)
            registrar.register(name, recordAddress);
            console.log("Registered domain:", string(abi.encodePacked(name, ".eth")), "to:", recordAddress);
        }

        // Stop broadcasting transactions
        vm.stopBroadcast();

        console.log("Seeding completed successfully");
    }
}
