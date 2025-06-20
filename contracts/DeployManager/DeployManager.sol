// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../UtilityContract/IUtilityContract.sol";
import "./IDeployManager.sol";

/// @title DeployManager - Factory for utility contracts
/// @notice Manages the deployment of utility contracts using minimal proxy pattern
/// @dev Implements IDeployManager interface and inherits from OpenZeppelin's Ownable and ERC165
contract DeployManager is IDeployManager, Ownable, ERC165 {
    /// @notice Initializes the contract and sets the owner
    /// @dev Calls Ownable constructor with msg.sender
    constructor() payable Ownable(msg.sender) {}

    /// @notice Structure to store information about registered utility contracts
    /// @dev Used in contractsData mapping
    struct ContractInfo {
        uint256 fee;
        /// @notice Deployment fee (in wei)
        bool isDeployable;
        /// @notice Shows deployable status
        uint256 registeredAt;
    }
    /// @notice Registration timestamp

    /// @notice Mapping of user addresses to their deployed contracts
    mapping(address => address[]) public deployedContracts;

    /// @notice Mapping of utility contract addresses to their configuration
    mapping(address => ContractInfo) public contractsData;

    /// @inheritdoc IDeployManager
    function deploy(address _utilityContract, bytes calldata _initData) external payable override returns (address) {
        ContractInfo memory info = contractsData[_utilityContract];

        require(info.isDeployable, ContractNotActive());
        require(msg.value >= info.fee, NotEnoghtFunds());
        require(info.registeredAt > 0, ContractDoesNotRegistered());

        address clone = Clones.clone(_utilityContract);

        require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

        payable(owner()).transfer(msg.value);

        deployedContracts[msg.sender].push(clone);

        emit NewDeployment(msg.sender, clone, msg.value, block.timestamp);

        return clone;
    }

    /// @inheritdoc IDeployManager
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner {
        require(
            IUtilityContract(_contractAddress).supportsInterface(type(IUtilityContract).interfaceId),
            ContractIsNotUtilityContract()
        );
        require(contractsData[_contractAddress].registeredAt == 0, AlreadyRegistered());

        contractsData[_contractAddress] =
            ContractInfo({fee: _fee, isDeployable: _isActive, registeredAt: block.timestamp});

        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractDoesNotRegistered());

        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, _oldFee, _newFee, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function deactivateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registeredAt > 0, ContractDoesNotRegistered());

        contractsData[_address].isDeployable = false;

        emit ContractStatusUpdated(_address, false, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function activateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registeredAt > 0, ContractDoesNotRegistered());

        contractsData[_address].isDeployable = true;

        emit ContractStatusUpdated(_address, true, block.timestamp);
    }

    /// @notice Checks if contract supports specific interface
    /// @dev Implementation of IERC165 interface detection
    /// @param interfaceId The interface identifier to check
    /// @return bool True if interface is supported
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IDeployManager).interfaceId || super.supportsInterface(interfaceId);
    }
}
