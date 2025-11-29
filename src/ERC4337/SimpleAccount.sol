// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    BaseAccount
} from "../../lib/account-abstraction/contracts/core/BaseAccount.sol";
import {
    IEntryPoint
} from "../../lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {
    PackedUserOperation
} from "../../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {
    SIG_VALIDATION_FAILED,
    SIG_VALIDATION_SUCCESS
} from "../../lib/account-abstraction/contracts/core/Helpers.sol";
import {
    ECDSA
} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

/// @title SimpleAccount - a minimal implementation of an ERC-4337 account
/// @author Kevin.
/// @notice This contract is a simple implementation of an ERC-4337 account that
///         sets the entry point and owner at construction time and provides
///         getter functions for both.
contract SimpleAccount is BaseAccount {
    IEntryPoint private immutable _i_entryPoint;
    address private immutable _i_owner;

    error SimpleAccount__CallFailed();

    /// @notice constructor sets the entry point and owner of the account
    /// @param entryPointAddress address of the entry point contract
    /// @param owner address of the owner of the account
    constructor(address entryPointAddress, address owner) {
        _i_entryPoint = IEntryPoint(entryPointAddress);
        _i_owner = owner;
    }

    /// @notice validate the signature of the user operation
    /// @param userOp the packed user operation
    /// @param userOpHash the hash of the user operation
    /// @return uint256 indicating signature validation result
    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal override returns (uint256) {
        bytes32 digest = ECDSA.toEthSignedMessageHash(userOpHash);
        address messageSigner = ECDSA.recover(digest, userOp.signature);
        if (messageSigner == _i_owner) {
            return SIG_VALIDATION_SUCCESS;
        } else {
            return SIG_VALIDATION_FAILED;
        }
    }

    /// @notice execute a transaction from the account
    /// @param dest destination address of the transaction
    /// @param value amount of ether to send
    /// @param funcCallData calldata of the function to call
    function execute(
        address dest,
        uint256 value,
        bytes calldata funcCallData
    ) external {
        _requireFromEntryPoint();
        (bool success, ) = dest.call{value: value}(funcCallData);
        if (!success) {
            revert SimpleAccount__CallFailed();
        }
    }

    /// @notice return the entry point set at construction time
    /// @return IEntryPoint interface of the entry point
    function entryPoint() public view override returns (IEntryPoint) {
        return _i_entryPoint;
    }

    /// @notice return the owner set at construction time
    /// @return address of the owner
    function getOwner() public view returns (address) {
        return _i_owner;
    }
}
