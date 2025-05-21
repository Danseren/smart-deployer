// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

/// @title IDeployManager - Factory for utility contracts
/// @notice Interface for managing contract deployments
/// @dev Implements IERC165 for ERC165 standard support
interface IDeployManager is IERC165 {
    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Error thrown when attempting to use an inactive contract
    error ContractNotActive();

    /// @dev Error thrown when there are insufficient funds
    error NotEnoghtFunds();

    /// @dev Error thrown when attempting to use an unregistered contract
    error ContractDoesNotRegistered();

    /// @dev Error thrown when contract initialization fails
    error InitializationFailed();

    /// @dev Error thrown when attempting to use a non-utility contract
    error ContractIsNotUtilityContract();

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Event emitted when a new utility contract template is registered
    /// @param _contractAddress Address of the registered utility contract template
    /// @param _fee Fee (in wei) required to deploy a clone of this contract
    /// @param _isActive Contract active status, indicating whether the contract is active and ready to be deployed
    /// @param _timestamp Timestamp indicating when the contract was added
    event NewContractAdded(address indexed _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);

    /// @notice Event emitted when a contract's fee is updated
    /// @param _contractAddress Address of the contract
    /// @param _oldFee Previous fee
    /// @param _newFee New fee
    /// @param _timestamp Timestamp indicating when the fee was updated
    event ContractFeeUpdated(address indexed _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);

    /// @notice Event emitted when a contract's status is updated
    /// @param _contractAddress Address of the contract
    /// @param _isActive New active status
    /// @param _timestamp Timestamp indicating when the status was updated
    event ContractStatusUpdated(address indexed _contractAddress, bool _isActive, uint256 _timestamp);

    /// @notice Event emitted on new deployment
    /// @param _deployer Address of the deployer
    /// @param _contractAddress Address of the deployed contract
    /// @param _fee Paid fee
    /// @param _timestamp Timestamp indicating when the deployment occurred
    event NewDeployment(address indexed _deployer, address indexed _contractAddress, uint256 _fee, uint256 _timestamp);

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Deploys a new contract
    /// @param _utilityContract Address of the utility contract to deploy
    /// @param _initData Initialization data for the contract
    /// @return Address of the deployed contract
    /// @dev Emits NewDeployment event
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    /// @notice Adds a new contract to the system
    /// @param _contractAddress Address of the contract to add
    /// @param _fee Deployment fee
    /// @param _isActive Initial active status
    /// @dev Emits NewContractAdded event
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    /// @notice Updates the fee for an existing contract
    /// @param _contractAddress Address of the contract
    /// @param _newFee New fee
    /// @dev Emits ContractFeeUpdated event
    function updateFee(address _contractAddress, uint256 _newFee) external;

    /// @notice Deactivates an existing contract
    /// @param _contractAddress Address of the contract to deactivate
    /// @dev Emits ContractStatusUpdated event
    function deactivateContract(address _contractAddress) external;

    /// @notice Activates an existing contract
    /// @param _contractAddress Address of the contract to activate
    /// @dev Emits ContractStatusUpdated event
    function activateContract(address _contractAddress) external;
}
