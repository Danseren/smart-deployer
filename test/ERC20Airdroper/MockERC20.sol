// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract MockERC20 {
    string public name = "MockERC20";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 internal _totalSupply;

    mapping(address => uint256) internal _balanceOf;
    mapping(address => mapping(address => uint256)) internal _allowances;

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balanceOf[account];
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        require(_balanceOf[msg.sender] >= amount, "balance");
        _balanceOf[msg.sender] -= amount;
        _balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        require(_balanceOf[from] >= amount, "balance");
        require(_allowances[from][msg.sender] >= amount, "allowance");
        _balanceOf[from] -= amount;
        _balanceOf[to] += amount;
        return true;
    }

    function mint(address to, uint256 amount) external {
        _totalSupply += amount;
        _balanceOf[to] += amount;
    }
}
