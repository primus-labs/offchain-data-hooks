// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {PositionManager} from "v4-periphery/src/PositionManager.sol";
import {IPermit2Forwarder} from "v4-periphery/src/interfaces/IPermit2Forwarder.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {V4Router} from "v4-periphery/src/V4Router.sol";
import {IV4Router} from "v4-periphery/src/interfaces/IV4Router.sol";
import {UniversalRouter} from "universal-router/contracts/UniversalRouter.sol";
import {Commands} from "universal-router/contracts/libraries/Commands.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
import {Planner, Plan} from "v4-periphery/test/shared/Planner.sol";
import {PoolIdLibrary, PoolId} from "v4-core/src/types/PoolId.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";
import {LPFeeLibrary} from "v4-core/src/libraries/LPFeeLibrary.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Actions} from "v4-periphery/src/libraries/Actions.sol";
import {ActionConstants} from "v4-periphery/src/libraries/ActionConstants.sol";
//forge script script/Swap.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
contract Swap is Script {
    function run() public {
        console.log("msg.sender %s", msg.sender);
        console.log("script %s", address(this));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address signerAddr = vm.addr(privateKey);
        console.log("SIGNER=%s", signerAddr);

        vm.startBroadcast(privateKey);

        swap();

        vm.stopBroadcast();
    }

    // prettier-ignore
    function swap() internal {
        address _token0 = vm.envAddress("TOKEN0");
        console.log("_token0=%s", _token0);
        address _token1 = vm.envAddress("TOKEN1");
        console.log("_token1=%s", _token1);
        address payable _positionManager = payable(vm.envAddress("POSITION_MANAGER"));
        console.log("_positionManager=%s", _positionManager);
        address _universalRouter = vm.envAddress("UNIVERSAL_ROUTER");
        console.log("_universalRouter=%s", _universalRouter);
        UniversalRouter router = UniversalRouter(payable(_universalRouter));


        address token0 = vm.envAddress("TOKEN0");
        console.log("token0=%s", token0);

        address token1 = vm.envAddress("TOKEN1");
        console.log("token1=%s", token1);

        address hook = vm.envAddress("HOOK");
        console.log("HOOK=%s", hook);
        int24 tickSpacing = 10;

        Currency currency0 = Currency.wrap(token0);
        Currency currency1 = Currency.wrap(token1);
        PoolKey memory key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: tickSpacing,
            hooks: IHooks(hook)
        });

        // Swap
        IV4Router.ExactInputSingleParams memory params = IV4Router.ExactInputSingleParams({
            poolKey: key,
            zeroForOne: true,
            amountIn: 1e18,
            amountOutMinimum: 0,
            hookData: new bytes(0)
        });
        Plan memory plan = Planner.init().add(Actions.SWAP_EXACT_IN_SINGLE, abi.encode(params));
        bytes memory data = params.zeroForOne
            ? plan.finalizeSwap(params.poolKey.currency0, params.poolKey.currency1, ActionConstants.MSG_SENDER)
            : plan.finalizeSwap(params.poolKey.currency1, params.poolKey.currency0, ActionConstants.MSG_SENDER);

        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V4_SWAP)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = data;

        router.execute(commands, inputs);
    }
}