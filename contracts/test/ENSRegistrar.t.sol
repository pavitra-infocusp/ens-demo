// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ENSRegistry.sol";
import "../src/ENSResolver.sol";
import "../src/ENSRegistrar.sol";

contract ENSRegistrarTest is Test {
    ENSRegistry public registry;
    ENSResolver public resolver;
    ENSRegistrar public registrar;
    
    // Test addresses
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    
    // Constants
    bytes32 constant ROOT_NODE = bytes32(0);
    bytes32 constant ETH_LABEL = keccak256("eth");
    bytes32 constant ETH_NODE = keccak256(abi.encodePacked(ROOT_NODE, ETH_LABEL));
    
    function setUp() public {
        // Deploy contracts
        registry = new ENSRegistry();
        resolver = new ENSResolver(address(registry));
        registrar = new ENSRegistrar(address(registry), address(resolver), ETH_NODE);
        
        // Set up the .eth domain - first create it, then give it to the registrar
        registry.setSubnodeOwner(ROOT_NODE, ETH_LABEL, address(this));
        registry.setOwner(ETH_NODE, address(registrar));
    }
    
    function testRegisterName() public {
        // Register "alice.eth" to alice
        registrar.register("alice", alice);
        
        // Verify ownership
        assertEq(registrar.owner("alice"), alice);
        assertEq(registrar.available("alice"), false);
        
        // Verify resolution
        assertEq(registrar.resolve("alice"), alice);
        assertEq(registrar.reverseLookup(alice), "alice");
    }
    
    function testRegisterSubdomain() public {
        // First register "alice.eth" to alice
        registrar.register("alice", alice);
        
        // Alice registers "www.alice.eth" to bob
        vm.prank(alice);
        registrar.registerSubdomain("www", "alice", bob);
        
        // Verify subdomain ownership
        assertEq(registrar.owner("www.alice"), bob);
    }
    
    function testTransferName() public {
        // Register "alice.eth" to alice
        registrar.register("alice", alice);
        
        // Alice transfers to bob
        vm.prank(alice);
        registrar.transfer("alice", bob);
        
        // Verify transfer
        assertEq(registrar.owner("alice"), bob);
        assertEq(registrar.resolve("alice"), bob);
        assertEq(registrar.reverseLookup(bob), "alice");
        assertEq(registrar.reverseLookup(alice), ""); // Alice no longer has a name
    }
    
    function testLookupNameToAddress() public {
        // Register multiple names
        registrar.register("alice", alice);
        registrar.register("bob", bob);
        registrar.register("charlie", charlie);
        
        // Test lookups
        assertEq(registrar.resolve("alice"), alice);
        assertEq(registrar.resolve("bob"), bob);
        assertEq(registrar.resolve("charlie"), charlie);
    }
    
    function testReverseLookupAddressToName() public {
        // Register multiple names
        registrar.register("alice", alice);
        registrar.register("bob", bob);
        registrar.register("charlie", charlie);
        
        // Test reverse lookups
        assertEq(registrar.reverseLookup(alice), "alice");
        assertEq(registrar.reverseLookup(bob), "bob");
        assertEq(registrar.reverseLookup(charlie), "charlie");
    }
    
    function testCompleteWorkflow() public {
        // 1. Register "alice.eth"
        registrar.register("alice", alice);
        
        // 2. Alice registers subdomain "www.alice.eth"
        vm.prank(alice);
        registrar.registerSubdomain("www", "alice", bob);
        
        // 3. Alice transfers main domain to charlie
        vm.prank(alice);
        registrar.transfer("alice", charlie);
        
        // 4. Verify final state
        assertEq(registrar.owner("alice"), charlie);
        assertEq(registrar.owner("www.alice"), bob);
        assertEq(registrar.resolve("alice"), charlie);
        assertEq(registrar.reverseLookup(charlie), "alice");
        assertEq(registrar.reverseLookup(alice), ""); // Alice no longer owns a name
    }
    
    function test_Revert_When_UnauthorizedSubdomainRegistration() public {
        // Register "alice.eth" to alice
        registrar.register("alice", alice);
        
        // Bob tries to register subdomain without authorization
        vm.prank(bob);
        vm.expectRevert("ENSRegistrar: not authorized");
        registrar.registerSubdomain("www", "alice", bob);
    }
    
    function test_Revert_When_UnauthorizedTransfer() public {
        // Register "alice.eth" to alice
        registrar.register("alice", alice);
        
        // Bob tries to transfer alice's name
        vm.prank(bob);
        vm.expectRevert("ENSRegistrar: not authorized");
        registrar.transfer("alice", bob);
    }
}
