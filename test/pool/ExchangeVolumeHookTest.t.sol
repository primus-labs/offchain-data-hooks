// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./util/MockAttestationRegistry.t.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {ExchangeVolumeHook} from "../../src/hook/volume/ExchangeVolumeHook.sol";
import {Test} from "forge-std/Test.sol";
import {Attestation} from "../../src/types/Common.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {console} from "forge-std/console.sol";
//import {IVault} from "v4-core/src/interfaces/IVault.sol";
//import {Vault} from "v4-core/src/Vault.sol";
import {LPFeeLibrary} from "v4-core/src/libraries/LPFeeLibrary.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ModifyLiquidityParams, SwapParams} from "v4-core/src/types/PoolOperation.sol";
import {HookMiner} from "v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";


contract ExchangeVolumeHookTest is Test {

    ExchangeVolumeHook public exchangeVolumeHook;
    IAttestationRegistry public iAttestationRegistry;
    IPoolManager public poolManager;

    function setUp() public {
        iAttestationRegistry = new MockAttestationRegistry();

        poolManager = new PoolManager(address(this));
        console.log("poolManager:", address(poolManager));
        // Create an attestation and add it to the registry
        Attestation memory attestation = Attestation({
            recipient: address(poolManager),
            exchange: "binance",
            value: 100000,
            timestamp: block.timestamp
        });
        console.log("address_(this) is", address(this));
        console.log("block.timestamp:", block.timestamp);
        MockAttestationRegistry(address(iAttestationRegistry)).addAttestation(attestation);

        // Initialize the ExchangeVolumeHook with the mock registry
        deployHook();
    }

    function deployHook() private returns (address){
        uint160 flags = uint160(
            Hooks.AFTER_INITIALIZE_FLAG |
            Hooks.BEFORE_SWAP_FLAG
        );

        bytes memory constructorArgs = abi.encode(poolManager, iAttestationRegistry, address(this));
        // Mine a salt that will produce a hook address with the correct flags
        (address hookAddress, bytes32 salt) =
                            HookMiner.find(address(this), flags, type(ExchangeVolumeHook).creationCode, constructorArgs);
        console.log("hookAddress=%s", hookAddress);
        // Deploy the hook using CREATE2
//        console.log("salt=%s",salt);
        exchangeVolumeHook = new ExchangeVolumeHook{salt: salt}(poolManager, iAttestationRegistry, address(this));

        console.log("exchangeVolumeHook=%s", address(exchangeVolumeHook));
        console.log("exchangeVolumeHook owner=%s", address(exchangeVolumeHook.owner()));
        return address(exchangeVolumeHook);
    }

    function testBeforeSwap() public {
        // Fetch attestation by recipient
        Attestation[] memory fetchedAttestation =
                                MockAttestationRegistry(address(iAttestationRegistry)).getAttestationByRecipient(address(this));
        // Define a valid PoolKey (adjust fields as per actual definition)
        int24 tickSpacing = 10;

        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(0)), // Replace with actual token address
            currency1: Currency.wrap(address(1)), // Replace with actual token address
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,// Example fee, replace with actual value
            tickSpacing: tickSpacing,
            hooks: IHooks(address(exchangeVolumeHook))
        });

        // Define valid SwapParams (adjust fields as per actual definition)
        SwapParams memory swapParams = SwapParams({
            amountSpecified: 1000, // Example amount
            sqrtPriceLimitX96: 0, // Replace with appropriate value
            zeroForOne: true // Example direction
        });

        poolManager.initialize(poolKey, Constants.SQRT_PRICE_1_1);
        console.log("initialize pool size:", exchangeVolumeHook.getInitializedPoolSize());
        //update fee
        vm.prank(exchangeVolumeHook.owner());
        exchangeVolumeHook.updatePoolFeeByPoolKey(poolKey, 3000);

        console.logString("start swap");
        vm.prank(address(poolManager));
        (bytes4 selector1, BeforeSwapDelta beforeSwapDelta1, uint24 fee1) =
                            exchangeVolumeHook.beforeSwap(address(poolManager), poolKey, swapParams, abi.encode("0"));
        console.logUint(fee1);
        assertTrue(fee1 == 3000, "fee1 is not equal");
        vm.stopPrank();
        vm.startPrank(address(poolManager), address(poolManager));

        (bytes4 selector2, BeforeSwapDelta beforeSwapDelta2, uint24 fee2) =
                            exchangeVolumeHook.beforeSwap(address(poolManager), poolKey, swapParams, abi.encode("0"));
        console.log("swap 2");

        console.logUint(fee2);
        assertTrue(fee2 == (1500 | LPFeeLibrary.OVERRIDE_FEE_FLAG), "fee2 is not equal");
        vm.stopPrank();
    }

    function testOnlyOwnerCanChangeFee() public {
        // Test that non-owner cannot change the fee
        address nonOwner = address(poolManager);
        console.log("nonOwner=%s", nonOwner);
        address owner = exchangeVolumeHook.owner();
        console.log("owner=%s", owner);
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        exchangeVolumeHook.setDefaultFee(5000);

        // Simulate the owner calling the function
        vm.prank(owner); // Mock the caller as the owner
        exchangeVolumeHook.setDefaultFee(5000);

        // Verify the state update
        uint256 updatedFee = exchangeVolumeHook.defaultFee();
        assertEq(updatedFee, 5000);
    }

    function testBaseValue() public {
        // Test that non-owner cannot change the baseValue
        address nonOwner = address(poolManager);
        console.log("nonOwner=%s", nonOwner);
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        exchangeVolumeHook.setBaseValue(20000);
        // Simulate the owner calling the function
        address owner = exchangeVolumeHook.owner();
        console.log("owner=%s", owner);
        vm.prank(owner); // Mock the caller as the owner
        exchangeVolumeHook.setBaseValue(20000);
        // Verify the state update
        uint256 updatedFee = exchangeVolumeHook.baseValue();
        assertEq(updatedFee, 20000);
    }
}
