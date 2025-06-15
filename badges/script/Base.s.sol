// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28 <0.9.0;

import { Script } from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    /// @dev Included to enable compilation of the script without a $PRIVATE_KEY environment variable.
    bytes32 internal constant TEST_PRIVATE_KEY = 0x0000000000000000000000000000000000000000000000000000000000000001;

    /// @dev Needed for the deterministic deployments.
    bytes32 internal constant ZERO_SALT = bytes32(0);

    /// @dev The address of the transaction broadcaster.
    address internal broadcaster;

    /// @dev Used to store the private key
    uint256 internal privateKey;

    /// @dev Initializes the transaction broadcaster:
    ///
    /// - If $ETH_FROM is defined, use it.
    /// - Otherwise, derive the broadcaster address from $PRIVATE_KEY.
    /// - If $PRIVATE_KEY is not defined, default to a test private key.
    constructor() {
        address from = vm.envOr({ name: "ETH_FROM", defaultValue: address(0) });
        if (from != address(0)) {
            broadcaster = from;
        } else {
            privateKey = uint256(vm.envOr({ 
                name: "PRIVATE_KEY", 
                defaultValue: TEST_PRIVATE_KEY 
            }));
            broadcaster = vm.addr(privateKey);
        }
    }

    modifier broadcast() {
        vm.startBroadcast(privateKey);
        _;
        vm.stopBroadcast();
    }
}
