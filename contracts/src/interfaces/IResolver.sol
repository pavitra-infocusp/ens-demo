// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ENS Resolver Interface
 * @dev Interface for the ENS Resolver contract, which stores and provides
 * resolution data for domain names.
 */
interface IResolver {
    // Events
    event AddrChanged(bytes32 indexed node, address addr);
    event NameChanged(bytes32 indexed node, string name);

    // View functions
    /**
     * @dev Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) external view returns (address);

    /**
     * @dev Returns the name associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) external view returns (string memory);

    /**
     * @dev Checks if the resolver supports a specific interface.
     * @param interfaceID The ID of the interface to check.
     * @return True if the interface is supported, false otherwise.
     */
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);

    // State-changing functions
    /**
     * @dev Sets the address associated with an ENS node.
     * @param node The ENS node to update.
     * @param addr The address to set.
     */
    function setAddr(bytes32 node, address addr) external;

    /**
     * @dev Sets the name associated with an ENS node.
     * @param node The ENS node to update.
     * @param name The name to set.
     */
    function setName(bytes32 node, string calldata name) external;
}
