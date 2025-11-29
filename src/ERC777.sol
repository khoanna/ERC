// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC777/IERC777Recipient.sol";
import "lib/openzeppelin-contracts/contracts/utils/introspection/IERC1820Registry.sol";

contract MyERC777 is ERC777 {
    constructor() ERC777("MyToken", "MTK", new address[](0)) {}

    function mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public {
        _mint(account, amount, userData, operatorData);
    }
}

contract TestERC777Recipient is IERC777Recipient {
    IERC1820Registry private constant _ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH =
        keccak256("ERC777TokensRecipient");

    uint256 public receivedTokens;
    uint256 public lastReceivedAmount;
    address public lastOperator;
    address public lastSender;

    event TokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes userData,
        bytes operatorData
    );

    constructor() {
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            _TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        receivedTokens += amount;
        lastReceivedAmount = amount;
        lastOperator = operator;
        lastSender = from;

        emit TokensReceived(operator, from, to, amount, userData, operatorData);
    }

    function getReceivedTokens() public view returns (uint256) {
        return receivedTokens;
    }

    function getLastReceivedInfo()
        public
        view
        returns (uint256, address, address)
    {
        return (lastReceivedAmount, lastOperator, lastSender);
    }
}
