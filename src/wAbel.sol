// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract wAbel is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() ERC20("QdayTokenOfAbel", "QAbel") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    // 用户存款，mint 代币给自己
    function deposit(address to, uint256 amount) external onlyRole(ADMIN_ROLE) {
        _mint(msg.sender, amount);
    }

    // 用户取款，burn 自己的代币
    function withdraw(address from, uint256 amount) external onlyRole(ADMIN_ROLE) {
        _burn(msg.sender, amount);
    }
}
