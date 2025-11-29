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
    uint256 internal _defaultId = 0;

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
        _mint(_alice, _defaultId, _maxAmount);
        _mint(_bob, _defaultId, _maxAmount);
    }

    function testTotalSupply() public {
        assertEq(totalSupply(_defaultId), _maxAmount * 2);
    }

    function testBalanceOfSuccess() public {
        assertEq(balanceOf(_alice, _defaultId), _maxAmount);
        assertEq(balanceOf(_bob, _defaultId), _maxAmount);
    }

    function testTransferSuccess() public {
        transferERC1155(_alice, _mike, _defaultId, _maxAmount / 2);
        assertEq(balanceOf(_alice, _defaultId), _maxAmount / 2);
        assertEq(balanceOf(_mike, _defaultId), _maxAmount / 2);
    }

    function testTransferFromSpenderSuccess() public {
        approveERC1155(_bob, _alice, true);
        transferFromSpenderERC1155(
            _alice,
            _bob,
            _mike,
            _defaultId,
            _maxAmount / 2
        );
        assertEq(balanceOf(_bob, _defaultId), _maxAmount / 2);
        assertEq(balanceOf(_mike, _defaultId), _maxAmount / 2);
    }

    function testBurnSuccess() public {
        burnERC1155(_bob, _defaultId, _maxAmount / 3);
        assertEq(balanceOf(_bob, _defaultId), (_maxAmount * 2) / 3);
        assertEq(totalSupply(_defaultId), (_maxAmount * 5) / 3);
    }

    function testTransferNotExistRevert() public {
        _vm.expectRevert("Token does not exist");
        transferERC1155(_alice, _mike, _defaultId + 1, _maxAmount / 2);
    }

    function testTransferFromSpenderRevert() public {
        _vm.expectRevert("Caller is not owner nor approved");
        transferFromSpenderERC1155(
            _alice,
            _bob,
            _mike,
            _defaultId,
            _maxAmount / 2
        );
    }

    function testBurnRevert() public {
        _vm.expectRevert("Burn amount exceeds balance");
        burnERC1155(_bob, _defaultId, _maxAmount + 1);
    }

    function testUri() public {
        string memory expectedUri = string.concat(
            "https://token-cdn-domain/{id}.json",
            "0"
        );
        assertEq(getUri(_defaultId), expectedUri);
    }
}
