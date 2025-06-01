// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/// @title MockERC20 - Simplified ERC20 token for testing purposes
/// @notice Provides basic ERC20 functionality with minimal implementation
/// @dev Intended for use in unit tests, not for production deployment
contract MockERC20 {
    /// @notice Token metadata
    string public name = "MockERC20";
    string public symbol = "MTK";
    uint8 public decimals = 18;

    /// @dev Internal tracking of total token supply
    uint256 internal _totalSupply;

    /// @dev Mapping of account balances
    mapping(address => uint256) internal _balanceOf;

    /// @dev Mapping of token allowances between accounts
    mapping(address => mapping(address => uint256)) internal _allowances;

    /// @notice Returns the total token supply
    /// @return Current total supply of tokens
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /// @notice Retrieves the token balance of an account
    /// @param account Address to check balance for
    /// @return Token balance of the specified account
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balanceOf[account];
    }

    /// @notice Checks the amount of tokens an owner has approved for a spender
    /// @param owner Address of token owner
    /// @param spender Address of token spender
    /// @return Remaining number of tokens the spender is allowed to spend
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /// @notice Approves a spender to spend a specific amount of tokens
    /// @param spender Address allowed to spend tokens
    /// @param amount Number of tokens to approve
    /// @return Boolean indicating successful approval
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    /// @notice Transfers tokens to a specified address
    /// @param to Recipient address
    /// @param amount Number of tokens to transfer
    /// @return Boolean indicating successful transfer
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        require(_balanceOf[msg.sender] >= amount, "balance");
        _balanceOf[msg.sender] -= amount;
        _balanceOf[to] += amount;
        return true;
    }

    /// @notice Transfers tokens from one address to another with allowance check
    /// @param from Address sending the tokens
    /// @param to Recipient address
    /// @param amount Number of tokens to transfer
    /// @return Boolean indicating successful transfer
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        require(_balanceOf[from] >= amount, "balance");
        require(_allowances[from][msg.sender] >= amount, "allowance");
        _balanceOf[from] -= amount;
        _balanceOf[to] += amount;
        return true;
    }

    /// @notice Mints new tokens to a specified address
    /// @dev Increases total supply and account balance
    /// @param to Address to receive minted tokens
    /// @param amount Number of tokens to mint
    function mint(address to, uint256 amount) external {
        _totalSupply += amount;
        _balanceOf[to] += amount;
    }
}
