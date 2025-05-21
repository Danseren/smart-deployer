// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC20 Airdroper - Utility contract for batch ERC20 token distribution
/// @notice Utility contract for batch airdropping ERC20 tokens
/// @dev Inherits from AbstractUtilityContract and Ownable for deployment and access control
contract ERC20Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Constructor initializes the contract with the sender as the initial owner
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of recipients that can be airdropped to in a single transaction
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC20 token contract to be used for airdrops
    IERC20 public token;

    /// @notice Amount of tokens to be distributed to each recipient
    uint256 public amount;

    /// @notice Treasury address holding the tokens for airdrop
    address public treasury;

    /// @dev Flag to prevent multiple initializations
    bool private initialized;

    /// @dev Error thrown when attempting to initialize the contract more than once
    error AlreadyInitialized();

    /// @dev Error thrown when input arrays have mismatched lengths
    error ArraysLengthMismatch();

    /// @dev Error thrown when the treasury has not approved enough tokens
    error NotEnoughApprovedTokens();

    /// @dev Error thrown when token transfer fails
    error TransferFailed();

    /// @dev Error thrown when attempting to airdrop to more recipients than the batch size limit
    error BatchSizeExceeded();

    /// @dev Modifier to ensure the contract has not been initialized before
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    /// @notice Performs batch airdrop of ERC20 tokens
    /// @dev Transfers tokens from treasury to specified receivers
    /// @param receivers Array of recipient addresses
    /// @param amounts Array of token amounts to transfer to each recipient
    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == amounts.length, ArraysLengthMismatch());
        require(token.allowance(treasury, address(this)) >= amount, NotEnoughApprovedTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < receivers.length;) {
            require(token.transferFrom(treasuryAddress, receivers[i], amounts[i]), TransferFailed());
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUtilityContract
    /// @dev Initializes the contract with deploy manager, token, amount, treasury, and owner
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, uint256 _amount, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, uint256, address, address));

        setDeployManager(_deployManager);

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Generates initialization data for the contract
    /// @dev Encodes initialization parameters for use with deploy manager
    /// @param _deployManager Address of the deploy manager
    /// @param _token Address of the ERC20 token contract
    /// @param _amount Amount of tokens to be distributed to each recipient
    /// @param _treasury Address of the treasury holding tokens
    /// @param _owner Address of the contract owner
    /// @return bytes Encoded initialization data
    function getInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _amount, _treasury, _owner);
    }
}
