// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { BaseHook } from "v4-periphery/BaseHook.sol";
import { IPoolManager } from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import { Hooks } from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import { PoolKey } from "@uniswap/v4-core/contracts/types/PoolId.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IEAS } from "./IEAS.sol";
import { IEASProxy} from "./IEASProxy.sol";
import { Attestation, EMPTY_UID, uncheckedInc } from "./Common.sol";

import {PADOBaseFactory} from "../PADOBaseFactory.sol";

contract KYCHook is BaseHook, Ownable {
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

    function beforeModifyPosition(
        address sender,
        PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata
    ) external override returns (bytes4 selector) {
        if(!_checkKycResult(sender)) {
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
        if(!_checkKycResult(sender)) {
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
        return address(new KYCHook{salt: salt}(poolManager,iEasPrxoy,eas,schemaKyc,schemaCountry));
    }

    function _hashBytecode(IPoolManager poolManager) internal pure override returns (bytes32 bytecodeHash) {
        bytecodeHash = keccak256(abi.encodePacked(type(KYCHook).creationCode, abi.encode(poolManager)));
    }
}
