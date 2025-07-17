// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ENS Registry Interface
 * @dev Interface for the ENS Registry contract, which is the core contract that maintains
 * the mapping of domain names to owners and resolvers.
 */
interface IENSRegistry {
    // Events
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
    event Transfer(bytes32 indexed node, address owner);
    event NewResolver(bytes32 indexed node, address resolver);
    event NewTTL(bytes32 indexed node, uint64 ttl);

    // View functions
    /**
     * @dev Returns the owner of the specified node.
     * @param node The node to query.
     * @return The address of the owner.
     */
    function owner(bytes32 node) external view returns (address);

    /**
     * @dev Returns the resolver for the specified node.
     * @param node The node to query.
     * @return The address of the resolver.
     */
    function resolver(bytes32 node) external view returns (address);

    /**
     * @dev Returns the time-to-live (TTL) of the specified node.
     * @param node The node to query.
     * @return The TTL of the node.
     */
    function ttl(bytes32 node) external view returns (uint64);

    // State-changing functions
    /**
     * @dev Sets the owner of the specified node.
     * @param node The node to update.
     * @param owner The address of the new owner.
     */
    function setOwner(bytes32 node, address owner) external;

    /**
     * @dev Sets the owner of a subnode.
     * @param node The parent node.
     * @param label The hash of the label specifying the subnode.
     * @param owner The address of the new owner.
     * @return The created node hash.
     */
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns (bytes32);

    /**
     * @dev Sets the resolver for the specified node.
     * @param node The node to update.
     * @param resolver The address of the resolver.
     */
    function setResolver(bytes32 node, address resolver) external;

    /**
     * @dev Sets the TTL for the specified node.
     * @param node The node to update.
     * @param ttl The TTL in seconds.
     */
    function setTTL(bytes32 node, uint64 ttl) external;
}
