// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {MyToken} from "../ERC20.sol";

contract BaseSetup is DSTest, MyToken {
    Vm internal immutable _vm = Vm(HEVM_ADDRESS);

    Utilities internal _utils;
    address payable[] internal _users;

    address internal _alice;
    address internal _bob;

    function setUp() public virtual {
        _utils = new Utilities();
        _users = _utils.createUsers(5);

        _alice = _users[0];
        _bob = _users[1];
    }
}

contract HandleToken is BaseSetup {
    uint256 internal _maxTransferAmount = 12e18;

    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    function transferToken(
        address from,
        address to,
        uint256 transferAmount
    ) public returns (bool) {
        _vm.prank(from);
        return this.transfer(to, transferAmount);
    }

    function approveToken(
        address owner,
        address spender,
        uint256 amount
    ) public returns (bool) {
        _vm.prank(owner);
        return this.approve(spender, amount);
    }

    function burnToken(address from, uint256 burnAmount) public returns (bool) {
        _vm.prank(from);
        return this.burn(burnAmount);
    }

    function transferFromToken(
        address spender,
        address from,
        address to,
        uint256 transferAmount
    ) public returns (bool) {
        _vm.prank(spender);
        return this.transferFrom(from, to, transferAmount);
    }
}

contract SuccessTransferTest is HandleToken {
    uint256 internal _mintAmount = _maxTransferAmount;

    function setUp() public override {
        HandleToken.setUp();
        console.log("When Alice has sufficient funds");
        _mint(_alice, _mintAmount);
    }

    function itTransfersAmountCorrectly(
        address from,
        address to,
        uint256 amount
    ) public {
        uint256 fromBalance = balanceOf(from);
        bool success = transferToken(from, to, amount);

        assertTrue(success);
        assertEqDecimal(balanceOf(from), fromBalance - amount, decimals());
        assertEqDecimal(balanceOf(to), amount, decimals());
    }

    function testTransferAllTokens() public {
        uint256 t = _maxTransferAmount;
        itTransfersAmountCorrectly(_alice, _bob, t);
    }

    function testTransferHalfTokens() public {
        uint256 t = _maxTransferAmount / 2;
        itTransfersAmountCorrectly(_alice, _bob, t);
    }

    function testTransferOneToken() public {
        itTransfersAmountCorrectly(_alice, _bob, 1);
    }
}

contract SuccessTransferFromTest is HandleToken {
    uint256 internal _mintAmount = _maxTransferAmount;

    function setUp() public override {
        HandleToken.setUp();
        console.log("When Bob is approved to spend Alice's tokens");
        _mint(_alice, _mintAmount);
    }

    function itTransfersFromAmountCorrectly(
        address from,
        address to,
        uint256 amount
    ) public {
        uint256 fromBalance = balanceOf(from);
        bool success = transferFromToken(to, from, to, amount);

        assertTrue(success);
        assertEqDecimal(balanceOf(from), fromBalance - amount, decimals());
        assertEqDecimal(balanceOf(to), amount, decimals());
    }

    function itApprovesSpender(
        address owner,
        address spender,
        uint256 amount
    ) public {
        uint256 currentAllowance = allowance(owner, spender);
        _vm.prank(owner);
        bool success = this.approve(spender, amount);

        assertTrue(success);
        assertEqDecimal(
            allowance(owner, spender),
            currentAllowance + amount,
            decimals()
        );
    }

    function testTransferFromAllTokens() public {
        uint256 t = _maxTransferAmount;
        approveToken(_alice, _bob, t);
        itTransfersFromAmountCorrectly(_alice, _bob, t);
    }

    function testTransferFromHalfTokens() public {
        uint256 t = _maxTransferAmount / 2;
        approveToken(_alice, _bob, t);
        itTransfersFromAmountCorrectly(_alice, _bob, t);
    }
}

contract SuccesBurnTest is HandleToken {
    uint256 internal _mintAmount = _maxTransferAmount;

    function setUp() public override {
        HandleToken.setUp();
        console.log("When Alice has sufficient funds to burn");
        _mint(_alice, _mintAmount);
    }

    function itBurnsAmountCorrectly(address from, uint256 amount) public {
        uint256 fromBalance = balanceOf(from);
        bool success = burnToken(from, amount);

        assertTrue(success);
        assertEqDecimal(balanceOf(from), fromBalance - amount, decimals());
        assertEqDecimal(totalSupply(), _mintAmount - amount, decimals());
    }

    function testBurnAllTokens() public {
        uint256 t = _maxTransferAmount;
        itBurnsAmountCorrectly(_alice, t);
    }

    function testBurnHalfTokens() public {
        uint256 t = _maxTransferAmount / 2;
        itBurnsAmountCorrectly(_alice, t);
    }
}

contract RevertTransferTest is HandleToken {
    uint256 internal _mintAmount = _maxTransferAmount - 1e18;

    function setUp() public override {
        HandleToken.setUp();
        console.log("When Alice has insufficient funds");
        _mint(_alice, _mintAmount);
    }

    function itRevertsTransfer(
        address from,
        address to,
        uint256 amount,
        string memory expRevertMessage
    ) public {
        _vm.expectRevert(abi.encodePacked(expRevertMessage));
        transferToken(from, to, amount);
    }

    function testCannotTransferMoreThanAvailable() public {
        itRevertsTransfer(
            _alice,
            _bob,
            _maxTransferAmount,
            "ERC20: transfer amount exceeds balance"
        );
    }

    function testCannotTransferToZero() public {
        itRevertsTransfer(
            _alice,
            address(0),
            _mintAmount,
            "ERC20: transfer to the zero address"
        );
    }
}

contract RevertInsufficientAllowanceTest is HandleToken {
    uint256 internal _mintAmount = _maxTransferAmount;

    function setUp() public override {
        HandleToken.setUp();
        console.log("When Bob is not approved to spend Alice's tokens");
        _mint(_alice, _mintAmount);
    }

    function itRevertsTransferFrom(
        address from,
        address to,
        uint256 amount,
        string memory expRevertMessage
    ) public {
        _vm.expectRevert(abi.encodePacked(expRevertMessage));
        transferFromToken(to, from, to, amount);
    }

    function testCannotTransferFromWithoutApproval() public {
        itRevertsTransferFrom(
            _alice,
            _bob,
            _maxTransferAmount,
            "ERC20: insufficient allowance"
        );
    }

    function testCannotTransferFromMoreThanApproved() public {
        uint256 approvedAmount = _maxTransferAmount / 2;
        approveToken(_alice, _bob, approvedAmount);

        itRevertsTransferFrom(
            _alice,
            _bob,
            _maxTransferAmount,
            "ERC20: insufficient allowance"
        );
    }
}

contract RevertBurnTest is HandleToken {
    uint256 internal _mintAmount = _maxTransferAmount - 1e18;

    function setUp() public override {
        HandleToken.setUp();
        console.log("When Alice has insufficient funds to burn");
        _mint(_alice, _mintAmount);
    }

    function itRevertsBurn(
        address from,
        uint256 amount,
        string memory expRevertMessage
    ) public {
        _vm.expectRevert(abi.encodePacked(expRevertMessage));
        burnToken(from, amount);
    }

    function testCannotBurnMoreThanAvailable() public {
        itRevertsBurn(
            _alice,
            _maxTransferAmount,
            "ERC20: burn amount exceeds balance"
        );
    }
}
