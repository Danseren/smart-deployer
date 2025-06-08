// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.9;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title ERC20Mock Token
/// @notice A simple mock ERC20 token for testing and development purposes
/// @dev Mints a fixed amount of tokens to a specified recipient during deployment
contract ERC20Mock is ERC20 {
    /// @notice Initializes the mock token with a fixed supply
    /// @param recipient Address that will receive the initial token supply
    /// @dev Mints 10,000 tokens multiplied by the token's decimal precision
    constructor(address recipient) payable ERC20("MyToken", "MTK") {
        _mint(recipient, 10_000 * 10 ** decimals());
    }
}
