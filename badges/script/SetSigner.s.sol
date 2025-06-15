// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28 <0.9.0;

import { BaseScript } from "./Base.s.sol";
import { BadgeMinter } from "../src/BadgeMinter.sol";

contract SetSignerScript is BaseScript {
    function run() public broadcast {
        // Get the BadgeMinter contract address from environment variable
        address minterAddress = vm.envAddress("BADGE_MINTER_ADDRESS");
        // Get the signer address from environment variable
        address signerAddress = vm.envAddress("BADGE_SIGNER_ADDRESS");
        
        // Get the BadgeMinter contract instance
        BadgeMinter minter = BadgeMinter(minterAddress);
        
        // Set the signer
        minter.setSigner(signerAddress);
    }
} 