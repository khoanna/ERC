// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {MyToken} from "../ERC20.sol";

contract ERC20Script is Script {
    MyToken public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myToken = new MyToken();

        vm.stopBroadcast();
    }
}
