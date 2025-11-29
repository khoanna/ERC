// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract MyERC1155 {
    using Strings for uint256;

    string private _uri;
    // Token Id => Account => Balance
    mapping(uint256 => mapping(address => uint256)) private _balances;
    // Token Id => Total Supply
    mapping(uint256 => uint256) private _totalSupply;
    // Accoount => Operator => Approved
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory uri_) {
        _uri = uri_;
    }

    // View function
    function uri(uint256 id) public view returns (string memory) {
        return string.concat(_uri, id.toString(), ".json");
    }

    function balanceOf(
        address account,
        uint256 id
    ) public view returns (uint256) {
        require(isExist(id), "Token does not exist");
        require(account != address(0), "Balance query for the zero address");
        return _balances[id][account];
    }

    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    // Mint functions
    function _mint(address to, uint256 id, uint256 amount) internal {
        require(to != address(0), "Mint to the zero address");
        _balances[id][to] += amount;
        _totalSupply[id] += amount;
    }

    // Burn functions
    function burn(uint256 id, address from, uint256 amount) public {
        require(isExist(id), "Token does not exist");
        require(msg.sender == from, "Can only burn from own account");
        require(from != address(0), "Burn from the zero address");
        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "Burn amount exceeds balance");
        _balances[id][from] = fromBalance - amount;
        _totalSupply[id] -= amount;
    }

    // Approve function
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Setting approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
    }

    // Transfer functions
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public {
        require(isExist(id), "Token does not exist");
        require(
            from == msg.sender || _operatorApprovals[from][msg.sender],
            "Caller is not owner nor approved"
        );
        require(to != address(0), "Transfer to the zero address");
        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "Transfer amount exceeds balance");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;
    }

    // Helper function
    function isExist(uint256 id) public view returns (bool) {
        return _totalSupply[id] > 0;
    }
}
