// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/// @title IVesting - Interface for token vesting mechanism
/// @notice Defines the core functionality for a token vesting contract
/// @dev Provides structures and methods for creating and managing token vesting schedules
interface IVesting {
    /// @notice Information about a beneficiary's vesting schedule
    /// @param totalAmount Total number of tokens to be vested
    /// @param startTime Timestamp when vesting begins
    /// @param cliff Duration of the cliff period in seconds
    /// @param duration Total duration of the vesting period in seconds
    /// @param claimed Amount of tokens already claimed
    /// @param lastClaimTime Timestamp of the last claim
    /// @param claimCooldown Minimum time interval between claims in seconds
    /// @param minClaimAmount Minimum amount that can be claimed in a single transaction
    /// @param created Indicates whether the vesting schedule has been created  
    struct VestingInfo {
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
        uint256 claimed;
        uint256 lastClaimTime;
        uint256 claimCooldown;
        uint256 minClaimAmount;
        bool created;
    }

    /// @notice Parameters for creating a new vesting schedule in startVesting function
    /// @param beneficiary Address that will receive vested tokens
    /// @param totalAmount Total number of tokens to be vested
    /// @param startTime Timestamp when vesting begins
    /// @param cliff Duration of the cliff period in seconds
    /// @param duration Total duration of the vesting period in seconds
    /// @param claimCooldown Minimum time interval between claims in seconds
    /// @param minClaimAmount Minimum amount that can be claimed in a single transaction
    struct VestingParams {
        address beneficiary;
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
        uint256 claimCooldown;
        uint256 minClaimAmount;
    }

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Event emitted when a new vesting schedule is created
    /// @param beneficiary Address of the token recipient
    /// @param amount Total amount of tokens to be vested
    /// @param creationTime Timestamp of vesting schedule creation
    event VestingCreated(address indexed beneficiary, uint256 amount, uint256 creationTime);

    /// @notice Event emitted when tokens are withdrawn
    /// @param to Address receiving the withdrawn tokens
    /// @param amount Amount of tokens withdrawn
    event TokensWithdrawn(address indexed to, uint256 amount);

    /// @notice Event emitted when tokens are claimed
    /// @param beneficiary Address claiming the tokens
    /// @param amount Amount of tokens claimed
    /// @param timestamp Timestamp of the claim
    event Claim(address indexed beneficiary, uint256 amount, uint256 timestamp);

    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------


    /// @dev Error thrown when attempting to interact with a non-existent vesting schedule
    error VestingNotFound();

    /// @dev Error thrown when trying to claim tokens before they are available
    /// @param blockTimestamp Current block timestamp
    /// @param availableFrom Timestamp when tokens become available
    error ClaimNotAvailable(uint256 blockTimestamp, uint256 availableFrom);

    /// @dev Error thrown when there are no tokens available to claim
    error NothingToClaim();

    /// @dev Error thrown when attempting to claim more tokens than available
    /// @param availableBalance Current available balance
    /// @param totalAmount Total amount requested
    error InfsufficientBalance(uint256 availableBalance, uint256 totalAmount);

    /// @dev Error thrown when trying to create a vesting schedule that already exists
    error VestingAlreadyExist();

    /// @dev Error thrown when attempting to create a vesting schedule with zero amount
    error AmountCantBeZero();

    /// @dev Error thrown when vesting start time is not in the future
    /// @param startTime Proposed start time
    /// @param blockTimestamp Current block timestamp
    error StartTimeShouldBeFuture(uint256 startTime, uint256 blockTimestamp);

    /// @dev Error thrown when vesting duration is zero
    error DurationCantBeZero();

    /// @dev Error thrown when claim cooldown is longer than vesting duration
    error CooldownCantBeLongerThanDuration();

    /// @dev Error thrown when beneficiary address is invalid
    error InvalidBeneficiary();

    /// @dev Error thrown when claim amount is below the minimum claim amount
    /// @param minClaimAmount Minimum allowed claim amount
    /// @param lastClaimTime Timestamp of last claim
    error BelowMinimalClaimAmount(uint256 minClaimAmount, uint256 lastClaimTime);

    /// @dev Error thrown when claim cooldown period has not passed
    /// @param blockTimestamp Current block timestamp
    /// @param lastClaimTime Timestamp of last claim
    error CooldownNotPassed(uint256 blockTimestamp, uint256 lastClaimTime);

    /// @dev Error thrown when there are no tokens to withdraw
    error NothingToWithdraw();

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Allows beneficiary to claim vested tokens
    function claim() external;

    /// @notice Starts a new vesting schedule
    /// @param params Vesting parameters for the new schedule
    function startVesting(VestingParams calldata params) external;

    /// @notice Calculates the total amount of tokens vested for a beneficiary
    /// @param _claimer Address of the beneficiary
    /// @return Total vested amount
    function vestedAmount(address _claimer) external view returns (uint256);

    /// @notice Calculates the amount of tokens currently claimable
    /// @param _claimer Address of the beneficiary
    /// @return Claimable amount of tokens
    function claimableAmount(address _claimer) external view returns (uint256);

    /// @notice Withdraws unallocated tokens
    /// @param _to Address to receive unallocated tokens
    function withdrawUnallocated(address _to) external;

    /// @notice Generates initialization data for the contract
    /// @param _deployManager Address of the deploy manager
    /// @param _token Address of the token contract
    /// @param _owner Address of the contract owner
    /// @return Encoded initialization data
    function getInitData(address _deployManager, address _token, address _owner) external view returns (bytes memory);
}
