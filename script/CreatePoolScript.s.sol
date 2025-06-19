// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {SortTokens} from "v4-core/test/utils/SortTokens.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";

import {PoolModifyLiquidityTest} from "v4-core/src/test/PoolModifyLiquidityTest.sol";


import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";
import {LPFeeLibrary} from "v4-core/src/libraries/LPFeeLibrary.sol";

contract CreatePoolScript is Script {

    int24 public tickSpacing = 10;

    // floor(sqrt(1) * 2^96)
    uint160 public  startingPrice = 79228162514264337593543950336;

    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address signerAddr = vm.addr(privateKey);
        console.log("SIGNER=%s", signerAddr);


        vm.startBroadcast(privateKey);

        createAndInitPool();

        vm.stopBroadcast();
    }

    // prettier-ignore
    function createAndInitPool() internal {

        address token0 = vm.envAddress("TOKEN0");
        console.log("token0=%s", token0);

        address token1 = vm.envAddress("TOKEN1");
        console.log("token1=%s", token1);

        address hook = vm.envAddress("HOOK");
        console.log("HOOK=%s", hook);

        address _poolManager = vm.envAddress("POOL_MANAGER");
        console.log("_poolManager=%s", _poolManager);

        PoolManager poolManager = PoolManager(_poolManager);

        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: tickSpacing,
            hooks: IHooks(hook)
        });

        poolManager.initialize(poolKey, startingPrice);

    }
}
/*
source .env
forge script script/DeployToken.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
*/
