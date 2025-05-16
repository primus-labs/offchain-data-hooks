// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {CurrencyLibrary, Currency}from "v4-core/src/types/Currency.sol";
import {StateLibrary}from "v4-core/src/libraries/StateLibrary.sol";
import {FeeMath} from "v4-periphery/test/shared/FeeMath.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {LPFeeLibrary} from "v4-core/src/libraries/LPFeeLibrary.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/src/types/BalanceDelta.sol";

import {LiquidityAmounts} from "v4-periphery/src/libraries/LiquidityAmounts.sol";
import {Actions} from "v4-periphery/src/libraries/Actions.sol";
import {ModifyLiquidityParams} from "v4-core/src/types/PoolOperation.sol";
import {Planner, Plan} from "v4-periphery/test/shared/Planner.sol";
import {PositionConfig} from "v4-periphery/test/shared/PositionConfig.sol";
import {PoolIdLibrary, PoolId} from "v4-core/src/types/PoolId.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {PoolModifyLiquidityTest} from "v4-core/src/test/PoolModifyLiquidityTest.sol";
import {PositionConfig} from "v4-periphery/test/shared/PositionConfig.sol";
import {console} from "forge-std/console.sol";

contract AddLiquidityScript is Script {
    using CurrencyLibrary for Currency;
    using FeeMath for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using BalanceDeltaLibrary for BalanceDelta;
    using StateLibrary for PoolManager;

    bytes constant ZERO_BYTES = new bytes(0);

    address deployer;

    function run() external {
        addLiquidity();
//        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//        deployer = vm.rememberKey(deployerPrivateKey);
//
//        address _poolManager = vm.envAddress("POOL_MANAGER");
//        console.log("_poolManager=%s", _poolManager);
//
//        PoolManager poolManager = PoolManager(_poolManager);
//
//        PoolModifyLiquidityTest lpRouter = new PoolModifyLiquidityTest(poolManager);
//
//        vm.startBroadcast(deployer);
//
//        address token0 = vm.envAddress("TOKEN0");
//        console.log("token0=%s", token0);
//
//        address token1 = vm.envAddress("TOKEN1");
//        console.log("token1=%s", token1);
//
//        address hook = vm.envAddress("HOOK");
//        console.log("HOOK=%s", hook);
//
//        int24 tickSpacing = 10;
//
//        uint160 startingPrice = 79228162514264337593543950336;
//
//        PoolKey memory pool = PoolKey({
//            currency0: Currency.wrap(token0),
//            currency1: Currency.wrap(token1),
//            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
//            tickSpacing: tickSpacing,
//            hooks: IHooks(hook)
//        });
//
//        // approve tokens to the LP Router
//        console.log("Approving Tokens");
//        IERC20(token0).approve(address(lpRouter), 1000e18);
//        IERC20(token1).approve(address(lpRouter), 1000e18);
//
//        // optionally specify hookData if the hook depends on arbitrary data for liquidity modification
//        bytes memory hookData = new bytes(0);
//
//        // logging the pool ID
//        PoolId id = PoolIdLibrary.toId(pool);
//        bytes32 idBytes = PoolId.unwrap(id);
//        console.log("Pool ID Below");
//        console.logBytes32(bytes32(idBytes));
//
//        console.log("Add liquidity");
//        // Provide 10_000e18 worth of liquidity on the range of [-600, 600]
//        lpRouter.modifyLiquidity(pool, ModifyLiquidityParams(- 600, 600, 1000e18, 0), hookData);
    }

    function addLiquidity() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        deployer = vm.rememberKey(deployerPrivateKey);

        address _poolManager = vm.envAddress("POOL_MANAGER");
        console.log("_poolManager=%s", _poolManager);

        address _positionManager = vm.envAddress("POSITION_MANAGER");

        PoolManager poolManager = PoolManager(_poolManager);

        vm.startBroadcast(deployer);

        address token0 = vm.envAddress("TOKEN0");
        console.log("token0=%s", token0);

        address token1 = vm.envAddress("TOKEN1");
        console.log("token1=%s", token1);

        address hook = vm.envAddress("HOOK");
        console.log("HOOK=%s", hook);


        address recipient = vm.envAddress("FEE_RECIPIENT");


        uint256 amount0Max = 1000e18;
        uint256 amount1Max = 1000e18;


        int24 tickSpacing = 10;

        uint160 startingPrice = 79228162514264337593543950336;
        Currency currency0 = Currency.wrap(token0);
        Currency currency1 = Currency.wrap(token1);
        PoolKey memory key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: tickSpacing,
            hooks: IHooks(hook)
        });

        PositionConfig memory config = PositionConfig({poolKey: key, tickLower: - 300, tickUpper: 300});

        // Alice and Bob provide liquidity on the range
        // Alice uses her exact fees to increase liquidity (compounding)

        IPositionManager positionManager = IPositionManager(_positionManager);
        uint256 tokenId = positionManager.nextTokenId();

        (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(key.toId());

        uint256 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96,
            TickMath.getSqrtPriceAtTick(config.tickLower),
            TickMath.getSqrtPriceAtTick(config.tickUpper),
            amount0Max,
            amount1Max
        );
        //        PositionConfig memory config = PositionConfig({poolKey: key, tickLower: tickLower, tickUpper: tickUpper});
        //        Plan memory planner = Planner.init().add(
        //            Actions.CL_MINT_POSITION, abi.encode(config, liquidity, amount0Max, amount1Max, recipient, new bytes(0))
        //        );
        Plan memory planner = Planner.init().add(
            Actions.MINT_POSITION,
            abi.encode(
                key,
                config.tickLower,
                config.tickUpper,
                uint256(liquidity),
                amount0Max,
                amount1Max,
                recipient,
                new bytes(0) //hookdata
            )
        );
        bytes memory data = planner.finalizeModifyLiquidityWithClose(key);
        // positionManager.modifyLiquidities(data, block.timestamp + 1);
        positionManager.modifyLiquidities(data, block.timestamp + 100);
        vm.stopBroadcast();

    }
}