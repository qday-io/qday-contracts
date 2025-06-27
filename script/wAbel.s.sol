// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/wAbel.sol";

contract wAbelScript is Script {
    function setUp() public {}

    function run() public {
        // 检查私钥是否存在
        if (vm.envOr("PRIVATE_KEY", uint256(0)) == 0) {
            revert("PRIVATE_KEY not set in .env");
        }
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deployer address:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        wAbel token = new wAbel();
        console2.log("wAbel deployed at:", address(token));
        vm.stopBroadcast();
    }
} 