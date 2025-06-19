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

import {UniswapV4Router} from "../src/router/UniswapV4Router.sol";
import {UniswapV4Caller} from "../src/router/UniswapV4Caller.sol";
import {KYCFactory} from "../src/hooks/KYCHook.sol";
import {KYCUtil} from "./utils/KYCUtil.sol";

import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";

contract KYCFirstScript is Script, KYCUtil {
    uint256 privateKey;
    address signerAddr;

    IPoolManager manager;

    ERC20 token0;
    ERC20 token1;
    UniswapV4Router router;
    UniswapV4Caller caller;
    KYCFactory factory;
    IHooks hook;

    // .env.[PRIVATE_KEY, POOL_MANAGER]
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        privateKey = vm.envUint("PRIVATE_KEY");
        signerAddr = vm.addr(privateKey);
        console.log("DEPLOYER=%s", signerAddr);

        address _manager = vm.envAddress("POOL_MANAGER");
        console.log("POOL_MANAGER=%s", _manager);

        vm.startBroadcast(privateKey);

        manager = IPoolManager(_manager);

        address _token0;
        address _token1;
        (_token0, _token1) = KYCUtil.deployTokens();
        token0 = ERC20(_token0);
        token1 = ERC20(_token1);

        router = UniswapV4Router(KYCUtil.deployRouter(manager));
        caller = UniswapV4Caller(KYCUtil.deployCaller(manager, router));
        approveToRouter(token0, token1, router);

        factory = KYCFactory(deployKYCFactory());

        vm.stopBroadcast();
    }
}
