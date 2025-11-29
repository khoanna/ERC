// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {
    EntryPoint
} from "../../lib/account-abstraction/contracts/core/EntryPoint.sol";
import {
    PackedUserOperation
} from "../../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Paymaster} from "../ERC4337/Paymaster.sol";
import {
    Ownable
} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {
    SIG_VALIDATION_FAILED,
    SIG_VALIDATION_SUCCESS
} from "../../lib/account-abstraction/contracts/core/Helpers.sol";

contract PaymasterHarness is Paymaster {
    constructor(EntryPoint entryPoint) Paymaster(entryPoint) {}

    function exposeValidatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) external view returns (bytes memory context, uint256 validationData) {
        return _validatePaymasterUserOp(userOp, userOpHash, maxCost);
    }
}

contract BaseSetup is DSTest {
    Vm internal immutable _vm = Vm(HEVM_ADDRESS);
    PaymasterHarness internal _paymaster;

    EntryPoint internal _entryPoint;
    address internal _entryPointAddress;

    Utilities internal _utils;
    address payable[] internal _users;

    uint256 internal _ownerKey = 111;
    address internal _owner;

    uint256 internal _aliceKey = 222;
    address internal _alice;

    function setUp() public {
        _owner = _vm.addr(_ownerKey);
        _alice = _vm.addr(_aliceKey);

        _entryPoint = new EntryPoint();
        _entryPointAddress = address(_entryPoint);

        _vm.startPrank(_owner);
        _paymaster = new PaymasterHarness(_entryPoint);
        _vm.stopPrank();
    }
}

contract PaymasterTest is BaseSetup {
    function testOwnerCanAddAndRemoveAddressesFromWhitelist() public {
        _vm.prank(_owner);
        _paymaster.addAddress(_alice);
        _vm.assertTrue(_paymaster.checkWhitelist(_alice));

        _vm.prank(_owner);
        _paymaster.removeAddress(_alice);
        _vm.assertFalse(_paymaster.checkWhitelist(_alice));
    }
    function testAddAddressThrowErrorWhenCalledByNonOwner() public {
        address testUser = _vm.addr(999);

        _vm.expectRevert(abi.encodePacked("Ownable: caller is not the owner"));
        _paymaster.addAddress(testUser);
    }

    function testRemoveAddressThrowErrorWhenCalledByNonOwner() public {
        address testUser = _vm.addr(999);

        _vm.expectRevert(abi.encodePacked("Ownable: caller is not the owner"));
        _paymaster.removeAddress(testUser);
    }

    function testValidationWorkForWhitelistedAddresses() public {
        _vm.prank(_owner);
        _paymaster.addAddress(_alice);

        PackedUserOperation memory userOp = PackedUserOperation({
            sender: _alice,
            nonce: 1,
            initCode: hex"",
            callData: hex"",
            accountGasLimits: hex"",
            preVerificationGas: type(uint64).max,
            gasFees: hex"",
            paymasterAndData: hex"",
            signature: hex""
        });

        _vm.prank(address(_entryPoint));
        (bytes memory context, uint256 validationData) = _paymaster
            .exposeValidatePaymasterUserOp(userOp, hex"", 0);

        assertEq(validationData, SIG_VALIDATION_SUCCESS);
        assertEq(bytes32(context), hex"");
    }

    function testPaymasterValidationFailsForNonWhitelistAddress() public {
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: _alice,
            nonce: 1,
            initCode: hex"",
            callData: hex"",
            accountGasLimits: hex"",
            preVerificationGas: type(uint64).max,
            gasFees: hex"",
            paymasterAndData: hex"",
            signature: hex""
        });

        _vm.prank(address(_entryPoint));
        (bytes memory context, uint256 validationData) = _paymaster
            .exposeValidatePaymasterUserOp(userOp, hex"", 0);

        assertEq(validationData, SIG_VALIDATION_FAILED);
        assertEq(bytes32(context), hex"");
    }
}
