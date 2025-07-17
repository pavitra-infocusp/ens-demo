// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ENS Reverse Registrar Interface
 * @dev Interface for the ENS Reverse Registrar contract, which manages
 * reverse resolution (address to name).
 */
interface IReverseRegistrar {
    // Events
    event ReverseClaimed(address indexed addr, bytes32 indexed node);
    event NameChanged(bytes32 indexed node, string name);

    // View functions
    /**
     * @dev Returns the node hash for an address.
     * @param addr The address to query.
     * @return The node hash.
     */
    function node(address addr) external pure returns (bytes32);

    // State-changing functions
    /**
     * @dev Sets the name for the calling address.
     * @param name The name to set.
     * @return The node hash.
     */
    function setName(string calldata name) external returns (bytes32);

    /**
     * @dev Claims ownership of the reverse record for the calling address.
     * @param owner The address to set as the owner of the reverse record.
     * @return The node hash.
     */
    function claim(address owner) external returns (bytes32);

    /**
     * @dev Claims ownership of the reverse record for a specific address.
     * @param addr The address to claim.
     * @param owner The address to set as the owner of the reverse record.
     * @return The node hash.
     */
    function claimForAddr(address addr, address owner) external returns (bytes32);
}