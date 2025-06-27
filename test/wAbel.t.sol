// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/wAbel.sol";

contract wAbelTest is Test {
    wAbel token;
    address admin = address(0xABCD);
    address user = address(0x1234);

    function setUp() public {
        vm.prank(admin);
        token = new wAbel();
    }

    function testAdminHasRole() public {
        assertTrue(token.hasRole(token.ADMIN_ROLE(), admin));
    }

    function testDepositByAdmin() public {
        vm.prank(admin);
        token.deposit(admin, 100 ether);
        assertEq(token.balanceOf(admin), 100 ether);
    }

    function testDepositByUserShouldFail() public {
        vm.prank(user);
        vm.expectRevert();
        token.deposit(user, 100 ether);
    }

    function testWithdrawByAdmin() public {
        vm.startPrank(admin);
        token.deposit(admin, 100 ether);
        token.withdraw(admin, 50 ether);
        assertEq(token.balanceOf(admin), 50 ether);
        vm.stopPrank();
    }

    function testWithdrawByUserShouldFail() public {
        vm.prank(user);
        vm.expectRevert();
        token.withdraw(user, 10 ether);
    }
} 