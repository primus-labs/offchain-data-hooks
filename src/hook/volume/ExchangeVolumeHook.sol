// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseFeeDiscountHook} from "../../BaseFeeDiscountHook.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IAttestationRegistry} from "../../IAttestationRegistry.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {ModifyLiquidityParams, SwapParams} from "v4-core/src/types/PoolOperation.sol";
import {PositionManager} from "v4-periphery/src/PositionManager.sol";

import {PoolIdLibrary, PoolId} from "v4-core/src/types/PoolId.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";

/// @notice ExchangeVolumeHook.sol.sol will check the following attestations before adding liquidity or swap:
/// 1. The attestation of binance or other exchanges within 7 days
/// 2. If a valid attestation of address is provided, the handling fee will be discounted by 50%.
contract ExchangeVolumeHook is BaseFeeDiscountHook {
    using PoolIdLibrary for PoolKey;


    constructor(IPoolManager _poolManager, IAttestationRegistry _attestationRegistry, address initialOwner)
        BaseFeeDiscountHook(_attestationRegistry, _poolManager, initialOwner)
    {}

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            beforeAddLiquidity: false,
            afterInitialize: true,
            beforeSwap: true,
            beforeSwapReturnDelta: false,
            afterSwap: false,
            beforeRemoveLiquidity: false,
            afterAddLiquidity: false,
            afterRemoveLiquidity: false,
            beforeDonate: false,
            afterDonate: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function _afterInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, int24 tick)
        internal
        override
        onlyPoolManager
        returns (bytes4)
    {
        poolManager.updateDynamicLPFee(key, defaultFee);
        poolFeeMapping[key.toId()] = defaultFee;
        poolsInitialized.push(key.toId());
        poolIdToPoolKey[key.toId()] = key;
        emit AfterInitialize(key.toId());
        return (this.afterInitialize.selector);
    }

    function _beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)
        internal
        override
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        uint24 fee = getFeeDiscount(tx.origin, key);
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, fee);
    }

    /*
      @dev Set default fee for pool
      @param fee
      @return
     */
    function updatePoolFeeByPoolKey(PoolKey memory poolKey, uint24 newBaseFee) external onlyOwner {
        poolManager.updateDynamicLPFee(poolKey, newBaseFee);
        poolFeeMapping[poolKey.toId()] = newBaseFee;
    }

    /*
      @dev Update fee for pool by poolId
      @param fee
      @return
     */
    function updatePoolFeeByPoolId(PoolId[] memory poolIds, uint24 newBaseFee) external onlyOwner {
        for (uint256 i = 0; i < poolIds.length; i++) {
            PoolKey memory poolKey = poolIdToPoolKey[poolIds[i]];
            poolManager.updateDynamicLPFee(poolKey, newBaseFee);
            poolFeeMapping[poolIds[i]] = newBaseFee;
        }
    }
}
