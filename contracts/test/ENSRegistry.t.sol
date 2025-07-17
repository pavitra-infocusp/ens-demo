// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ENSRegistry.sol";

contract ENSRegistryTest is Test {
    ENSRegistry public registry;
    address public owner;
    address public newOwner;
    address public resolver;
    
    bytes32 constant ROOT_NODE = bytes32(0);
    bytes32 constant TEST_LABEL = keccak256("test");
    bytes32 constant TEST_NODE = keccak256(abi.encodePacked(ROOT_NODE, TEST_LABEL));
    
    function setUp() public {
        owner = address(this);
        newOwner = address(0x123);
        resolver = address(0x456);
        
        registry = new ENSRegistry();
    }
    
    function testRootOwner() public {
        assertEq(registry.owner(ROOT_NODE), owner);
    }
    
    function testSetOwner() public {
        registry.setOwner(ROOT_NODE, newOwner);
        assertEq(registry.owner(ROOT_NODE), newOwner);
    }
    
    function testSetSubnodeOwner() public {
        bytes32 node = registry.setSubnodeOwner(ROOT_NODE, TEST_LABEL, newOwner);
        assertEq(node, TEST_NODE);
        assertEq(registry.owner(node), newOwner);
    }
    
    function testSetResolver() public {
        registry.setResolver(ROOT_NODE, resolver);
        assertEq(registry.resolver(ROOT_NODE), resolver);
    }
    
    function testSetTTL() public {
        uint64 ttlValue = 3600;
        registry.setTTL(ROOT_NODE, ttlValue);
        assertEq(registry.ttl(ROOT_NODE), ttlValue);
    }
    
    function testFailSetOwnerUnauthorized() public {
        vm.prank(address(0x789));
        registry.setOwner(ROOT_NODE, newOwner);
    }
    
    function testFailSetSubnodeOwnerUnauthorized() public {
        vm.prank(address(0x789));
        registry.setSubnodeOwner(ROOT_NODE, TEST_LABEL, newOwner);
    }
    
    function testFailSetResolverUnauthorized() public {
        vm.prank(address(0x789));
        registry.setResolver(ROOT_NODE, resolver);
    }
    
    function testFailSetTTLUnauthorized() public {
        vm.prank(address(0x789));
        registry.setTTL(ROOT_NODE, 3600);
    }
}