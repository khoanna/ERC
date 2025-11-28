// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Fifa is ERC1155 {
    address private admin;

    constructor() ERC1155("https://fifa-game-api/{id}.json") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function mint(
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyAdmin {
        _mint(msg.sender, id, amount, data);
    }

    function mintBatch(
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyAdmin {
        _mintBatch(msg.sender, ids, amounts, data);
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public onlyAdmin {
        _burn(account, id, amount);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public onlyAdmin {
        _burnBatch(account, ids, amounts);
    }

    function updateURI(string memory newuri) public onlyAdmin {
        _setURI(newuri);
    }
}
