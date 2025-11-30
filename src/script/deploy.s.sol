// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {
    IEntryPoint
} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {SimpleAccount} from "../ERC4337/SimpleAccount.sol";
import {Paymaster} from "../ERC4337/Paymaster.sol";

contract SimpleAccountScript is Script {
    SimpleAccount public simpleAccount;

    function setUp() public {}

    address constant ENTRY_POINT_ADDRESS =
        0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    address constant OWNER_ADDRESS = 0xd5de8324D526A201672B30584e495C71BeBb3e9A;

    function run() public {
        vm.startBroadcast();

        simpleAccount = new SimpleAccount(ENTRY_POINT_ADDRESS, OWNER_ADDRESS);

        vm.stopBroadcast();
    }
}

contract PaymasterScript is Script {
    Paymaster public paymaster;

    function setUp() public {}

    address constant ENTRY_POINT_ADDRESS =
        0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    function run() public {
        vm.startBroadcast();

        IEntryPoint(ENTRY_POINT_ADDRESS).depositTo{value: 0.1 ether}(
            address(0xd7a66Ece1719FBC6593181615bfb6d2F28664416)
        );

        vm.stopBroadcast();
    }
}
