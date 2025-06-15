// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import { WebAuthnValidator } from "src/WebAuthnValidator.sol";

import "forge-std/console2.sol";

interface IRegistry {
    function deployModule(
        bytes32 salt,
        bytes32 resolverUID,
        bytes calldata initCode,
        bytes calldata metadata,
        bytes calldata resolverContext
    )
        external
        payable
        returns (address moduleAddress);

    function calcModuleAddress(
        bytes32 salt,
        bytes calldata initCode
    )
        external
        view
        returns (address);
}

struct Deployments {
    address ownableValidator;
    address ownableExecutor;
    address autosavings;
    address flashloanCallback;
    address flashloanLender;
    address coldStorageHook;
    address coldStorageFlashloan;
    address deadmanSwitch;
    address hookMultiPlexer;
    address multiFactor;
    address registryHook;
    address scheduledOrders;
    address scheduledTransfers;
    address socialRecovery;
    address deployer;
    bytes32 salt;
}

library Inspect {
    function isContract(address _addr) internal returns (bool _isContract) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}

/**
 * @title Deploy
 * @author @kopy-kat
 */
contract DeployScript is Script {
    using Inspect for address;

    address registry = 0x000000000069E2a187AEFFb852bF3cCdC95151B2;
    IRegistry _registry = IRegistry(registry);

    function run() public {


        // Sepolia
        // vm.createSelectFork("sepolia");
        // console2.log("Deploying to Sepolia");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on Sepolia");
        
        // Base Sepolia
        // vm.createSelectFork("basesepolia");
        // console2.log("Deploying to Base sepolia");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on Base sepolia");
        
        // Mainnet
        vm.createSelectFork("mainnet");
        console2.log("Deploying to Mainnet");
        if (registry.isContract()) deploy();
        else console2.log("Registry not deployed on Mainnet");
        // Base 
        // vm.createSelectFork("base");
        // console2.log("Deploying to Base");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on Base");

        // Polygon
        // vm.createSelectFork("polygon");
        // console2.log("Deploying to Polygon");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on Polygon");

        // Optimism
        // vm.createSelectFork("optimism");
        // console2.log("Deploying to Optimism");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on Optimism");

        // Arbitrum
        // vm.createSelectFork("arbitrum");
        // console2.log("Deploying to Arbitrum");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on Arbitrum");
        
        // BNB Smart Chain
        // vm.createSelectFork("bnbsmartchain");
        // console2.log("Deploying to BNB Smart Chain");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on BNB Smart Chain");

        // Gnosis Chain
        // vm.createSelectFork("gnosis");
        // console2.log("Deploying to Gnosis Chain");
        // if (registry.isContract()) deploy();
        // else console2.log("Registry not deployed on Gnosis Chain");

    }

    function deploy() public {
        bytes32 salt = bytes32(0x0000000000000000000000000000000000000000000000000000000000007579);
        bytes32 resolverUID =
            bytes32(0xDBCA873B13C783C0C9C6DDFC4280E505580BF6CC3DAC83F8A0F7B44ACAAFCA4F);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        Deployments memory env;

        env.deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        env.salt = salt;

        env.ownableValidator =
            _registryDeploy(salt, resolverUID, type(WebAuthnValidator).creationCode, "", "");
        vm.stopBroadcast();

        // _logJson(env);
    }

    function _registryDeploy(
        bytes32 salt,
        bytes32 resolverUID,
        bytes memory initCode,
        bytes memory metadata,
        bytes memory resolverContext
    )
        internal
        returns (address module)
    {
        module = _registry.calcModuleAddress(salt, initCode);
        console2.log("Module:",module);

        if (!module.isContract()) {
            address temp =
                _registry.deployModule(salt, resolverUID, initCode, metadata, resolverContext);

            require(temp == module, "DeployScript: Mismatching module address");
        }
    }

    // function _logJson(Deployments memory env) internal {
    //     string memory root = "some key";
    //     vm.serializeUint(root, "chainId", block.chainid);
    //     vm.serializeAddress(root, "broadcastEOA", env.deployer);

    //     string memory deployments = "deployments";

    //     string memory item = "OwnableValidator";
    //     vm.serializeAddress(item, "address", env.ownableValidator);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "ownableValidator", item);

    //     item = "OwnableExecutor";
    //     vm.serializeAddress(item, "address", env.ownableExecutor);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "ownableExecutor", item);

    //     item = "ColdStorageHook";
    //     vm.serializeAddress(item, "address", env.coldStorageHook);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);

    //     vm.serializeString(deployments, "coldStorageHook", item);

    //     item = "ColdStorageFlashloan";
    //     vm.serializeAddress(item, "address", env.coldStorageFlashloan);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "coldStorageFlashloan", item);

    //     item = "DeadmanSwitch";
    //     vm.serializeAddress(item, "address", env.deadmanSwitch);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "deadmanSwitch", item);

    //     item = "HookMultiPlexer";
    //     vm.serializeAddress(item, "address", env.hookMultiPlexer);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "hookMultiPlexer", item);

    //     item = "MultiFactor";
    //     vm.serializeAddress(item, "address", env.multiFactor);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "multiFactor", item);

    //     item = "RegistryHook";
    //     vm.serializeAddress(item, "address", env.registryHook);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "registryHook", item);

    //     item = "AutoSavings";
    //     vm.serializeAddress(item, "address", env.autosavings);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "autoSavings", item);

    //     item = "ScheduledOrders";
    //     vm.serializeAddress(item, "address", env.scheduledOrders);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "scheduledOrders", item);

    //     item = "ScheduledTransfers";
    //     vm.serializeAddress(item, "address", env.scheduledTransfers);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "scheduledTransfers", item);

    //     item = "SocialRecovery";
    //     vm.serializeAddress(item, "address", env.socialRecovery);
    //     vm.serializeBytes32(item, "salt", env.salt);
    //     vm.serializeAddress(item, "deployer", env.deployer);
    //     item = vm.serializeAddress(item, "factory", registry);
    //     vm.serializeString(deployments, "socialRecovery", item);

    //     string memory output = vm.serializeUint(deployments, "timestamp", block.timestamp);
    //     string memory finalJson = vm.serializeString(root, "deployments", output);

    //     string memory fileName =
    //         string(abi.encodePacked("./deployments/", Strings.toString(block.chainid), ".json"));
    //     console2.log("Writing to file: ", fileName);

    //     vm.writeJson(finalJson, fileName);
    // }
}