// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC1155 Airdroper - Utility contract for batch ERC1155 token distribution
/// @notice Utility contract for batch airdropping ERC1155 tokens
/// @dev Inherits from AbstractUtilityContract and Ownable for deployment and access control
contract ERC1155Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Constructor initializes the contract with the sender as the initial owner
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of tokens that can be airdropped in a single transaction
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 10;

    /// @notice ERC1155 token contract to be used for airdrops
    IERC1155 public token;

    /// @notice Treasury address holding the tokens for airdrop
    address public treasury;

    /// @dev Error thrown when the number of receivers does not match other input arrays
    error RecieversLengthMismatch();

    /// @dev Error thrown when the number of amounts does not match other input arrays
    error AmountsLengthMismatch();

    /// @dev Error thrown when attempting to airdrop more tokens than the batch size limit
    error BatchSizeExceeded();

    /// @dev Error thrown when the treasury has not approved the contract to transfer tokens
    error NeedToApproveTokens();

    /// @notice Performs batch airdrop of ERC1155 tokens
    /// @dev Transfers tokens from treasury to specified receivers
    /// @param receivers Array of recipient addresses
    /// @param amounts Array of token amounts to transfer
    /// @param tokenIds Array of token IDs to transfer
    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds)
        external
        onlyOwner
    {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, RecieversLengthMismatch());
        require(amounts.length == tokenIds.length, AmountsLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < amounts.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i], amounts[i], "");
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUtilityContract
    /// @dev Initializes the contract with deploy manager, token, treasury, and owner
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC1155(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Generates initialization data for the contract
    /// @dev Encodes initialization parameters for use with deploy manager
    /// @param _deployManager Address of the deploy manager
    /// @param _token Address of the ERC1155 token contract
    /// @param _treasury Address of the treasury holding tokens
    /// @param _owner Address of the contract owner
    /// @return bytes Encoded initialization data
    function getInitData(address _deployManager, address _token, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}
