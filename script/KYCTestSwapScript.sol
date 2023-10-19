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

import {KYCUtil} from "./utils/KYCUtil.sol";

import {console} from "forge-std/console.sol";
import {MockToken} from "../src/mocks/MockToken.sol";
import {UniswapV4Router} from "../src/router/UniswapV4Router.sol";
import {UniswapV4Caller} from "../src/router/UniswapV4Caller.sol";
import {KYCFactory} from "../src/hooks/KYCHook.sol";
import {IEAS} from "../src/hooks/IEAS.sol";
import {IEASProxy} from "../src/hooks/IEASProxy.sol";

import "forge-std/Script.sol";

contract KYCTestSwapScript is Script, KYCUtil {
    uint256 privateKey;
    address signerAddr;

    ERC20 tokenA;
    ERC20 tokenB;
    UniswapV4Caller caller;
    IHooks hook;

    // .env.[PRIVATE_KEY]
    // .env.[TOKENA, TOKENB, CALLER, KYC_HOOK]
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        privateKey = vm.envUint("PRIVATE_KEY");
        signerAddr = vm.addr(privateKey);
        console.log("DEPLOYER=%s", signerAddr);

        address _tokenA = vm.envAddress("TOKENA");
        console.log("TOKENA=%s", _tokenA);
        address _tokenB = vm.envAddress("TOKENB");
        console.log("TOKENB=%s", _tokenB);
        address _caller = vm.envAddress("CALLER");
        console.log("CALLER=%s", _caller);
        address _hook = vm.envAddress("KYC_HOOK");
        console.log("HOOK=%s", _hook);

        vm.startBroadcast(privateKey);

        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);
        caller = UniswapV4Caller(_caller);
        hook = IHooks(_hook);

        PoolKey memory poolKey = KYCUtil.getPoolKey(tokenA, tokenB, hook);

        KYCUtil.testSwap(caller, poolKey, signerAddr);

        vm.stopBroadcast();
    }
}
