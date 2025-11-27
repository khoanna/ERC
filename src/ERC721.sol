// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 private _tokenIds;
    string private baseURI;

    constructor(string memory _baseURI_) ERC721("MyNFT", "MNFT") {
        baseURI = _baseURI_;
    }

    function mint() public {
        _mint(msg.sender, _tokenIds);
        _tokenIds++;
    }

    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        _burn(tokenId);
    }

    function getURI(uint256 tokenId) public view returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return tokenURI(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
