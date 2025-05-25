// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

/// @title IUtilityContract - Interface for deployable utility contracts
/// @notice Defines the base interface that all utility contracts must implement
/// @dev Utility contracts should implement this interface to be compatible with the DeployManager.
interface IUtilityContract is IERC165 {
    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Error thrown when deploy manager address is zero
    error DeployManagerCannotBeZero();

    /// @dev Error thrown when caller is not the deploy manager
    error NotDeployManager();

    /// @dev Error thrown when deploy manager validation failed throw validateDeployManager()
    error FailedToValidateDeployManager();

    /// @dev Error thrown when contract is already initialized
    error AlreadyInitialized();

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Initializes the utility contract with provided data
    /// @dev This function should be called by the DeployManager after deploying the contract
    /// @param _initData Encoded initialization parameters
    /// @return bool Success status of initialization
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice Returns the address of the deploy manager
    /// @dev Used to verify contract deployment origin
    /// @return address The address of the deploy manager
    function getDeployManager() external view returns (address);
}
