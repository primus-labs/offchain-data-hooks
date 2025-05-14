// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ExchangeVolumeHook} from "../../src/hook/volume/ExchangeVolumeHook.sol";
import {PoolId} from "v4-core/src/types/PoolId.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";

//forge script script/pool-cl/caller/CallHook.s.sol:CallHook --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
contract CallHook is Script {
    ExchangeVolumeHook public hook;
    PoolManager public poolManager;
    using StateLibrary for PoolManager;

    function run() public {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        address clHook = vm.envAddress("HOOK");

        hook = ExchangeVolumeHook(address(clHook));
        poolManager = PoolManager(vm.envAddress("POOL_MANAGER"));
        vm.startBroadcast(senderPrivateKey);

        // setBaseValue();
        getBaseValue();
        vm.stopBroadcast();
    }

    function setDefaultFee() public {
        hook.setDefaultFee(3000);
        // PoolId poolId = hook.poolsInitialized(0);
        // PoolId[] memory poolIds = new PoolId[](1);
        // poolIds[0] = poolId;
        // hook.updatePoolFeeByPoolId(poolIds, 40000);
        // (,,, uint24 lpFee) = poolManager.getSlot0(poolId);
        // console.log("fee from poolManager is:", lpFee);
        // console.log("fee from hook is:", hook.poolFeeMapping(poolId));
    }

    function setDurationOfAttestation() public {
        hook.setDurationOfAttestation(1);
    }

    function setBaseValue() public {
        hook.setBaseValue(5000);
    }

    function getBaseValue() public {
        console.log("baseValue:", hook.baseValue());
    }

    function getPool0Fee() public {
        PoolId poolId = hook.poolsInitialized(0);
        bytes32 poolIdBytes = PoolId.unwrap(poolId);
        uint24 fee = hook.poolFeeMapping(poolId);
        console.logBytes32(poolIdBytes);
        console.log(fee);
    }
}
