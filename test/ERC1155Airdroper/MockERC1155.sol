// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @title MockERC1155 - Simplified ERC1155 token for testing purposes
/// @notice Provides basic ERC1155 functionality with minimal implementation
/// @dev Intended for use in unit tests, not for production deployment
contract MockERC1155 is IERC1155 {
    /// @dev Mapping of token balances for each account and token ID
    mapping(uint256 => mapping(address => uint256)) public balances;

    /// @dev Mapping of operator approvals for token management
    mapping(address => mapping(address => bool)) public operatorApprovals;

    /// @notice Mint tokens to a specific address
    /// @param to Address to receive the tokens
    /// @param id Token identifier
    /// @param amount Number of tokens to mint
    function mint(address to, uint256 id, uint256 amount) external {
        balances[id][to] += amount;
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }

    /// @notice Approve or remove approval for an operator to manage all tokens
    /// @param operator Address authorized to manage tokens
    /// @param approved Boolean indicating approval status
    function setApprovalForAll(address operator, bool approved) external override {
        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Check if an operator is approved to manage all tokens for an owner
    /// @param owner Token owner address
    /// @param operator Address to check for approval
    /// @return Whether the operator is approved
    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return operatorApprovals[owner][operator];
    }

    /// @notice Get the balance of a specific token for an account
    /// @param account Address to check balance
    /// @param id Token identifier
    /// @return Number of tokens owned
    function balanceOf(address account, uint256 id) external view override returns (uint256) {
        return balances[id][account];
    }

    /// @notice Get balances for multiple accounts and token IDs
    /// @param accounts Array of addresses to check
    /// @param ids Array of token identifiers
    /// @return Array of token balances
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            batchBalances[i] = balances[ids[i]][accounts[i]];
        }
        return batchBalances;
    }

    /// @notice Transfer tokens between addresses
    /// @param from Current token owner
    /// @param to Recipient address
    /// @param id Token identifier
    /// @param amount Number of tokens to transfer
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata) external override {
        require(balances[id][from] >= amount, "Not enough balance");
        balances[id][from] -= amount;
        balances[id][to] += amount;
        emit TransferSingle(msg.sender, from, to, id, amount);
    }

    /// @notice Batch transfer (not implemented in this mock)
    /// @dev Reverts to prevent unexpected behavior
    function safeBatchTransferFrom(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        override
    {
        revert("Not implemented");
    }

    /// @notice Check interface support
    /// @param interfaceId Interface identifier to check
    /// @return Whether the interface is supported
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId;
    }
}
