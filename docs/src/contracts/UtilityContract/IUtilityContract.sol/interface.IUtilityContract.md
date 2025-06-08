# IUtilityContract
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\UtilityContract\IUtilityContract.sol)

**Inherits:**
IERC165

Defines the base interface that all utility contracts must implement

*Utility contracts should implement this interface to be compatible with the DeployManager.*


## Functions
### initialize

Initializes the utility contract with provided data

*This function should be called by the DeployManager after deploying the contract*


```solidity
function initialize(bytes memory _initData) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_initData`|`bytes`|Encoded initialization parameters|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Success status of initialization|


### getDeployManager

Returns the address of the deploy manager

*Used to verify contract deployment origin*


```solidity
function getDeployManager() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address The address of the deploy manager|


## Errors
### DeployManagerCannotBeZero
*Error thrown when deploy manager address is zero*


```solidity
error DeployManagerCannotBeZero();
```

### NotDeployManager
*Error thrown when caller is not the deploy manager*


```solidity
error NotDeployManager();
```

### FailedToValidateDeployManager
*Error thrown when deploy manager validation failed throw validateDeployManager()*


```solidity
error FailedToValidateDeployManager();
```

### AlreadyInitialized
*Error thrown when contract is already initialized*


```solidity
error AlreadyInitialized();
```

