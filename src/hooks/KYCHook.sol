// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { BaseHook } from "v4-periphery/BaseHook.sol";
import { IPoolManager } from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import { IHookFeeManager } from "@uniswap/v4-core/contracts/interfaces/IHookFeeManager.sol";
import { Hooks } from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import { PoolKey } from "@uniswap/v4-core/contracts/types/PoolId.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IEAS } from "./IEAS.sol";
import { IEASProxy} from "./IEASProxy.sol";
import { Attestation, EMPTY_UID, uncheckedInc } from "./Common.sol";
import {PADOBaseFactory} from "../PADOBaseFactory.sol";

contract KYCHook is BaseHook, IHookFeeManager, Ownable {
    error NOKYC();
    error RestrictedCountry();

    event BeforeModify(address indexed sender);
    event BeforeSwap(address indexed sender);

    IEASProxy private _iEasProxy;
    IEAS private _eas;
    bytes32 private _schemaKyc;
    bytes32 private _schemaCountry;
    
    constructor(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry) BaseHook(poolManager) Ownable(msg.sender) {
        _iEasProxy = iEasPrxoy;
        _eas = eas;
        _schemaKyc = schemaKyc;
        _schemaCountry = schemaCountry;
    }

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: true,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    /// @notice The interface for setting a fee on swap or fee on withdraw to the hook
    /// @dev This callback is only made if the Fee.HOOK_SWAP_FEE_FLAG or Fee.HOOK_WITHDRAW_FEE_FLAG in set in the pool's key.fee.
    function getHookFees(PoolKey calldata) external pure returns (uint24 fee) {
        // Swap fee is upper bits.
        // 20% fee as 85 = hex55 which is 5 in both directions. 1/5 = 20%
        // Withdraw fee is lower bits
        // 33% fee as 51 = hex33 which is 3 in both directions. 1/3 = 33%
        fee = 0x5533;
    }

    function getHookWithdrawFee(PoolKey calldata key) external view returns (uint8 fee) {}

    function beforeModifyPosition(
        address sender,
        PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata
    ) external override returns (bytes4 selector) {
        if(!_checkKycResult(tx.origin)) {
            revert NOKYC();
        }
        emit BeforeModify(sender);
        selector = BaseHook.beforeModifyPosition.selector;
    }

    function beforeSwap(address sender, PoolKey calldata, IPoolManager.SwapParams calldata, bytes calldata)
        external
        override
        returns (bytes4 selector)
    {
        if(!_checkKycResult(tx.origin)) {
            revert NOKYC();
        }
        emit BeforeSwap(sender);
        selector = BaseHook.beforeSwap.selector;
    }

    function _checkKycResult(address sender) internal view returns (bool) {
        bytes32[] memory uids = _iEasProxy.getPadoAttestations(sender, _schemaKyc);
        for (uint256 i = 0; i < uids.length; i = uncheckedInc(i)) {
            Attestation memory ats = _eas.getAttestation(uids[i]);
            (string memory ProofType,string memory Source,string memory Content,string memory Condition,/*bytes32 SourceUserIdHash*/,bool Result,/*uint64 Timestamp*/,/*bytes32 UserIdHash*/) = abi.decode(ats.data, (string,string,string,string,bytes32,bool,uint64,bytes32));
            if (_compareStrings(ProofType, "Identity") && _compareStrings(Source, "binance") 
            && _compareStrings(Content, "KYC Level") && _compareStrings(Condition, ">=2") && Result) {
                return true;
            }
        }
        return false;
    }
    function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(bytes(a)) == keccak256(bytes(b)));
    }


    function setEasProxy(IEASProxy iEasPrxoy) external onlyOwner {
        _iEasProxy = iEasPrxoy;
    }
    function setSchemaKyc(bytes32 schemaKyc) external onlyOwner {
        _schemaKyc = schemaKyc;
    }
    function setSchemaCountry(bytes32 schemaCountry) external onlyOwner {
        _schemaCountry = schemaCountry;
    }

    function getEasProxy() external view returns (IEASProxy) {
        return _iEasProxy;
    }
    function getSchemaKyc() external view returns (bytes32) {
        return _schemaKyc;
    }
    function getSchemaCountry() external view returns (bytes32) {
        return _schemaCountry;
    }
}

contract KYCFactory is PADOBaseFactory {
    constructor()
        PADOBaseFactory(
            address(
                uint160(
                    Hooks.BEFORE_MODIFY_POSITION_FLAG | Hooks.BEFORE_SWAP_FLAG
                )
            )
        )
    {}

    function deploy(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry, bytes32 salt) public override returns (address) {
        return address(new KYCHook{salt: salt}(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry));
    }

    function _hashBytecode(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry) internal pure override returns (bytes32 bytecodeHash) {
        bytecodeHash = keccak256(abi.encodePacked(type(KYCHook).creationCode, abi.encode(poolManager), abi.encode(iEasPrxoy), abi.encode(eas), schemaKyc, schemaCountry));
    }
}
