// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./IVesting.sol";

/// @title VestingLib
/// @notice Library for calculating vested and claimable token amounts
/// @dev Provides utility functions for vesting schedule calculations
library VestingLib {
    /// @notice Calculates the total amount of tokens vested at the current time
    /// @dev Computes vested tokens based on the vesting schedule, considering cliff period
    /// @param v Storage reference to the VestingInfo struct
    /// @return Amount of tokens vested
    function vestedAmount(IVesting.VestingInfo storage v) internal view returns (uint256) {
        if (block.timestamp < v.startTime + v.cliff) return 0;
        uint256 passed = block.timestamp - (v.startTime + v.cliff);
        if (passed >= v.duration) passed = v.duration;
        return (v.totalAmount * passed) / v.duration;
    }

    /// @notice Calculates the amount of tokens currently available to claim
    /// @dev Computes claimable tokens by subtracting already claimed tokens from vested amount
    /// @param v Storage reference to the VestingInfo struct
    /// @return Amount of tokens that can be claimed
    function claimableAmount(IVesting.VestingInfo storage v) internal view returns (uint256) {
        uint256 vested = vestedAmount(v);
        if (vested <= v.claimed) return 0;
        return vested - v.claimed;
    }
}
