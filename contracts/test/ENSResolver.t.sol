// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ENSRegistry.sol";
import "../src/ENSResolver.sol";

contract ENSResolverTest is Test {
    ENSRegistry public registry;
    ENSResolver public resolver;
    
    address public owner;
    address public newOwner;
    address public addrValue;
    
    bytes32 constant ROOT_NODE = bytes32(0);
    bytes32 constant TEST_LABEL = keccak256("test");
    bytes32 constant TEST_NODE = keccak256(abi.encodePacked(ROOT_NODE, TEST_LABEL));
    string constant TEST_NAME = "test.eth";
    
    function setUp() public {
        owner = address(this);
        newOwner = address(0x123);
        addrValue = address(0x456);
        
        registry = new ENSRegistry();
        resolver = new ENSResolver(address(registry));
        
        // Set up the resolver for the root node
        registry.setResolver(ROOT_NODE, address(resolver));
        
        // Create a test node
        registry.setSubnodeOwner(ROOT_NODE, TEST_LABEL, owner);
        registry.setResolver(TEST_NODE, address(resolver));
    }
    
    function testSetAddr() public {
        resolver.setAddr(TEST_NODE, addrValue);
        assertEq(resolver.addr(TEST_NODE), addrValue);
    }
    
    function testSetName() public {
        resolver.setName(TEST_NODE, TEST_NAME);
        assertEq(resolver.name(TEST_NODE), TEST_NAME);
    }
    
    function testSupportsInterface() public {
        // Test addr interface
        assertTrue(resolver.supportsInterface(0x3b3b57de));
        
        // Test name interface
        assertTrue(resolver.supportsInterface(0x691f3431));
        
        // Test IResolver interface
        assertTrue(resolver.supportsInterface(type(IResolver).interfaceId));
        
        // Test unsupported interface
        assertFalse(resolver.supportsInterface(0x12345678));
    }
    
    function test_Revert_When_UnauthorizedSetAddr() public {
        vm.prank(address(0x789));
        vm.expectRevert("Resolver: caller is not authorized");
        resolver.setAddr(TEST_NODE, addrValue);
    }
    
    function test_Revert_When_UnauthorizedSetName() public {
        vm.prank(address(0x789));
        vm.expectRevert("Resolver: caller is not authorized");
        resolver.setName(TEST_NODE, TEST_NAME);
    }
    
    function testAuthorizedAfterOwnerChange() public {
        // Transfer ownership
        registry.setOwner(TEST_NODE, newOwner);
        
        // Try to set addr as original owner (should fail)
        vm.expectRevert("Resolver: caller is not authorized");
        resolver.setAddr(TEST_NODE, addrValue);
        
        // Set addr as new owner (should succeed)
        vm.prank(newOwner);
        resolver.setAddr(TEST_NODE, addrValue);
        assertEq(resolver.addr(TEST_NODE), addrValue);
    }
}