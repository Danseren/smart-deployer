// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

interface IVesting {
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

    struct VestingParams {
        address beneficiary;
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
        uint256 claimCooldown;
        uint256 minClaimAmount;
    }

    event VestingCreated(address indexed beneficiary, uint256 amount, uint256 creationTime);

    event TokensWithdrawn(address indexed to, uint256 amount);

    event Claim(address indexed beneficiary, uint256 amount, uint256 timestamp);

    error VestingNotFound();

    error ClaimNotAvailable(uint256 blockTimestamp, uint256 availableFrom);

    error NothingToClaim();

    error InfsufficientBalance(uint256 availableBalance, uint256 totalAmount);

    error VestingAlreadyExist();

    error AmountCantBeZero();

    error StartTimeShouldBeFuture(uint256 startTime, uint256 blockTimestamp);

    error DurationCantBeZero();

    error CooldownCantBeLongerThanDuration();

    error InvalidBeneficiary();

    error BelowMinimalClaimAmount(uint256 minClaimAmount, uint256 lastClaimTime);

    error CooldownNotPassed(uint256 blockTimestamp, uint256 lastClaimTime);

    error NothingToWithdraw();

    function claim() external;

    function startVesting(VestingParams calldata params) external;

    function vestedAmount(address _claimer) external view returns (uint256);

    function claimableAmount(address _claimer) external view returns (uint256);

    function withdrawUnallocated(address _to) external;

    function getInitData(address _deployManager, address _token, address _owner) external view returns (bytes memory);
}
