// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/wAbel.sol";

contract wAbelScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        wAbel token = new wAbel();
        console2.log("wAbel deployed at:", address(token));
        vm.stopBroadcast();
    }
} 