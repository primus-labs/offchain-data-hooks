// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {MockEAS} from "../src/mocks/MockEAS.sol";
import {MockEASProxy} from "../src/mocks/MockEASProxy.sol";
import {ISchemaRegistry} from "../src/hooks/ISchemaRegistry.sol";

import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";

contract EASScript is Script {
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address signerAddr = vm.addr(privateKey);
        console.log("DEPLOYER=%s", signerAddr);

        vm.startBroadcast(privateKey);

        // It's just a test. It doesn't matter.
        ISchemaRegistry sr = ISchemaRegistry(address(this));

        MockEAS eas = new MockEAS(sr);
        console.log("EAS_ADDRESS=%s", address(eas));

        MockEASProxy easproxy = new MockEASProxy();
        console.log("EASPROXY_ADDRESS=%s", address(easproxy));

        vm.stopBroadcast();
    }
}
