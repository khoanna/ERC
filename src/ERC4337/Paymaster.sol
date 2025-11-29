// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    BasePaymaster
} from "../../lib/account-abstraction/contracts/core/BasePaymaster.sol";
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

/// @title Paymaster Contract
/// @author Kevin
/// @notice This contract extends BasePaymaster and is responsible for validating user operations based on a whitelist.

contract Paymaster is BasePaymaster {
    /// @dev Stores the whitelist status of each address.
    /// Only whitelisted addresses can successfully validate operations.
    mapping(address => bool) private _whitelist;

    /// @notice Initializes the Paymaster with a specified EntryPoint.
    /// @param entryPoint The EntryPoint contract address for managing user operations.
    constructor(IEntryPoint entryPoint) BasePaymaster(entryPoint) {}

    /// @inheritdoc BasePaymaster
    /// @notice Validates the user operation if the sender is whitelisted
    /// @param userOp The user operation that needs validation.
    /// @param userOpHash Hash of the user operation.
    /// @param maxCost The maximum gas cost for the operation.
    /// @return context The data for post-operation action if needed.
    /// @return validationData The validation result, indicating success or failure.
    function _validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    )
        internal
        view
        override
        returns (bytes memory context, uint256 validationData)
    {
        (userOpHash, maxCost);
        address user = userOp.sender;

        context = hex"";

        if (_whitelist[user]) {
            validationData = SIG_VALIDATION_SUCCESS;
            return (context, validationData);
        } else {
            validationData = SIG_VALIDATION_FAILED;
            return (context, validationData);
        }
    }

    /// @notice Adds a specified address to the whitelist.
    /// @dev This function can only be called by the owner.
    /// @param user The address to be added to the whitelist.
    function addAddress(address user) external onlyOwner {
        _whitelist[user] = true;
    }

    /// @notice Removes a specified address from the whitelist.
    /// @dev This function can only be called by the owner.
    /// @param user The address to be removed from the whitelist.
    function removeAddress(address user) external onlyOwner {
        _whitelist[user] = false;
    }

    /// @notice Checks if a specified address is whitelisted.
    /// @param user The address to check.
    /// @return True if the address is whitelisted, false otherwise.
    function checkWhitelist(address user) external view returns (bool) {
        return _whitelist[user];
    }
}
