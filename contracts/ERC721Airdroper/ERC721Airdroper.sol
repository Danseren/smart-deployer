// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC721 Airdroper - Utility contract for batch ERC721 token distribution
/// @notice Utility contract for batch airdropping ERC721 tokens
/// @dev Inherits from AbstractUtilityContract and Ownable for deployment and access control
contract ERC721Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Constructor initializes the contract with the sender as the initial owner
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of NFTs that can be airdropped in a single transaction
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC721 token contract to be used for airdrops
    IERC721 public token;

    /// @notice Treasury address holding the NFTs for airdrop
    address public treasury;

    /// @dev Flag to prevent multiple initializations
    bool private initialized;

    /// @dev Error thrown when attempting to initialize the contract more than once
    error AlreadyInitialized();

    /// @dev Error thrown when input arrays have mismatched lengths
    error ArraysLengthMismatch();

    /// @dev Error thrown when the treasury has not approved the contract to transfer tokens
    error NeedToApproveTokens();

    /// @dev Error thrown when attempting to airdrop more NFTs than the batch size limit
    error BatchSizeExceeded();

    /// @dev Modifier to ensure the contract has not been initialized before
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    /// @notice Performs batch airdrop of ERC721 tokens
    /// @dev Transfers NFTs from treasury to specified receivers
    /// @param receivers Array of recipient addresses
    /// @param tokenIds Array of token IDs to transfer
    function airdrop(address[] calldata receivers, uint256[] calldata tokenIds) external onlyOwner {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ArraysLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < tokenIds.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i]);
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

        token = IERC721(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Generates initialization data for the contract
    /// @dev Encodes initialization parameters for use with deploy manager
    /// @param _deployManager Address of the deploy manager
    /// @param _token Address of the ERC721 token contract
    /// @param _treasury Address of the treasury holding NFTs
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
