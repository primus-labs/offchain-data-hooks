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

contract KYCScript is Script, KYCUtil {
    uint256 privateKey;
    address signerAddr;

    IPoolManager manager;
    IEASProxy easproxy;
    IEAS eas;

    ERC20 tokenA;
    ERC20 tokenB;
    UniswapV4Router router;
    UniswapV4Caller caller;
    KYCFactory factory;
    IHooks hook;

    // .env.[PRIVATE_KEY, POOL_MANAGER]
    // .env.[EASPROXY_ADDRESS, EAS_ADDRESS, SCHEMA_KYC_BYTES, SCHEMA_COUNTRY_BYTES]
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        privateKey = vm.envUint("PRIVATE_KEY");
        signerAddr = vm.addr(privateKey);
        console.log("DEPLOYER=%s", signerAddr);

        address _manager = vm.envAddress("POOL_MANAGER");
        console.log("POOL_MANAGER=%s", _manager);

        address _easproxy = vm.envAddress("EASPROXY_ADDRESS");
        console.log("EASPROXY_ADDRESS=%s", _easproxy);
        address _eas = vm.envAddress("EAS_ADDRESS");
        console.log("EAS_ADDRESS=%s", _eas);

        bytes32 schemaKyc = vm.envBytes32("SCHEMA_KYC_BYTES");
        // console.log("SCHEMA_KYC_BYTES=%s", schemaKyc);
        bytes32 schemaCountry = vm.envBytes32("SCHEMA_COUNTRY_BYTES");
        // console.log("SCHEMA_COUNTRY_BYTES=%s", schemaCountry);

        vm.startBroadcast(privateKey);

        manager = IPoolManager(_manager);
        easproxy = IEASProxy(_easproxy);
        eas = IEAS(_eas);

        address _tokenA;
        address _tokenB;
        (_tokenA, _tokenB) = KYCUtil.deployTokens();
        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);

        router = UniswapV4Router(KYCUtil.deployRouter(manager));
        caller = UniswapV4Caller(KYCUtil.deployCaller(manager, router));
        approveToRouter(tokenA, tokenB, router);

        factory = KYCFactory(deployKYCFactory());

        hook = IHooks(
            KYCUtil.deployKYCHook(
                factory,
                manager,
                easproxy,
                eas,
                schemaKyc,
                schemaCountry
            )
        );

        PoolKey memory poolKey = KYCUtil.getPoolKey(tokenA, tokenB, hook);

        KYCUtil.initPool(manager, poolKey);

        // KYCUtil.addLiquidity(caller, poolKey, signerAddr);

        // KYCUtil.testSwap(caller, poolKey, signerAddr);

        vm.stopBroadcast();
    }
}
