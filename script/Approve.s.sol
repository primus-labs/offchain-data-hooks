// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {PositionManager} from "v4-periphery/src/PositionManager.sol";
import {IPermit2Forwarder} from "v4-periphery/src/interfaces/IPermit2Forwarder.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";

import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";

contract DeployTokenScript is Script {
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

    // prettier-ignore
    function _deploy() internal {
        address _token0 = vm.envAddress("TOKEN0");
        console.log("_token0=%s", _token0);
        address _token1 = vm.envAddress("TOKEN1");
        console.log("_token1=%s", _token1);
        address payable _positionManager = payable(vm.envAddress("POSITION_MANAGER"));
        console.log("_positionManager=%s", _positionManager);
        address _universalRouter = vm.envAddress("UNIVERSAL_ROUTER");
        console.log("_universalRouter=%s", _universalRouter);
        PositionManager positionManager = PositionManager(_positionManager);
//        UniversalRouter universalRouter = UniversalRouter(payable(_universalRouter));
        IAllowanceTransfer permit2 = positionManager.permit2();

        MockERC20 token0 = MockERC20(_token0);
        MockERC20 token1 = MockERC20(_token1);

        // approve permit2 contract to transfer our funds
        token0.approve(address(permit2), type(uint256).max);
        token1.approve(address(permit2), type(uint256).max);

        permit2.approve(address(token0), address(positionManager), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(positionManager), type(uint160).max, type(uint48).max);

        permit2.approve(address(token0), _universalRouter, type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), _universalRouter, type(uint160).max, type(uint48).max);
    }
}
/*
source .env
forge script script/Approve.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
*/
