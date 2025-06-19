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

import {MockToken} from "../../src/mocks/MockToken.sol";
import {UniswapV4Router} from "../../src/router/UniswapV4Router.sol";
import {UniswapV4Caller} from "../../src/router/UniswapV4Caller.sol";
import {KYCFactory} from "../../src/hooks/KYCHook.sol";
import {IEAS} from "../../src/hooks/IEAS.sol";
import {IEASProxy} from "../../src/hooks/IEASProxy.sol";

import {console} from "forge-std/console.sol";

contract KYCUtil {
    uint256 public constant MAX_AMOUNT = 0x8ac7230489e80000;
    uint160 public constant SQRT_RATIO_1_TO_1 = 79228162514264337593543950336;

    function deployTokens() public returns (address token0, address token1) {
        console.log("Deploy two tokens");
        token0 = address(new MockToken("Token 0", "TOK0", MAX_AMOUNT));
        token1 = address(new MockToken("Token 1", "TOK1", MAX_AMOUNT));

        // pools alphabetically sort tokens by address
        // so align `token0` with `pool.token0` for consistency
        if (token0 > token1) {
            address tokenX = token0;
            token0 = token1;
            token1 = tokenX;
        }
        console.log("TOKEN0=%s", token0);
        console.log("TOKEN1=%s", token1);
    }

    function deployRouter(IPoolManager manager) public returns (address router) {
        console.log("Deploy a generic router");
        router = address(new UniswapV4Router(manager));
        console.log("ROUTER=%s", router);
    }

    function deployCaller(IPoolManager manager, UniswapV4Router router) public returns (address caller) {
        console.log("Deploy a generic caller");
        caller = address(new UniswapV4Caller(router, manager));
        console.log("CALLER=%s", caller);
    }

    function approveToRouter(ERC20 token0, ERC20 token1, UniswapV4Router router) public {
        console.log("Approve to router");
        token0.approve(address(router), MAX_AMOUNT);
        token1.approve(address(router), MAX_AMOUNT);
    }

    function deployKYCFactory() public returns (address factory) {
        console.log("Deploy KYC Factory");
        factory = address(new KYCFactory());
        console.log("KYC_FACTORY=%s", factory);
    }

    function deployKYCHook(
        KYCFactory factory,
        IPoolManager manager,
        IEASProxy easproxy,
        IEAS eas,
        bytes32 schemaKyc,
        bytes32 schemaCountry
    ) public returns (address hook) {
        console.log("Deploy KYC Hook");
        hook = factory.mineDeploy(manager, easproxy, eas, schemaKyc, schemaCountry);
        console.log("KYC_HOOK=%s", hook);
    }

    function getPoolKey(ERC20 token0, ERC20 token1, IHooks hook) public pure returns (PoolKey memory poolKey) {
        poolKey = PoolKey(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            FeeLibrary.HOOK_SWAP_FEE_FLAG | FeeLibrary.HOOK_WITHDRAW_FEE_FLAG | 3000,
            60,
            hook
        );
    }

    function initPool(IPoolManager manager, PoolKey memory poolKey) public {
        console.log("Create the pool in the Uniswap Pool Manager");
        manager.initialize(poolKey, SQRT_RATIO_1_TO_1, "");
    }

    function addLiquidity(UniswapV4Caller caller, PoolKey memory poolKey, address signerAddr) public {
        console.log("Provide liquidity to the pool");
        caller.addLiquidity(poolKey, signerAddr, -60, 60, 0.01 ether);
        caller.addLiquidity(poolKey, signerAddr, -120, 120, 0.01 ether);
        // caller.addLiquidity(poolKey, signerAddr, TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 0.01 ether);
    }

    function testSwap(UniswapV4Caller caller, PoolKey memory poolKey, address signerAddr) public {
        console.log("test swap");
        caller.swap(poolKey, signerAddr, signerAddr, poolKey.currency0, 1e9);
    }
}
