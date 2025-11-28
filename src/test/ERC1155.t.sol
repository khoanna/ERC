// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {Fifa} from "../ERC1155.sol";

contract BaseSetup is DSTest, Fifa {
    Vm internal immutable _vm = Vm(HEVM_ADDRESS);

    Utilities internal _utils;
    address payable[] internal _users;

    address internal _alice;
    address internal _bob;

    function setUp() public virtual {
        _utils = new Utilities();
        _users = _utils.createUsers(5);

        _alice = _users[0];
        _vm.label(_alice, "Alice");

        _bob = _users[1];
        _vm.label(_bob, "Bob");
    }
}

contract HandleERC1155 is BaseSetup {
    uint256 internal _tokenId = 1;
    uint256 internal _mintAmount = 100;

    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    function mintToken(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        _vm.prank(address(this));
        this.mint(id, amount, data);
        this.safeTransferFrom(address(this), to, id, amount, data);
    }

    function burnToken(address from, uint256 id, uint256 amount) public {
        _vm.prank(address(this));
        this.burn(from, id, amount);
    }
}
