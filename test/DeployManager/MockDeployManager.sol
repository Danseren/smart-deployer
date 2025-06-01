// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IDeployManager} from "../../contracts/DeployManager/IDeployManager.sol";

/// @notice Mock implementation of DeployManager for testing purposes
/// @dev Allows controlled simulation of DeployManager interface behaviors
contract MockDeployManager is IDeployManager {
    /// @notice Flag to simulate interface support, controllable for testing
    bool public supportsIface = true;

    /// @notice Allows dynamic configuration of interface support flag
    /// @param v Boolean value to set interface support
    function setSupports(bool v) external {
        supportsIface = v;
    }

    /// @notice Simulates interface detection with configurable behavior
    /// @param interfaceId Interface identifier to check
    /// @return Whether the interface is supported based on internal flag
    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return supportsIface && interfaceId == type(IDeployManager).interfaceId;
    }

    /// @notice Mock deployment method that always returns zero address
    /// @dev Allows testing deployment failure scenarios without actual contract creation
    /// @return Always returns address(0) to simulate deployment failure or placeholder
    function deploy(address, bytes calldata) external payable override returns (address) {
        return address(0);
    }

    /// @notice Stub implementations of interface methods for testing
    /// @dev Provide no-op implementations to satisfy interface requirements
    function addNewContract(address, uint256, bool) external override {}
    function updateFee(address, uint256) external override {}
    function deactivateContract(address) external override {}
    function activateContract(address) external override {}
}
