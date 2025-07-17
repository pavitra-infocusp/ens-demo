// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IReverseRegistrar.sol";
import "./interfaces/IENSRegistry.sol";
import "./interfaces/IResolver.sol";

/**
 * @title ENS Reverse Registrar
 * @dev Implementation of the ENS Reverse Registrar, which manages
 * reverse resolution (address to name).
 */
contract ReverseRegistrar is IReverseRegistrar {
    // ENS registry
    IENSRegistry private _registry;
    
    // Default resolver
    IResolver private _defaultResolver;
    
    // Reverse registrar node (addr.reverse)
    bytes32 public constant ADDR_REVERSE_NODE = keccak256(abi.encodePacked(bytes32(0), keccak256("reverse")));
    
    // Constructor
    constructor(address registryAddress, address resolverAddress) {
        _registry = IENSRegistry(registryAddress);
        _defaultResolver = IResolver(resolverAddress);
        
        // Create the reverse node if it doesn't exist
        if (_registry.owner(ADDR_REVERSE_NODE) == address(0)) {
            _registry.setSubnodeOwner(bytes32(0), keccak256("reverse"), address(this));
        }
    }
    
    /**
     * @dev Returns the node hash for an address.
     * @param addr The address to query.
     * @return The node hash.
     */
    function node(address addr) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, keccak256(abi.encodePacked(addr))));
    }
    
    /**
     * @dev Sets the name for the calling address.
     * @param name The name to set.
     * @return The node hash.
     */
    function setName(string calldata name) public override returns (bytes32) {
        return claimForAddr(msg.sender, msg.sender, address(_defaultResolver), name);
    }
    
    /**
     * @dev Claims ownership of the reverse record for the calling address.
     * @param owner The address to set as the owner of the reverse record.
     * @return The node hash.
     */
    function claim(address owner) public override returns (bytes32) {
        return claimForAddr(msg.sender, owner, address(0), "");
    }
    
    /**
     * @dev Claims ownership of the reverse record for a specific address.
     * @param addr The address to claim.
     * @param owner The address to set as the owner of the reverse record.
     * @return The node hash.
     */
    function claimForAddr(address addr, address owner) public override returns (bytes32) {
        return claimForAddr(addr, owner, address(0), "");
    }
    
    /**
     * @dev Claims ownership of the reverse record for a specific address and sets a name.
     * @param addr The address to claim.
     * @param owner The address to set as the owner of the reverse record.
     * @param resolverAddr The resolver to use.
     * @param name The name to set.
     * @return The node hash.
     */
    function claimForAddr(address addr, address owner, address resolverAddr, string memory name) public returns (bytes32) {
        // Only the address owner or an authorized operator can claim the reverse record
        require(addr == msg.sender || _registry.owner(node(addr)) == msg.sender, "ReverseRegistrar: not authorized");
        
        bytes32 label = keccak256(abi.encodePacked(addr));
        bytes32 reverseNode = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        
        // Set the owner of the reverse record
        _registry.setSubnodeOwner(ADDR_REVERSE_NODE, label, owner);
        
        // Set the resolver if provided
        if (resolverAddr != address(0)) {
            _registry.setResolver(reverseNode, resolverAddr);
            
            // Set the name if provided
            if (bytes(name).length > 0) {
                IResolver(resolverAddr).setName(reverseNode, name);
                emit NameChanged(reverseNode, name);
            }
        }
        
        emit ReverseClaimed(addr, reverseNode);
        return reverseNode;
    }
    
    /**
     * @dev Sets the default resolver.
     * @param resolverAddr The address of the resolver.
     */
    function setDefaultResolver(address resolverAddr) public {
        require(_registry.owner(ADDR_REVERSE_NODE) == msg.sender, "ReverseRegistrar: not authorized");
        _defaultResolver = IResolver(resolverAddr);
    }
}