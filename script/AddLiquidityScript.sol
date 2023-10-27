// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {PoolKey, PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {FeeLibrary} from "@uniswap/v4-core/contracts/libraries/FeeLibrary.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";

import {UniswapV4Caller} from "../src/router/UniswapV4Caller.sol";
import {KYCUtil} from "./utils/KYCUtil.sol";

import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";

contract AddLiquidityScript is Script, KYCUtil {
    uint256 privateKey;
    address signerAddr;

    ERC20 token0;
    ERC20 token1;
    UniswapV4Caller caller;
    IHooks hook;

    // .env.[PRIVATE_KEY]
    // .env.[TOKEN0, TOKEN1, CALLER, KYC_HOOK]
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        privateKey = vm.envUint("PRIVATE_KEY");
        signerAddr = vm.addr(privateKey);
        console.log("DEPLOYER=%s", signerAddr);

        address _token0 = vm.envAddress("TOKEN0");
        console.log("TOKEN0=%s", _token0);
        address _token1 = vm.envAddress("TOKEN1");
        console.log("TOKEN1=%s", _token1);
        address _caller = vm.envAddress("CALLER");
        console.log("CALLER=%s", _caller);
        address _hook = vm.envAddress("KYC_HOOK");
        console.log("KYC_HOOK=%s", _hook);

        vm.startBroadcast(privateKey);

        token0 = ERC20(_token0);
        token1 = ERC20(_token1);
        caller = UniswapV4Caller(_caller);
        hook = IHooks(_hook);

        PoolKey memory poolKey = KYCUtil.getPoolKey(token0, token1, hook);

        KYCUtil.addLiquidity(caller, poolKey, signerAddr);

        vm.stopBroadcast();
    }
}
