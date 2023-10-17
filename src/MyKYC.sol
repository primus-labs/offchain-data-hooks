// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {KYCHook} from "./hooks/KYCHook.sol";
import {PoolKey, PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {FeeLibrary} from "@uniswap/v4-core/contracts/libraries/FeeLibrary.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";

import {UniswapV4Router} from "./router/UniswapV4Router.sol";
import {UniswapV4Caller} from "./router/UniswapV4Caller.sol";

import {console} from "forge-std/console.sol";

contract MyKYC is Deployers {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    PoolKey _poolKey;
    PoolManager _manager;
    UniswapV4Caller _caller;
    address _owner;
    uint160 public constant sqrtPriceX96 = 79228162514264337593543950336;

    constructor(
        PoolManager manager,
        KYCHook hook,
        ERC20 tokenA,
        ERC20 tokenB,
        UniswapV4Caller caller
    ) {
        _owner = msg.sender;
        _caller = caller;
        _manager = manager;
        _poolKey = PoolKey(
            Currency.wrap(address(tokenA)),
            Currency.wrap(address(tokenB)),
            FeeLibrary.HOOK_SWAP_FEE_FLAG | 3000,
            60,
            IHooks(hook)
        );
        _manager.initialize(_poolKey, sqrtPriceX96, "");
        // _caller.addLiquidity(_poolKey, msg.sender, -60, 60, 0.001 ether);
        // _caller.addLiquidity(_poolKey, msg.sender, -120, 120, 0.001 ether);
        // _caller.addLiquidity(
        //     _poolKey,
        //     msg.sender,
        //     TickMath.minUsableTick(60),
        //     TickMath.maxUsableTick(60),
        //     0.001 ether
        // );
    }

    function testswap() public {
        console.log("testswap");
        _caller.swap(_poolKey, _owner, _owner, _poolKey.currency0, 1e18);
    }
}
