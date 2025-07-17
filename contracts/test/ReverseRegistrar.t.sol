// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ENSRegistry.sol";
import "../src/Resolver.sol";
import "../src/ReverseRegistrar.sol";

contract ReverseRegistrarTest is Test {
    ENSRegistry public registry;
    Resolver public resolver;
    ReverseRegistrar public reverseRegistrar;
    
    address public owner;
    address public user1;
    address public user2;
    
    bytes32 constant ROOT_NODE = bytes32(0);
    bytes32 constant REVERSE_LABEL = keccak256("reverse");
    bytes32 constant REVERSE_NODE = keccak256(abi.encodePacked(ROOT_NODE, REVERSE_LABEL));
    
    function setUp() public {
        owner = address(this);
        user1 = address(0x123);
        user2 = address(0x456);
        
        registry = new ENSRegistry();
        resolver = new Resolver(address(registry));
        reverseRegistrar = new ReverseRegistrar(address(registry), address(resolver));
        
        // Set the reverse registrar as the owner of the reverse node
        registry.setSubnodeOwner(ROOT_NODE, REVERSE_LABEL, address(reverseRegistrar));
    }
    
    function testNode() public {
        bytes32 expectedNode = keccak256(abi.encodePacked(
            reverseRegistrar.ADDR_REVERSE_NODE(),
            keccak256(abi.encodePacked(user1))
        ));
        
        assertEq(reverseRegistrar.node(user1), expectedNode);
    }
    
    function testClaim() public {
        vm.prank(user1);
        bytes32 node = reverseRegistrar.claim(user1);
        
        assertEq(registry.owner(node), user1);
    }
    
    function testClaimForAddr() public {
        vm.prank(user1);
        bytes32 node = reverseRegistrar.claimForAddr(user1, user2);
        
        assertEq(registry.owner(node), user2);
    }
    
    function testSetName() public {
        string memory name = "user1.eth";
        
        vm.prank(user1);
        bytes32 node = reverseRegistrar.setName(name);
        
        assertEq(registry.owner(node), user1);
        assertEq(registry.resolver(node), address(resolver));
        assertEq(resolver.name(node), name);
    }
    
    function testFailClaimForAddrUnauthorized() public {
        vm.prank(user1);
        reverseRegistrar.claimForAddr(user2, user1);
    }
    
    function testClaimForAddrAfterOwnership() public {
        // First, user1 claims their own reverse record
        vm.prank(user1);
        bytes32 node = reverseRegistrar.claim(user1);
        
        // Then, user1 transfers ownership to user2
        vm.prank(user1);
        registry.setOwner(node, user2);
        
        // Now user2 should be able to update the record
        vm.prank(user2);
        reverseRegistrar.claimForAddr(user1, user2, address(resolver), "user2.eth");
        
        assertEq(resolver.name(node), "user2.eth");
    }
    
    function testSetDefaultResolver() public {
        address newResolver = address(0x789);
        
        reverseRegistrar.setDefaultResolver(newResolver);
        
        // We can't directly test the private variable, but we can test the behavior
        vm.prank(user1);
        bytes32 node = reverseRegistrar.setName("test.eth");
        
        assertEq(registry.resolver(node), newResolver);
    }
    
    function testFailSetDefaultResolverUnauthorized() public {
        address newResolver = address(0x789);
        
        vm.prank(user1);
        reverseRegistrar.setDefaultResolver(newResolver);
    }
}