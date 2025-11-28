// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {MyERC1155} from "../ERC1155.sol";

contract BaseSetup is DSTest, MyERC1155("https://token-cdn-domain/") {
    Vm internal immutable _vm = Vm(HEVM_ADDRESS);

    Utilities internal _utils;
    address payable[] internal _users;

    address internal _alice;
    address internal _bob;
    address internal _mike;

    function setUp() public virtual {
        _utils = new Utilities();
        _users = _utils.createUsers(5);

        _alice = _users[0];
        _bob = _users[1];
        _mike = _users[2];
    }
}

contract HandleERC1155 is BaseSetup {
    uint256 internal _maxAmount = 12e18;

    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    function approveERC1155(
        address owner,
        address operator,
        bool approved
    ) public {
        _vm.prank(owner);
        this.setApprovalForAll(operator, approved);
    }

    function transferERC1155(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public {
        _vm.prank(from);
        this.safeTransferFrom(from, to, id, amount);
    }

    function transferFromSpenderERC1155(
        address spender,
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public {
        _vm.prank(spender);
        this.safeTransferFrom(from, to, id, amount);
    }

    function getUri(uint256 id) public view returns (string memory) {
        return this.uri(id);
    }

    function burnERC1155(address from, uint256 id, uint256 amount) public {
        _vm.prank(from);
        this.burn(id, from, amount);
    }
}

contract BasicTest is HandleERC1155 {
    function setUp() public virtual override {
        HandleERC1155.setUp();
        _mint(_alice, 0, _maxAmount);
        _mint(_bob, 0, _maxAmount);
    }

    function testTotalSupply() public {
        assertEq(totalSupply(0), _maxAmount * 2);
    }

    function testBalanceOf() public {
        assertEq(balanceOf(_alice, 0), _maxAmount);
        assertEq(balanceOf(_bob, 0), _maxAmount);
    }

    function testTransfer() public {
        transferERC1155(_alice, _mike, 0, _maxAmount / 2);
        assertEq(balanceOf(_alice, 0), _maxAmount / 2);
        assertEq(balanceOf(_mike, 0), _maxAmount / 2);
    }

    function testTransferFromSpenderSuccess() public {
        approveERC1155(_bob, _alice, true);
        transferFromSpenderERC1155(_alice, _bob, _mike, 0, _maxAmount / 2);
        assertEq(balanceOf(_bob, 0), _maxAmount / 2);
        assertEq(balanceOf(_mike, 0), _maxAmount / 2);
    }

    function testBurnSuccess() public {
        burnERC1155(_bob, 0, _maxAmount / 3);
        assertEq(balanceOf(_bob, 0), (_maxAmount * 2) / 3);
        assertEq(totalSupply(0), (_maxAmount * 5) / 3);
    }

    function testTransferFromSpenderRevert() public {
        _vm.expectRevert("Caller is not owner nor approved");
        transferFromSpenderERC1155(_alice, _bob, _mike, 0, _maxAmount / 2);
    }

    function testBurnRevert() public {
        _vm.expectRevert("Burn amount exceeds balance");
        burnERC1155(_bob, 0, _maxAmount + 1);
    }

    function testUri() public {
        string memory expectedUri = string.concat(
            "https://token-cdn-domain/{id}.json",
            "0"
        );
        assertEq(getUri(0), expectedUri);
    }
}
