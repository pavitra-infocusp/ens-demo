// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ENSRegistry.sol";
import "../src/Registrar.sol";

contract RegistrarTest is Test {
    ENSRegistry public registry;
    Registrar public registrar;
    
    address public owner;
    address public user1;
    address public user2;
    
    bytes32 constant ROOT_NODE = bytes32(0);
    bytes32 constant ETH_LABEL = keccak256("eth");
    bytes32 constant ETH_NODE = keccak256(abi.encodePacked(ROOT_NODE, ETH_LABEL));
    
    string constant TEST_NAME = "test";
    bytes32 constant TEST_LABEL = keccak256("test");
    bytes32 constant TEST_NODE = keccak256(abi.encodePacked(ETH_NODE, TEST_LABEL));
    
    uint256 constant DEFAULT_PRICE = 1 ether / (365 days); // 1 ETH per year
    uint256 constant REGISTRATION_DURATION = 365 days;
    
    function setUp() public {
        owner = address(this);
        user1 = address(0x123);
        user2 = address(0x456);
        
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        
        registry = new ENSRegistry();
        
        // Create the .eth TLD
        registry.setSubnodeOwner(ROOT_NODE, ETH_LABEL, address(this));
        
        // Deploy the registrar
        registrar = new Registrar(address(registry), ETH_NODE, DEFAULT_PRICE);
        
        // Transfer ownership of the .eth TLD to the registrar
        registry.setOwner(ETH_NODE, address(registrar));
    }
    
    function testAvailable() public {
        assertTrue(registrar.available(TEST_NAME));
    }
    
    function testRegister() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        uint256 id = registrar.register{value: cost}(TEST_NAME, user1, REGISTRATION_DURATION);
        
        assertEq(registry.owner(TEST_NODE), user1);
        assertFalse(registrar.available(TEST_NAME));
        
        // Check that the ID is returned correctly
        assertEq(registrar.nameExpires(id), block.timestamp + REGISTRATION_DURATION);
    }
    
    function testRegisterWithExcessPayment() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        uint256 excess = 0.5 ether;
        
        uint256 balanceBefore = user1.balance;
        
        vm.prank(user1);
        registrar.register{value: cost + excess}(TEST_NAME, user1, REGISTRATION_DURATION);
        
        // Check that the excess payment was refunded
        assertEq(user1.balance, balanceBefore - cost);
    }
    
    function testRenew() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        uint256 id = registrar.register{value: cost}(TEST_NAME, user1, REGISTRATION_DURATION);
        
        uint256 expiresAt = block.timestamp + REGISTRATION_DURATION;
        assertEq(registrar.nameExpires(id), expiresAt);
        
        // Renew the registration
        vm.prank(user1);
        registrar.renew{value: cost}(TEST_NAME, REGISTRATION_DURATION);
        
        // Check that the expiration time was extended
        assertEq(registrar.nameExpires(id), expiresAt + REGISTRATION_DURATION);
    }
    
    function testFailRegisterUnavailable() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        registrar.register{value: cost}(TEST_NAME, user1, REGISTRATION_DURATION);
        
        // Try to register the same name again
        vm.prank(user2);
        registrar.register{value: cost}(TEST_NAME, user2, REGISTRATION_DURATION);
    }
    
    function testFailRegisterInsufficientPayment() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        registrar.register{value: cost - 0.1 ether}(TEST_NAME, user1, REGISTRATION_DURATION);
    }
    
    function testFailRenewUnregistered() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        registrar.renew{value: cost}(TEST_NAME, REGISTRATION_DURATION);
    }
    
    function testExpiration() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        registrar.register{value: cost}(TEST_NAME, user1, REGISTRATION_DURATION);
        
        // Fast forward past the expiration time
        vm.warp(block.timestamp + REGISTRATION_DURATION + 1);
        
        // The name should be available again
        assertTrue(registrar.available(TEST_NAME));
        
        // Another user should be able to register it
        vm.prank(user2);
        registrar.register{value: cost}(TEST_NAME, user2, REGISTRATION_DURATION);
        
        assertEq(registry.owner(TEST_NODE), user2);
    }
    
    function testSetPrice() public {
        uint256 newPrice = 2 ether / (365 days);
        registrar.setPrice(TEST_NAME, newPrice);
        
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        assertEq(cost, newPrice * REGISTRATION_DURATION);
    }
    
    function testFailSetPriceUnauthorized() public {
        uint256 newPrice = 2 ether / (365 days);
        
        vm.prank(user1);
        registrar.setPrice(TEST_NAME, newPrice);
    }
    
    function testWithdraw() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        registrar.register{value: cost}(TEST_NAME, user1, REGISTRATION_DURATION);
        
        uint256 balanceBefore = address(this).balance;
        
        registrar.withdraw();
        
        assertEq(address(this).balance, balanceBefore + cost);
        assertEq(address(registrar).balance, 0);
    }
    
    function testFailWithdrawUnauthorized() public {
        uint256 cost = registrar.rentPrice(TEST_NAME, REGISTRATION_DURATION);
        
        vm.prank(user1);
        registrar.register{value: cost}(TEST_NAME, user1, REGISTRATION_DURATION);
        
        vm.prank(user1);
        registrar.withdraw();
    }
    
    // Required to receive ETH refunds
    receive() external payable {}
}