// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolManager} from "v4-core/src/PoolManager.sol";

import {ExchangeVolumeHook} from "../../src/hook/volume/ExchangeVolumeHook.sol";
import {IAttestationRegistry} from "../../src/IAttestationRegistry.sol";

import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";

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
        // Log
        console.log("ATTESTATION_REGISTRY=%s", attestationRegistry);

        PoolManager poolManager = PoolManager(_poolManager);
        IAttestationRegistry iAttestationRegistry = IAttestationRegistry(attestationRegistry);
        ExchangeVolumeHook hook = new ExchangeVolumeHook(poolManager, iAttestationRegistry, contractOwner);
        console.log("HOOK=%s", address(hook));
    }
}
/*
source .env
forge script script/DeployHook.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
*/
