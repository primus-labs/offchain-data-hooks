// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../src/hook/volume/ExchangeVolumeHook.sol";

import "forge-std/Script.sol";
import {ExchangeVolumeHook} from "../../src/hook/volume/ExchangeVolumeHook.sol";

import {IAttestationRegistry} from "../../src/IAttestationRegistry.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {console} from "forge-std/console.sol";
import {HookMiner} from "v4-periphery/src/utils/HookMiner.sol";

//source .env
//forge script script/hook/DeployHook.s.sol:DeployHookScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

contract DeployHookScript is Script {
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address signerAddr = vm.addr(privateKey);
        console.log("SIGNER=%s", signerAddr);

        vm.startBroadcast(privateKey);

        _deploy();

        vm.stopBroadcast();
    }

    function _deploy() internal {
        address _poolManager = vm.envAddress("POOL_MANAGER");
        console.log("_poolManager=%s", _poolManager);
        address contractOwner = vm.envAddress("CONTRACT_OWNER");
        // Log
        console.log("CONTRACT_OWNER=%s", contractOwner);
        address attestationRegistry = vm.envAddress("ATTESTATION_REGISTRY");
        console.log("ATTESTATION_REGISTRY=%s", attestationRegistry);

        PoolManager poolManager = PoolManager(_poolManager);
        console.log("POOL_MANAGER=%s", address(poolManager));
        IAttestationRegistry iAttestationRegistry = IAttestationRegistry(attestationRegistry);
        console.log("ATTESTATION_REGISTRY=%s", address(iAttestationRegistry));

        //
        uint160 flags = uint160(
            Hooks.AFTER_INITIALIZE_FLAG |
            Hooks.BEFORE_SWAP_FLAG
        );

        bytes memory constructorArgs = abi.encode(poolManager, iAttestationRegistry, contractOwner);
        // Mine a salt that will produce a hook address with the correct flags
        (address hookAddress, bytes32 salt) =
                            HookMiner.find(CREATE2_DEPLOYER, flags, type(ExchangeVolumeHook).creationCode, constructorArgs);
        console.log("hookAddress=%s", hookAddress);
        // Deploy the hook using CREATE2
//        console.log("salt=%s",salt);
        ExchangeVolumeHook exchangeHook = new ExchangeVolumeHook{salt: salt}(poolManager, iAttestationRegistry, contractOwner);

        console.log("HOOK=%s", address(exchangeHook));

//
//        console.log("Deploy VOLUME Hook");
//        address hook = factory.mineDeploy(poolManager, iAttestationRegistry, contractOwner);
//        console.log("VOLUME_HOOK=%s", hook);
//        console.log("HOOK=%s", address(hook));
    }
}
