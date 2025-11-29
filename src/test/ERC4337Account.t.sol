// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {
    ECDSA
} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import {
    EntryPoint
} from "../../lib/account-abstraction/contracts/core/EntryPoint.sol";
import {
    PackedUserOperation
} from "../../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {
    SIG_VALIDATION_FAILED,
    SIG_VALIDATION_SUCCESS
} from "../../lib/account-abstraction/contracts/core/Helpers.sol";
import {SimpleAccount} from "../ERC4337/SimpleAccount.sol";

contract SimpleAccountHarness is SimpleAccount {
    constructor(
        address entryPoint,
        address owner
    ) SimpleAccount(entryPoint, owner) {}

    // exposes `_validateSignature` for testing
    function validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) external returns (uint256) {
        return _validateSignature(userOp, userOpHash);
    }
}

contract RevertsOnEthTransfer {
    fallback() external {
        revert("");
    }
}

contract BaseSetup is DSTest {
    Vm internal immutable _vm = Vm(HEVM_ADDRESS);
    SimpleAccountHarness internal _aliceAccount;
    EntryPoint internal _entryPoint;

    Utilities internal _utils;
    address payable[] internal _users;

    address internal _entryPointAddress;

    uint256 internal _aliceKey = 123;
    address internal _alice;
    uint256 internal _bobKey = 456;
    address internal _bob;

    function setUp() public virtual {
        _utils = new Utilities();
        _users = _utils.createUsers(5);

        _alice = _vm.addr(_aliceKey);
        _bob = _vm.addr(_bobKey);

        _entryPoint = new EntryPoint();
        _entryPointAddress = address(_entryPoint);

        _aliceAccount = new SimpleAccountHarness(address(_entryPoint), _alice);

        _vm.deal(address(_aliceAccount), 10 ether);
    }
}

contract ERC4337Test is BaseSetup {
    function testStateVariables() public {
        address contractOwner = _aliceAccount.getOwner();
        address contractEntryPoint = address(_aliceAccount.entryPoint());

        assertEq(_alice, contractOwner);
        assertEq(_entryPointAddress, contractEntryPoint);
    }

    function testExecuteFunction() public {
        // Arrange
        uint256 initalBalanceOfRandomUser = _bob.balance;
        uint256 initalBalanceOfAccountContract = address(_aliceAccount).balance;

        uint256 valueToSend = 1 ether;

        // Act
        _vm.prank(address(_entryPoint));
        _aliceAccount.execute(_bob, valueToSend, "");

        // Assert
        assertEq(_bob.balance, initalBalanceOfRandomUser + valueToSend);
        assertEq(
            address(_aliceAccount).balance,
            initalBalanceOfAccountContract - valueToSend
        );
    }

    function testExecuteRevertsWithCorrectError() public {
        // Arrange
        uint256 valueToSend = 1 ether;

        // Act + Assert
        _vm.prank(_bob);
        _vm.expectRevert(bytes("account: not from EntryPoint"));
        _aliceAccount.execute(_bob, valueToSend, "");
    }

    function testCallFromExecuteFails() public {
        // Arrange
        RevertsOnEthTransfer revertsOnEthTransfer = new RevertsOnEthTransfer();

        uint256 valueToSend = 1 ether;

        // Act + Assert
        _vm.prank(address(_entryPoint));
        _vm.expectRevert(SimpleAccount.SimpleAccount__CallFailed.selector);
        _aliceAccount.execute(address(revertsOnEthTransfer), valueToSend, "");
    }

    function testSigAndSignedUserOpSuccess() public {
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: address(_aliceAccount),
            nonce: 1,
            initCode: hex"",
            callData: hex"",
            accountGasLimits: hex"",
            preVerificationGas: type(uint64).max,
            gasFees: hex"",
            paymasterAndData: hex"",
            signature: hex""
        });

        bytes32 userOpHash = _entryPoint.getUserOpHash(userOp);
        bytes32 formattedUserOpHash = ECDSA.toEthSignedMessageHash(userOpHash);

        (uint8 v, bytes32 r, bytes32 s) = _vm.sign(
            _aliceKey,
            formattedUserOpHash
        );

        userOp.signature = abi.encodePacked(r, s, v);

        uint256 result = _aliceAccount.validateSignature(userOp, userOpHash);

        // Assert
        assertEq(result, SIG_VALIDATION_SUCCESS);
    }

    function testSigAndSignedUserOpRevert() public {
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: address(_aliceAccount),
            nonce: 1,
            initCode: hex"",
            callData: hex"",
            accountGasLimits: hex"",
            preVerificationGas: type(uint64).max,
            gasFees: hex"",
            paymasterAndData: hex"",
            signature: hex""
        });

        bytes32 userOpHash = _entryPoint.getUserOpHash(userOp);
        bytes32 formattedUserOpHash = ECDSA.toEthSignedMessageHash(userOpHash);

        (uint8 v, bytes32 r, bytes32 s) = _vm.sign(
            _bobKey,
            formattedUserOpHash
        );

        userOp.signature = abi.encodePacked(r, s, v);

        uint256 result = _aliceAccount.validateSignature(userOp, userOpHash);

        // Assert
        assertEq(result, SIG_VALIDATION_FAILED);
    }
}
