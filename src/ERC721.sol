// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract MyNFT {
    using Strings for uint256;

    string private _name;
    string private _symbol;
    string private _baseURI;
    uint256 private _tokenId;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;

    constructor(string memory baseURI) {
        _name = "MyNFT";
        _symbol = "MNFT";
        _baseURI = baseURI;
    }

    // View functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(
            _owners[tokenId] != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string.concat(_baseURI, tokenId.toString());
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(
            isExists(tokenId),
            "ERC721: approved query for nonexistent token"
        );
        return _tokenApprovals[tokenId];
    }

    // Mint function
    function mint() public {
        uint256 tokenId = _tokenId;
        _owners[tokenId] = msg.sender;
        _balances[msg.sender] += 1;
        _tokenId++;
    }

    // Approve
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner, "ERC721: approve caller is not owner");
        _tokenApprovals[tokenId] = to;
    }

    // Transfer function
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(isExists(tokenId), "ERC721: transfer of nonexistent token");
        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(
            msg.sender == ownerOf(tokenId) ||
                msg.sender == _tokenApprovals[tokenId],
            "ERC721: transfer caller is not owner nor approved"
        );
        require(to != address(0), "ERC721: transfer to the zero address");
        _tokenApprovals[tokenId] = address(0);
        _owners[tokenId] = to;
        _balances[from] -= 1;
        _balances[to] += 1;
    }

    // Burn function
    function burn(uint256 tokenId) public {
        require(isExists(tokenId), "ERC721: burn of nonexistent token");
        require(
            ownerOf(tokenId) == msg.sender,
            "ERC721: burn caller is not owner"
        );
        _owners[tokenId] = address(0);
        _balances[msg.sender] -= 1;
    }

    // Helper function
    function isExists(uint256 tokenId) public view returns (bool) {
        return _owners[tokenId] != address(0);
    }
}
