// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IRegistrar.sol";
import "./interfaces/IENSRegistry.sol";
import "./interfaces/IResolver.sol";

/**
 * @title ENS Registrar
 * @dev Implementation of the ENS Registrar, which handles the registration
 * of domain names, including payment processing and expiration logic.
 */
contract Registrar is IRegistrar {
    // ENS registry
    IENSRegistry private _registry;
    
    // Base node for this registrar (e.g., eth)
    bytes32 private _baseNode;
    
    // Mapping from name hash to registration data
    struct Registration {
        address owner;
        uint256 expires;
        uint256 id;
    }
    
    // Mapping from label hash to registration
    mapping(bytes32 => Registration) private _registrations;
    
    // Mapping from name to price (0 means default price)
    mapping(string => uint256) private _prices;
    
    // Default price for registration (in wei per second)
    uint256 private _defaultPrice;
    
    // Minimum registration duration
    uint256 private constant MIN_REGISTRATION_DURATION = 28 days;
    
    // Maximum registration duration
    uint256 private constant MAX_REGISTRATION_DURATION = 365 days * 5;
    
    // Counter for registration IDs
    uint256 private _idCounter;
    
    /**
     * @dev Constructs a new Registrar.
     * @param registryAddress The address of the ENS registry.
     * @param baseNode The node under which names will be registered.
     * @param defaultPrice The default price per second for registration.
     */
    constructor(address registryAddress, bytes32 baseNode, uint256 defaultPrice) {
        _registry = IENSRegistry(registryAddress);
        _baseNode = baseNode;
        _defaultPrice = defaultPrice;
        
        // Ensure the registrar is the owner of the base node
        require(_registry.owner(baseNode) == address(this), "Registrar: not owner of base node");
    }
    
    /**
     * @dev Checks if a name is available for registration.
     * @param name The name to check.
     * @return True if the name is available, false otherwise.
     */
    function available(string calldata name) public view override returns (bool) {
        bytes32 label = keccak256(bytes(name));
        
        // Check if the name is registered and not expired
        if (_registrations[label].owner != address(0)) {
            return block.timestamp >= _registrations[label].expires;
        }
        
        return true;
    }
    
    /**
     * @dev Returns the expiration timestamp of a name.
     * @param id The ID of the name.
     * @return The timestamp when the name expires.
     */
    function nameExpires(uint256 id) public view override returns (uint256) {
        // Find the registration with the given ID
        bytes32 label = bytes32(0);
        for (uint256 i = 0; i < _idCounter; i++) {
            bytes32 currentLabel = bytes32(i);
            if (_registrations[currentLabel].id == id) {
                label = currentLabel;
                break;
            }
        }
        
        require(label != bytes32(0), "Registrar: name not found");
        return _registrations[label].expires;
    }
    
    /**
     * @dev Returns the cost of registering a name for a specified duration.
     * @param name The name to register.
     * @param duration The duration in seconds.
     * @return The cost in wei.
     */
    function rentPrice(string calldata name, uint256 duration) public view override returns (uint256) {
        uint256 price = _prices[name];
        if (price == 0) {
            price = _defaultPrice;
        }
        
        return price * duration;
    }
    
    /**
     * @dev Registers a name for a specified duration.
     * @param name The name to register.
     * @param owner The address that will own the name.
     * @param duration The duration in seconds.
     * @return The ID of the registered name.
     */
    function register(string calldata name, address owner, uint256 duration) public payable override returns (uint256) {
        require(available(name), "Registrar: name not available");
        require(duration >= MIN_REGISTRATION_DURATION, "Registrar: duration too short");
        require(duration <= MAX_REGISTRATION_DURATION, "Registrar: duration too long");
        
        uint256 cost = rentPrice(name, duration);
        require(msg.value >= cost, "Registrar: insufficient payment");
        
        bytes32 label = keccak256(bytes(name));
        bytes32 node = keccak256(abi.encodePacked(_baseNode, label));
        
        // If the name was previously registered but expired, update the registration
        if (_registrations[label].owner != address(0)) {
            require(block.timestamp >= _registrations[label].expires, "Registrar: name not expired");
            
            // Update the registration
            _registrations[label].owner = owner;
            _registrations[label].expires = block.timestamp + duration;
        } else {
            // Create a new registration
            _idCounter++;
            _registrations[label] = Registration({
                owner: owner,
                expires: block.timestamp + duration,
                id: _idCounter
            });
        }
        
        // Set the owner in the registry
        _registry.setSubnodeOwner(_baseNode, label, owner);
        
        // Refund any excess payment
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        
        emit NameRegistered(name, node, owner, cost, _registrations[label].expires);
        
        return _registrations[label].id;
    }
    
    /**
     * @dev Renews a name for a specified duration.
     * @param name The name to renew.
     * @param duration The duration in seconds.
     */
    function renew(string calldata name, uint256 duration) public payable override {
        bytes32 label = keccak256(bytes(name));
        require(_registrations[label].owner != address(0), "Registrar: name not registered");
        require(duration >= MIN_REGISTRATION_DURATION, "Registrar: duration too short");
        require(duration <= MAX_REGISTRATION_DURATION, "Registrar: duration too long");
        
        uint256 cost = rentPrice(name, duration);
        require(msg.value >= cost, "Registrar: insufficient payment");
        
        // Update the expiration time
        _registrations[label].expires += duration;
        
        // Refund any excess payment
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        
        bytes32 node = keccak256(abi.encodePacked(_baseNode, label));
        emit NameRenewed(name, node, cost, _registrations[label].expires);
    }
    
    /**
     * @dev Sets the price for a specific name.
     * @param name The name to set the price for.
     * @param price The price per second in wei.
     */
    function setPrice(string calldata name, uint256 price) public {
        require(msg.sender == _registry.owner(_baseNode), "Registrar: not authorized");
        _prices[name] = price;
        emit NamePriceChanged(name, price);
    }
    
    /**
     * @dev Sets the default price for registration.
     * @param price The default price per second in wei.
     */
    function setDefaultPrice(uint256 price) public {
        require(msg.sender == _registry.owner(_baseNode), "Registrar: not authorized");
        _defaultPrice = price;
    }
    
    /**
     * @dev Withdraws the contract balance to the owner of the base node.
     */
    function withdraw() public {
        address owner = _registry.owner(_baseNode);
        require(msg.sender == owner, "Registrar: not authorized");
        payable(owner).transfer(address(this).balance);
    }
}