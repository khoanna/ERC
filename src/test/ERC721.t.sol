// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {MyNFT} from "../ERC721.sol";

contract BaseSetup is DSTest, MyNFT("https://mybaseuri.com/") {
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

contract HandleNFT is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    function mintNFT(address to) public {
        _vm.prank(to);
        this.mint();
    }

    function burnNFT(address from, uint256 tokenId) public {
        _vm.prank(from);
        this.burn(tokenId);
    }

    function transferNFT(address from, address to, uint256 tokenId) public {
        _vm.prank(from);
        this.transferFrom(from, to, tokenId);
    }

    function transferNFTFromSpender(
        address spender,
        address from,
        address to,
        uint256 tokenId
    ) public {
        _vm.prank(spender);
        this.transferFrom(from, to, tokenId);
    }

    function approveNFT(
        address owner,
        address approved,
        uint256 tokenId
    ) public {
        _vm.prank(owner);
        this.approve(approved, tokenId);
    }
}

contract SuccessTransferTest is HandleNFT {
    function setUp() public override {
        HandleNFT.setUp();
        mintNFT(_alice);
    }

    function itTransferFromOwner(
        address from,
        address to,
        uint256 tokenId
    ) public {
        uint256 fromBalance = balanceOf(from);
        uint256 toBalance = balanceOf(to);

        transferNFT(from, to, tokenId);

        assertEq(balanceOf(from), fromBalance - 1);
        assertEq(balanceOf(to), toBalance + 1);
        assertEq(this.ownerOf(tokenId), to);
    }

    function testTransfer() public {
        itTransferFromOwner(_alice, _bob, 0);
    }
}

contract SuccessBurnTest is HandleNFT {
    function setUp() public override {
        HandleNFT.setUp();
        mintNFT(_alice);
    }

    function itBurnsNFT(address owner, uint256 tokenId) public {
        uint256 ownerBalance = balanceOf(owner);

        burnNFT(owner, tokenId);

        assertEq(balanceOf(owner), ownerBalance - 1);
    }

    function testBurn() public {
        itBurnsNFT(_alice, 0);
    }
}

contract SuccessTransferFromSpenderTest is HandleNFT {
    function setUp() public override {
        HandleNFT.setUp();
        mintNFT(_alice);
        approveNFT(_alice, _bob, 0);
    }

    function itTransferFromSpender(
        address spender,
        address from,
        address to,
        uint256 tokenId
    ) public {
        uint256 fromBalance = balanceOf(from);
        uint256 toBalance = balanceOf(to);

        transferNFTFromSpender(spender, from, to, tokenId);

        assertEq(balanceOf(from), fromBalance - 1);
        assertEq(balanceOf(to), toBalance + 1);
        assertEq(this.ownerOf(tokenId), to);
    }

    function testTransferFromSpender() public {
        itTransferFromSpender(_bob, _alice, _bob, 0);
    }
}

contract RevertAddressZeroTest is HandleNFT {
    function setUp() public override {
        HandleNFT.setUp();
        mintNFT(_alice);
    }

    function itCannotTransferToAddressZero(
        address from,
        uint256 tokenId,
        string memory expRevertMessage
    ) public {
        _vm.expectRevert(abi.encodePacked(expRevertMessage));
        transferNFT(from, address(0), tokenId);
    }

    function testCannotTransferToAddressZero() public {
        itCannotTransferToAddressZero(
            _alice,
            0,
            "ERC721: transfer to the zero address"
        );
    }
}

contract RevertBurnTest is HandleNFT {
    function setUp() public override {
        HandleNFT.setUp();
        mintNFT(_alice);
    }

    function itCannotBurnIfNotOwner(
        address caller,
        uint256 tokenId,
        string memory expRevertMessage
    ) public {
        _vm.expectRevert(abi.encodePacked(expRevertMessage));
        burnNFT(caller, tokenId);
    }

    function testCannotBurnIfNotOwner() public {
        itCannotBurnIfNotOwner(_bob, 0, "ERC721: burn caller is not owner");
    }
}
