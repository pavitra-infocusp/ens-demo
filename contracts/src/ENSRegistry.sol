// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IENSRegistry.sol";

/**
 * @title ENS Registry
 * @dev Implementation of the ENS Registry, the core contract that maintains
 * the mapping of domain names to owners and resolvers.
 */
contract ENSRegistry is IENSRegistry {
    // Mapping from node to owner
    mapping(bytes32 => address) private _owners;
    
    // Mapping from node to resolver
    mapping(bytes32 => address) private _resolvers;
    
    // Mapping from node to TTL
    mapping(bytes32 => uint64) private _ttls;

    /**
     * @dev Constructs a new ENS registry.
     */
    constructor() {
        // Set the owner of the root node (0x0) to the deployer
        _owners[0x0] = msg.sender;
    }

    /**
     * @dev Returns the owner of the specified node.
     * @param node The node to query.
     * @return The address of the owner.
     */
    function owner(bytes32 node) public view override returns (address) {
        return _owners[node];
    }

    /**
     * @dev Returns the resolver for the specified node.
     * @param node The node to query.
     * @return The address of the resolver.
     */
    function resolver(bytes32 node) public view override returns (address) {
        return _resolvers[node];
    }

    /**
     * @dev Returns the time-to-live (TTL) of the specified node.
     * @param node The node to query.
     * @return The TTL of the node.
     */
    function ttl(bytes32 node) public view override returns (uint64) {
        return _ttls[node];
    }

    /**
     * @dev Sets the owner of the specified node.
     * @param node The node to update.
     * @param ownerAddress The address of the new owner.
     */
    function setOwner(bytes32 node, address ownerAddress) public override {
        _validateOwnership(node);
        _owners[node] = ownerAddress;
        emit Transfer(node, ownerAddress);
    }

    /**
     * @dev Sets the owner of a subnode.
     * @param node The parent node.
     * @param label The hash of the label specifying the subnode.
     * @param ownerAddress The address of the new owner.
     * @return The created node hash.
     */
    function setSubnodeOwner(bytes32 node, bytes32 label, address ownerAddress) public override returns (bytes32) {
        _validateOwnership(node);
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        _owners[subnode] = ownerAddress;
        emit NewOwner(node, label, ownerAddress);
        return subnode;
    }

    /**
     * @dev Sets the resolver for the specified node.
     * @param node The node to update.
     * @param resolverAddress The address of the resolver.
     */
    function setResolver(bytes32 node, address resolverAddress) public override {
        _validateOwnership(node);
        _resolvers[node] = resolverAddress;
        emit NewResolver(node, resolverAddress);
    }

    /**
     * @dev Sets the TTL for the specified node.
     * @param node The node to update.
     * @param ttlValue The TTL in seconds.
     */
    function setTTL(bytes32 node, uint64 ttlValue) public override {
        _validateOwnership(node);
        _ttls[node] = ttlValue;
        emit NewTTL(node, ttlValue);
    }

    /**
     * @dev Validates that the sender is the owner of the node.
     * @param node The node to validate.
     */
    function _validateOwnership(bytes32 node) internal view {
        address nodeOwner = _owners[node];
        require(nodeOwner == msg.sender, "ENSRegistry: caller is not the owner");
    }
}