// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ENS Registrar Interface
 * @dev Interface for the ENS Registrar contract, which handles the registration
 * of domain names, including payment processing and expiration logic.
 */
interface IRegistrar {
    // Events
    event NameRegistered(string name, bytes32 indexed node, address indexed owner, uint256 cost, uint256 expires);
    event NameRenewed(string name, bytes32 indexed node, uint256 cost, uint256 expires);
    event NamePriceChanged(string name, uint256 price);

    // View functions
    /**
     * @dev Checks if a name is available for registration.
     * @param name The name to check.
     * @return True if the name is available, false otherwise.
     */
    function available(string calldata name) external view returns (bool);

    /**
     * @dev Returns the expiration timestamp of a name.
     * @param id The ID of the name.
     * @return The timestamp when the name expires.
     */
    function nameExpires(uint256 id) external view returns (uint256);

    /**
     * @dev Returns the cost of registering a name for a specified duration.
     * @param name The name to register.
     * @param duration The duration in seconds.
     * @return The cost in wei.
     */
    function rentPrice(string calldata name, uint256 duration) external view returns (uint256);

    // State-changing functions
    /**
     * @dev Registers a name for a specified duration.
     * @param name The name to register.
     * @param owner The address that will own the name.
     * @param duration The duration in seconds.
     * @return The ID of the registered name.
     */
    function register(string calldata name, address owner, uint256 duration) external payable returns (uint256);

    /**
     * @dev Renews a name for a specified duration.
     * @param name The name to renew.
     * @param duration The duration in seconds.
     */
    function renew(string calldata name, uint256 duration) external payable;
}