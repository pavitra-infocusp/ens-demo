// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IResolver.sol";
import "./interfaces/IENSRegistry.sol";

/**
 * @title ENS Resolver
 * @dev Implementation of the ENS Resolver, which stores and provides
 * resolution data for domain names.
 */
contract ENSResolver is IResolver {
    // ENS registry
    IENSRegistry private _registry;
    
    // Mapping from node to address
    mapping(bytes32 => address) private _addresses;
    
    // Mapping from node to name
    mapping(bytes32 => string) private _names;
    
    // Interface IDs
    bytes4 private constant ADDR_INTERFACE_ID = 0x3b3b57de; // addr(bytes32)
    bytes4 private constant NAME_INTERFACE_ID = 0x691f3431; // name(bytes32)
    
    /**
     * @dev Constructs a new Resolver.
     * @param registryAddress The address of the ENS registry.
     */
    constructor(address registryAddress) {
        _registry = IENSRegistry(registryAddress);
    }
    
    /**
     * @dev Modifier to check if the sender is authorized to manage the node.
     * @param node The node to check.
     */
    modifier authorizedFor(bytes32 node) {
        address nodeOwner = _registry.owner(node);
        require(nodeOwner == msg.sender, "Resolver: caller is not authorized");
        _;
    }
    
    /**
     * @dev Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) public view override returns (address) {
        return _addresses[node];
    }
    
    /**
     * @dev Returns the name associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) public view override returns (string memory) {
        return _names[node];
    }
    
    /**
     * @dev Sets the address associated with an ENS node.
     * @param node The ENS node to update.
     * @param addrValue The address to set.
     */
    function setAddr(bytes32 node, address addrValue) public override authorizedFor(node) {
        _addresses[node] = addrValue;
        emit AddrChanged(node, addrValue);
    }
    
    /**
     * @dev Sets the name associated with an ENS node.
     * @param node The ENS node to update.
     * @param nameValue The name to set.
     */
    function setName(bytes32 node, string calldata nameValue) public override authorizedFor(node) {
        _names[node] = nameValue;
        emit NameChanged(node, nameValue);
    }
    
    /**
     * @dev Checks if the resolver supports a specific interface.
     * @param interfaceID The ID of the interface to check.
     * @return True if the interface is supported, false otherwise.
     */
    function supportsInterface(bytes4 interfaceID) public pure override returns (bool) {
        return interfaceID == ADDR_INTERFACE_ID || 
               interfaceID == NAME_INTERFACE_ID || 
               interfaceID == type(IResolver).interfaceId;
    }
}