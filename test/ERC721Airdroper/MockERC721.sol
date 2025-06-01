// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title MockERC721 - Simplified ERC721 token for testing purposes
/// @notice Provides basic ERC721 functionality with minimal implementation
/// @dev Intended for use in unit tests, not for production deployment
contract MockERC721 is IERC721 {
    /// @notice Token metadata
    string public name = "MockERC721";
    string public symbol = "M721";

    /// @dev Mapping of token owners
    mapping(uint256 => address) public owners;

    /// @dev Mapping of operator approvals
    mapping(address => mapping(address => bool)) public operatorApprovals;

    /// @dev Mapping of token balances per address
    mapping(address => uint256) public balances;

    /// @dev Mapping of token-specific approvals
    mapping(uint256 => address) public tokenApprovals;

    /// @notice Mint a new token to a specified address
    /// @param to Address to receive the token
    /// @param tokenId Unique identifier for the token
    function mint(address to, uint256 tokenId) external {
        owners[tokenId] = to;
        balances[to] += 1;
        emit Transfer(address(0), to, tokenId);
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

    /// @notice Get the owner of a specific token
    /// @param tokenId Token identifier
    /// @return Address of the token owner
    function ownerOf(uint256 tokenId) external view override returns (address) {
        return owners[tokenId];
    }

    /// @notice Get the number of tokens owned by an address
    /// @param owner Address to check token balance
    /// @return Number of tokens owned
    function balanceOf(address owner) external view override returns (uint256) {
        return balances[owner];
    }

    /// @notice Transfer a token from one address to another
    /// @param from Current token owner
    /// @param to Recipient address
    /// @param tokenId Token to transfer
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(owners[tokenId] == from, "Not owner");
        owners[tokenId] = to;
        balances[from] -= 1;
        balances[to] += 1;
        emit Transfer(from, to, tokenId);
    }

    /// @notice Standard transfer method calling internal safe transfer
    /// @param from Current token owner
    /// @param to Recipient address
    /// @param tokenId Token to transfer
    function transferFrom(address from, address to, uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId);
    }

    /// @notice Approve an address to transfer a specific token
    /// @param to Address to approve
    /// @param tokenId Token to approve for transfer
    function approve(address to, uint256 tokenId) external override {
        tokenApprovals[tokenId] = to;
        emit Approval(owners[tokenId], to, tokenId);
    }

    /// @notice Get the address approved for a specific token
    /// @param tokenId Token to check
    /// @return Approved address for the token
    function getApproved(uint256 tokenId) external view override returns (address) {
        return tokenApprovals[tokenId];
    }

    /// @notice Safe transfer with additional data (simplified implementation)
    /// @param from Current token owner
    /// @param to Recipient address
    /// @param tokenId Token to transfer
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata) external override {
        safeTransferFrom(from, to, tokenId);
    }

    /// @notice Check interface support
    /// @param interfaceId Interface identifier to check
    /// @return Whether the interface is supported
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC721).interfaceId;
    }
}
