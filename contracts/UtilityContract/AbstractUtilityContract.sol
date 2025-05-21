// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IDeployManager} from "../DeployManager/IDeployManager.sol";
import {IUtilityContract} from "./IUtilityContract.sol";

/// @title AbstractUtilityContract
/// @notice Base abstract contract for utility contracts managed by DeployManager
/// @dev Provides core implementation for utility contract initialization and deploy manager validation
abstract contract AbstractUtilityContract is IUtilityContract, ERC165 {
    /// @notice Address of the deploy manager for this utility contract
    /// @dev Stores the address of the contract responsible for deploying this utility contract
    address public deployManager;

    /// @inheritdoc IUtilityContract
    function initialize(bytes memory _initData) external virtual override returns (bool) {
        deployManager = abi.decode(_initData, (address));
        setDeployManager(deployManager);
        return true;
    }

    /// @notice Internal method to set the deploy manager address
    /// @dev Validates the deploy manager before setting
    /// @param _deployManager Address of the deploy manager to set
    function setDeployManager(address _deployManager) internal virtual {
        if (!validateDeployManager(_deployManager)) {
            revert FailedToDeployManager();
        }
        deployManager = _deployManager;
    }

    /// @notice Validates the deploy manager address
    /// @dev Checks that the address is not zero and supports the IDeployManager interface
    /// @param _deployManager Address to validate
    /// @return bool Indicates whether the deploy manager is valid
    function validateDeployManager(address _deployManager) internal view returns (bool) {
        if (_deployManager == address(0)) {
            revert DeployManagerCannotBeZero();
        }

        bytes4 interfaceId = type(IDeployManager).interfaceId;

        if (!IDeployManager(_deployManager).supportsInterface(interfaceId)) {
            revert NotDeployManager();
        }

        return true;
    }

    /// @inheritdoc IUtilityContract
    function getDeployManager() external view virtual override returns (address) {
        return deployManager;
    }

    /// @notice Checks interface support for the contract
    /// @dev Extends ERC165 support to include IUtilityContract interface
    /// @param interfaceId The interface identifier to check
    /// @return bool Whether the interface is supported
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }
}
