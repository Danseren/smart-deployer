# IDeployManager
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\DeployManager\IDeployManager.sol)

**Inherits:**
IERC165

Interface for managing contract deployments

*Implements IERC165 for ERC165 standard support*


## Functions
### deploy

Deploys a new contract

*Emits NewDeployment event*


```solidity
function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_utilityContract`|`address`|Address of the registered utility contract|
|`_initData`|`bytes`|Initialization data for the contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Address of the deployed contract|


### addNewContract

Adds a new contract to the system

*Emits NewContractAdded event*


```solidity
function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the registered utility contract|
|`_fee`|`uint256`|Deployment fee|
|`_isActive`|`bool`|Initial active status|


### updateFee

Updates the fee for an existing contract

*Emits ContractFeeUpdated event*


```solidity
function updateFee(address _contractAddress, uint256 _newFee) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the contract|
|`_newFee`|`uint256`|New fee (in wei) required for the deployment|


### deactivateContract

Deactivates an existing contract

*Emits ContractStatusUpdated event*


```solidity
function deactivateContract(address _contractAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the contract to deactivate|


### activateContract

Activates an existing contract

*Emits ContractStatusUpdated event*


```solidity
function activateContract(address _contractAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the contract to activate|


## Events
### NewContractAdded
Event emitted when a new utility contract template is registered


```solidity
event NewContractAdded(address indexed _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the registered utility contract template|
|`_fee`|`uint256`|Fee (in wei) required to deploy a clone of this contract|
|`_isActive`|`bool`|Contract active status, indicating whether the contract is active and ready to be deployed|
|`_timestamp`|`uint256`|Timestamp indicating when the contract was added|

### ContractFeeUpdated
Event emitted when a contract's fee is updated


```solidity
event ContractFeeUpdated(address indexed _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the registered contract|
|`_oldFee`|`uint256`|Fee (in wei) required to deploy contract before update|
|`_newFee`|`uint256`|Fee (in wei) required to deploy contract after update|
|`_timestamp`|`uint256`|Timestamp indicating when the fee was updated|

### ContractStatusUpdated
Event emitted when a contract's status is updated


```solidity
event ContractStatusUpdated(address indexed _contractAddress, bool _isActive, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the registered contract|
|`_isActive`|`bool`|New active status|
|`_timestamp`|`uint256`|Timestamp indicating when the status was updated|

### NewDeployment
Event emitted on new deployment


```solidity
event NewDeployment(address indexed _deployer, address indexed _contractAddress, uint256 _fee, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployer`|`address`|Address of the deployer|
|`_contractAddress`|`address`|Address of the deployed contract|
|`_fee`|`uint256`|Fee (in wei) paid for deployment|
|`_timestamp`|`uint256`|Timestamp indicating when the deployment occurred|

## Errors
### ContractNotActive
*Error thrown when attempting to use an inactive contract*


```solidity
error ContractNotActive();
```

### NotEnoghtFunds
*Error thrown when there are insufficient funds*


```solidity
error NotEnoghtFunds();
```

### ContractDoesNotRegistered
*Error thrown when attempting to use an unregistered contract*


```solidity
error ContractDoesNotRegistered();
```

### InitializationFailed
*Error thrown when contract initialization fails*


```solidity
error InitializationFailed();
```

### ContractIsNotUtilityContract
*Error thrown when attempting to use a non-utility contract*


```solidity
error ContractIsNotUtilityContract();
```

### AlreadyRegistered
*Error thrown when contracts already registered*


```solidity
error AlreadyRegistered();
```

