// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";

import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";

contract PoolManagerScript is Script {
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address signerAddr = vm.addr(privateKey);
        console.log("DEPLOYER=%s", signerAddr);

        vm.startBroadcast(privateKey);

        PoolManager manager = new PoolManager(500000);
        console.log("POOL_MANAGER=%s", address(manager));

        vm.stopBroadcast();
    }
}
