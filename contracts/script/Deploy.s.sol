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
        // Start broadcasting transactions (uses private key from command line)
        vm.startBroadcast();

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
        bytes32 ethNode = registry.setSubnodeOwner(ROOT_NODE, ETH_LABEL, address(registrar));
        console.log("Created .eth TLD and transferred ownership to the registrar");

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log deployment addresses for extraction
        console.log("DEPLOYMENT_ADDRESSES:");
        console.log(
            string(
                abi.encodePacked(
                    '{"ENSRegistry":"',
                    vm.toString(address(registry)),
                    '",',
                    '"ENSResolver":"',
                    vm.toString(address(resolver)),
                    '",',
                    '"ENSRegistrar":"',
                    vm.toString(address(registrar)),
                    '"}'
                )
            )
        );
    }
}
