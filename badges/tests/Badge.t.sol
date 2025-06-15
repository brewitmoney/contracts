// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {BrewitBadge} from "../src/Badge.sol";
import {BadgeMinter} from "../src/BadgeMinter.sol";
import {BasicRenderer} from "../src/BasicRenderer.sol";
import {ITokenRenderer} from "../src/interfaces/ITokenRenderer.sol";
import {console2} from "forge-std/console2.sol";

contract BrewitBadgeTest is Test {
    BrewitBadge public badge;
    BadgeMinter public minter;
    BasicRenderer public renderer;
    address public owner;
    address public user1;
    address public user2;
    address public signer;

    // Test parameters
    string constant BASE_URI = "https://api.example.com/token/";
    string constant CONTRACT_URI = "https://api.example.com/contract";
    uint256 constant TOKEN_ID = 1;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        signer = makeAddr("signer");

        // Deploy contracts
        renderer = new BasicRenderer(owner, BASE_URI);
        badge = new BrewitBadge(ITokenRenderer(address(renderer)), owner, CONTRACT_URI);
        minter = new BadgeMinter(badge, owner);

        // Setup minter role
        badge.grantRoles(address(minter), badge.MINTER_ROLE());
        minter.setSigner(signer);
    }

    function _calculateDomainSeparator() internal view returns (bytes32) {
        bytes32 domainTypeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        
        // Calculate hashes for name and version
        bytes32 nameHash = keccak256(bytes("BadgeMinter"));
        bytes32 versionHash = keccak256(bytes("1"));
        
        return keccak256(
            abi.encode(
                domainTypeHash,
                nameHash,
                versionHash,
                block.chainid,
                address(minter)
            )
        );
    }

    function test_BasicSetup() public view {
        assertEq(badge.name(), "Brewit Badges");
        assertEq(badge.symbol(), "BREWIT_BADGE");
        assertEq(badge.contractURI(), CONTRACT_URI);
        assertEq(address(badge.renderer()), address(renderer));
    }

    function test_TokenURI() public view {
        string memory expectedURI = string.concat(BASE_URI, "1");
        assertEq(badge.uri(1), expectedURI);
    }

    function test_MintWithValidSignature() public {
        // Create signature
        bytes32 domainSeparator = _calculateDomainSeparator();
        bytes32 typeHash = minter.MINT_TYPEHASH();
        
        bytes32 structHash = keccak256(abi.encode(typeHash, user1, TOKEN_ID));
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );
        
        

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(keccak256(abi.encodePacked("signer"))), messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(user1);
        minter.mintBadge(user1, TOKEN_ID, signature);

        assertEq(badge.balanceOf(user1, TOKEN_ID), 1);
    }


    function test_RevertMintWithInvalidSignature() public {
        bytes memory invalidSignature = new bytes(65);
        
        vm.prank(user1);
        vm.expectRevert(BadgeMinter.InvalidSignature.selector);
        minter.mintBadge(user1, TOKEN_ID, invalidSignature);
    }

    function test_RevertSoulboundTransfer() public {
        // First mint a token - need to grant MINTER_ROLE to owner
        badge.grantRoles(owner, badge.MINTER_ROLE());
        
        vm.startPrank(owner);
        badge.mint(user1, TOKEN_ID);
        vm.stopPrank();

        // Try to transfer
        vm.startPrank(user1);
        vm.expectRevert(BrewitBadge.Soulbound.selector);
        badge.safeTransferFrom(user1, user2, TOKEN_ID, 1, "");
        vm.stopPrank();
    }

    function test_RevertDoubleMint() public {
        // Need to grant MINTER_ROLE to owner first
        badge.grantRoles(owner, badge.MINTER_ROLE());
        
        vm.startPrank(owner);
        badge.mint(user1, TOKEN_ID);
        
        vm.expectRevert(BrewitBadge.AlreadyMinted.selector);
        badge.mint(user1, TOKEN_ID);
        vm.stopPrank();
    }

    function test_UpdateRenderer() public {
        BasicRenderer newRenderer = new BasicRenderer(owner, "new-base-uri/");
        
        vm.startPrank(owner);
        badge.setRenderer(ITokenRenderer(address(newRenderer)));
        assertEq(address(badge.renderer()), address(newRenderer));
        vm.stopPrank();
    }

    function test_UpdateContractURI() public {
        string memory newURI = "https://new.example.com/contract";
        
        vm.startPrank(owner);
        badge.setContractURI(newURI);
        assertEq(badge.contractURI(), newURI);
        vm.stopPrank();
    }

    function test_RevertUnauthorizedMint() public {
        vm.prank(user1);
        vm.expectRevert();
        badge.mint(user1, TOKEN_ID);
    }

    function test_RevertUnauthorizedRendererUpdate() public {
        vm.prank(user1);
        vm.expectRevert();
        badge.setRenderer(ITokenRenderer(address(0)));
    }

    function test_BasicRendererCustomURI() public {
        string memory customURI = "ipfs://Qm123456";
        
        vm.startPrank(owner);
        renderer.setTokenURI(TOKEN_ID, customURI);
        assertEq(badge.uri(TOKEN_ID), customURI);
        vm.stopPrank();
    }

    function test_BasicRendererURISuffix() public {
        string memory suffix = ".json";
        
        vm.startPrank(owner);
        renderer.setURISuffix(suffix);
        assertEq(badge.uri(TOKEN_ID), string.concat(BASE_URI, "1", suffix));
        vm.stopPrank();
    }


}
