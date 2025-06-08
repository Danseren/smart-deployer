# AbstractUtilityContract
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\UtilityContract\AbstractUtilityContract.sol)

**Inherits:**
[IUtilityContract](/contracts\UtilityContract\IUtilityContract.sol\interface.IUtilityContract.md), ERC165

Base abstract contract for utility contracts managed by DeployManager

*Provides core implementation for utility contract initialization and deploy manager validation*


## State Variables
### initialized
Indicates whether the contract is initialized

*Used to prevent multiple initialization calls*


```solidity
bool public initialized;
```


### deployManager
Address of the deploy manager for this utility contract

*Stores the address of the contract responsible for deploying this utility contract*


```solidity
address public deployManager;
```


## Functions
### notInitialized

Modifier to prevent multiple initialization calls

*Checks if the contract is already initialized*


```solidity
modifier notInitialized();
```

### initialize

Initializes the utility contract with provided data

*This function should be called by the DeployManager after deploying the contract*


```solidity
function initialize(bytes memory _initData) external virtual override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_initData`|`bytes`|Encoded initialization parameters|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Success status of initialization|


### setDeployManager

Internal method to set the deploy manager address

*Validates the deploy manager before setting*


```solidity
function setDeployManager(address _deployManager) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployManager`|`address`|Address of the deploy manager to set|


### validateDeployManager

Validates the deploy manager address

*Checks that the address is not zero and supports the IDeployManager interface*


```solidity
function validateDeployManager(address _deployManager) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployManager`|`address`|Address to validate|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Indicates whether the deploy manager is valid|


### getDeployManager

Returns the address of the deploy manager

*Used to verify contract deployment origin*


```solidity
function getDeployManager() external view virtual override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address The address of the deploy manager|


### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool);
```

