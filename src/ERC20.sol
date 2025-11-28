// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MyToken {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _name = "MyToken";
        _symbol = "MTK";
    }

    // View functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Mint function for demonstration purposes
    function _mint(address to, uint256 amount) internal {
        _totalSupply += amount;
        _balances[to] += amount;
    }

    // Transfer function
    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[owner] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[owner] -= amount;
        _balances[to] += amount;
        return true;
    }

    // Approve function
    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _allowances[owner][spender] = amount;
        return true;
    }

    // Transfer from function
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(
            _balances[from] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            _allowances[from][msg.sender] >= amount,
            "ERC20: insufficient allowance"
        );
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }

    // Burn function
    function burn(uint256 amount) public returns (bool) {
        address owner = msg.sender;
        require(
            _balances[owner] >= amount,
            "ERC20: burn amount exceeds balance"
        );
        _balances[owner] -= amount;
        _totalSupply -= amount;
        return true;
    }
}
