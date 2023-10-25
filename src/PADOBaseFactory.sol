// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";

import {console} from "forge-std/console.sol";
import { IEAS } from "./hooks/IEAS.sol";
import { IEASProxy} from "./hooks/IEASProxy.sol";

abstract contract PADOBaseFactory {
    /// @notice zero out all but the first byte of the address which is all 1's
    uint160 public constant UNISWAP_FLAG_MASK = 0xff << 152;

    // Uniswap hook contracts must have specific flags encoded in the first byte of their address
    address public immutable TargetPrefix;

    constructor(address _targetPrefix) {
        TargetPrefix = _targetPrefix;
    }

    function deploy(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry, bytes32 salt) public virtual returns (address);

    function mineDeploy(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry) external returns (address) {
        return _mineDeploy(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry, 0);
    }

    function mineDeploy(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry, uint256 startSalt) external returns (address) {
        return _mineDeploy(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry, startSalt);
    }

    function mineDeploy2(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry, uint256 startSalt) external returns (address) {
        return _mineDeploy(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry, startSalt);
    }

    function _mineDeploy(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry, uint256 startSalt) internal returns (address) {
        bytes32 salt = mineSalt(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry, startSalt);
        return deploy(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry, salt);
    }

    function mineSalt(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry, uint256 startSalt) public view returns (bytes32 salt) {
        uint256 endSalt = uint256(startSalt) + 1000;
        console.log("startSalt %s endSalt %s", startSalt, endSalt);
        unchecked {
            for (uint256 i = startSalt; i < endSalt; ++i) {
                salt = bytes32(i);
                address hookAddress = _computeHookAddress(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry, salt);
                // console.log("Testing salt %s for address %s", i, hookAddress);

                if (_isPrefix(hookAddress)) {
                    console.log("Found salt %s for address %s", i, hookAddress);
                    return salt;
                }
            }
            revert("Failed to find a salt");
        }
    }

    function _computeHookAddress(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry, bytes32 salt) internal view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, _hashBytecode(poolManager, iEasPrxoy, eas, schemaKyc, schemaCountry)));
        return address(uint160(uint256(hash)));
    }

    /// @dev The implementing contract must override this function to return the bytecode hash of its contract
    /// For example, the CounterHook contract would return:
    /// bytecodeHash = keccak256(abi.encodePacked(type(CounterHook).creationCode, abi.encode(poolManager)));
    function _hashBytecode(IPoolManager poolManager, IEASProxy iEasPrxoy, IEAS eas, bytes32 schemaKyc, bytes32 schemaCountry) internal pure virtual returns (bytes32 bytecodeHash);

    function _isPrefix(address _address) internal view returns (bool) {
        // zero out all but the first byte of the address
        address actualPrefix = address(uint160(_address) & UNISWAP_FLAG_MASK);
        return actualPrefix == TargetPrefix;
    }
}
