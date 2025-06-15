// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.28 <0.9.0;

import {  BrewitBadge      } from "../src/Badge.sol";
import { BaseScript } from "./Base.s.sol";
import "forge-std/console2.sol";
import { ITokenRenderer } from "../src/interfaces/ITokenRenderer.sol";
import { BasicRenderer } from "../src/BasicRenderer.sol";
import { BadgeMinter } from "../src/BadgeMinter.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public {
        // Try deploying to multiple networks
        // vm.createSelectFork("base");
        // console2.log("Deploying to Base");
        // deployToNetwork("base");

        vm.createSelectFork("polygon");
        console2.log("Deploying to Polygon");
        deployToNetwork("polygon");

        // Add more networks as needed
    }


    function deployToNetwork(string memory network) internal returns (BrewitBadge badge) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deploying from", deployer);
        
        // First deploy the renderer
        bytes32 salt = bytes32(uint256(137));

        vm.startBroadcast(deployerPrivateKey);
        BasicRenderer renderer = new BasicRenderer{salt: salt}(
            deployer,                    // Owner
            "https://api.brewit.money/badges/"  // Base URI
        );
        console2.log("Renderer deployed to:", address(renderer));
        
        // Get exact bytecode including constructor params for badge
        bytes memory creationCode = abi.encodePacked(
            type(BrewitBadge).creationCode,
            abi.encode(
                ITokenRenderer(address(renderer)), // Use deployed renderer
                deployer,                         // Owner
                "https://assets.brewit.money/badges/contract.json" // Contract URI
            )
        );
        
        address predictedAddress = computeCreate2Address(deployer, salt, creationCode);
        console2.log("Predicted badge address:", predictedAddress);
        
        badge = new BrewitBadge{salt: salt}(
            ITokenRenderer(address(renderer)),
            deployer,
            "https://assets.brewit.money/badges/contract.json"
        );
        console2.log("Badge deployed to:", address(badge));
        
        // Deploy minter contract
        BadgeMinter minter = new BadgeMinter{salt: salt}(badge, deployer);
        console2.log("Minter deployed to:", address(minter));
        
        // Setup minter role
        badge.grantRoles(address(minter), badge.MINTER_ROLE());
        
        // require(address(badge) == predictedAddress, "Deployed address doesn't match prediction");
        
        vm.stopBroadcast();

        // Log deployment info
        string memory fileName = string.concat(
            "./deployments/",
            network,
            "_",
            vm.toString(block.number),
            ".json"
        );
        
        string memory deployment = "deployment";
        vm.serializeAddress(deployment, "badge", address(badge));
        vm.serializeAddress(deployment, "renderer", address(renderer));
        vm.serializeAddress(deployment, "minter", address(minter));
        vm.serializeAddress(deployment, "deployer", deployer);
        vm.serializeUint(deployment, "chainId", block.chainid);
        vm.serializeUint(deployment, "blockNumber", block.number);
        vm.writeJson(deployment, fileName);
    }

    error NoSuitableSaltFound();

    function findSaltForZeros(address deployer, uint256 numZeros) internal pure returns (bytes32) {
        bytes memory bytecode = abi.encodePacked(
            type(BrewitBadge).creationCode,
            abi.encode(deployer)  // Include constructor params
        );
        
        uint256 maxAttempts = 100000000;
        
        for (uint256 i = 0; i < maxAttempts; i++) {
            bytes32 salt = bytes32(i);
            address predictedAddress = computeAddress(deployer, salt, bytecode);
            // console2.log("Predicted address:", predictedAddress);
            
            // Convert address to uint to check hex digits
            uint160 addrInt = uint160(predictedAddress);
            bool isValid = true;
            
            // Each hex digit is 4 bits, so we need to check 2*numZeros nibbles
            for (uint256 j = 0; j < numZeros * 2; j++) {
                // Extract the rightmost nibble and shift right
                if ((addrInt >> (156 - (j * 4))) & 0xF != 0) {
                    isValid = false;
                    break;
                }
            }
            
            if (isValid) {
                return salt;
            }
        }
        
        revert NoSuitableSaltFound();
    }
    
    function computeAddress(address deployer, bytes32 salt, bytes memory bytecode) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            deployer,
            salt,
            keccak256(bytecode)
        )))));
    }

    function computeCreate2Address(address deployer, bytes32 salt, bytes memory bytecode) internal pure returns
     (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            deployer,
            salt,
            keccak256(bytecode)
        )))));
    }

    function hasZeroPrefix(address addr, uint256 numZeros) internal pure returns (bool) {
        bytes20 addrBytes = bytes20(addr);
        
        // Check if the first numZeros bytes are zero
        for (uint256 i = 0; i < numZeros; i++) {
            if (uint8(addrBytes[i]) != 0) {
                return false;
            }
        }
        
        return true;
    }
}