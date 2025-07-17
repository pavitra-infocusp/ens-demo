// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IENSRegistry.sol";
import "./interfaces/IENSResolver.sol";

/**
 * @title ENSRegistrar
 * @dev An ENS registrar that focuses on core functionality:
 * - Register a name
 * - Register a subdomain
 * - Transfer a name
 * - Lookup from name to address
 * - Reverse lookup from address to name
 */
contract ENSRegistrar {
    IENSRegistry private _registry;
    IENSResolver private _resolver;
    bytes32 private _baseNode;

    // Mapping from name to owner for easy lookup
    mapping(string => address) private _nameToOwner;
    mapping(address => string) private _ownerToName;

    event NameRegistered(string indexed name, address indexed owner);
    event NameTransferred(string indexed name, address indexed from, address indexed to);
    event SubdomainRegistered(string indexed subdomain, string indexed parent, address indexed owner);

    constructor(address registryAddress, address resolverAddress, bytes32 baseNode) {
        _registry = IENSRegistry(registryAddress);
        _resolver = IENSResolver(resolverAddress);
        _baseNode = baseNode;
    }

    /**
     * @dev Register a name under the base node
     * @param name The name to register (e.g., "alice")
     * @param nameOwner The address that will own the name
     */
    function register(string calldata name, address nameOwner) external {
        bytes32 label = keccak256(bytes(name));
        bytes32 node = keccak256(abi.encodePacked(_baseNode, label));

        // First set the owner to the registrar temporarily
        _registry.setSubnodeOwner(_baseNode, label, address(this));

        // Set the resolver while we still own it
        _registry.setResolver(node, address(_resolver));

        // Set the address resolution
        _resolver.setAddr(node, nameOwner);

        // Now transfer ownership to the final owner
        _registry.setOwner(node, nameOwner);

        // Update our mappings
        _nameToOwner[name] = nameOwner;
        _ownerToName[nameOwner] = name;

        emit NameRegistered(name, nameOwner);
    }

    /**
     * @dev Register a subdomain under an existing name
     * @param subdomain The subdomain to register (e.g., "www")
     * @param parentName The parent name (e.g., "alice")
     * @param subdomainOwner The address that will own the subdomain
     */
    function registerSubdomain(string calldata subdomain, string calldata parentName, address subdomainOwner)
        external
    {
        // Check that the caller owns the parent name
        require(_nameToOwner[parentName] == msg.sender, "ENSRegistrar: not authorized");

        bytes32 parentLabel = keccak256(bytes(parentName));
        bytes32 parentNode = keccak256(abi.encodePacked(_baseNode, parentLabel));

        bytes32 subdomainLabel = keccak256(bytes(subdomain));
        bytes32 subdomainNode = keccak256(abi.encodePacked(parentNode, subdomainLabel));

        // First set the owner to the registrar temporarily
        _registry.setSubnodeOwner(parentNode, subdomainLabel, address(this));

        // Set the resolver while we still own it
        _registry.setResolver(subdomainNode, address(_resolver));

        // Set the address resolution
        _resolver.setAddr(subdomainNode, subdomainOwner);

        // Now transfer ownership to the final owner
        _registry.setOwner(subdomainNode, subdomainOwner);

        string memory fullName = string(abi.encodePacked(subdomain, ".", parentName));
        _nameToOwner[fullName] = subdomainOwner;

        emit SubdomainRegistered(subdomain, parentName, subdomainOwner);
    }

    /**
     * @dev Transfer ownership of a name
     * @param name The name to transfer
     * @param to The new owner
     */
    function transfer(string calldata name, address to) external {
        require(_nameToOwner[name] == msg.sender, "ENSRegistrar: not authorized");

        bytes32 label = keccak256(bytes(name));
        bytes32 node = keccak256(abi.encodePacked(_baseNode, label));

        // Update the registry
        _registry.setOwner(node, to);

        // Update the resolver
        _resolver.setAddr(node, to);

        // Update our mappings
        address from = _nameToOwner[name];
        _nameToOwner[name] = to;
        _ownerToName[from] = "";
        _ownerToName[to] = name;

        emit NameTransferred(name, from, to);
    }

    /**
     * @dev Lookup address from name
     * @param name The name to lookup
     * @return The address associated with the name
     */
    function resolve(string calldata name) external view returns (address) {
        bytes32 label = keccak256(bytes(name));
        bytes32 node = keccak256(abi.encodePacked(_baseNode, label));
        return _resolver.addr(node);
    }

    /**
     * @dev Reverse lookup: get name from address
     * @param addr The address to lookup
     * @return The name associated with the address
     */
    function reverseLookup(address addr) external view returns (string memory) {
        return _ownerToName[addr];
    }

    /**
     * @dev Get the owner of a name
     * @param name The name to lookup
     * @return The owner address
     */
    function owner(string calldata name) external view returns (address) {
        return _nameToOwner[name];
    }

    /**
     * @dev Check if a name is available
     * @param name The name to check
     * @return True if available, false otherwise
     */
    function available(string calldata name) external view returns (bool) {
        return _nameToOwner[name] == address(0);
    }
}
