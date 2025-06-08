# DeployManager
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\DeployManager\DeployManager.sol)

**Inherits:**
[IDeployManager](/contracts\DeployManager\IDeployManager.sol\interface.IDeployManager.md), Ownable, ERC165

Manages the deployment of utility contracts using minimal proxy pattern

*Implements IDeployManager interface and inherits from OpenZeppelin's Ownable and ERC165*


## State Variables
### deployedContracts
Registration timestamp

Mapping of user addresses to their deployed contracts


```solidity
mapping(address => address[]) public deployedContracts;
```


### contractsData
Mapping of utility contract addresses to their configuration


```solidity
mapping(address => ContractInfo) public contractsData;
```


## Functions
### constructor

Initializes the contract and sets the owner

*Calls Ownable constructor with msg.sender*


```solidity
constructor() payable Ownable(msg.sender);
```

### deploy

Deploys a new contract

*Emits NewDeployment event*


```solidity
function deploy(address _utilityContract, bytes calldata _initData) external payable override returns (address);
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
function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner;
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
function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner;
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
function deactivateContract(address _address) external override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`||


### activateContract

Activates an existing contract

*Emits ContractStatusUpdated event*


```solidity
function activateContract(address _address) external override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`||


### supportsInterface

Checks if contract supports specific interface

*Implementation of IERC165 interface detection*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if interface is supported|


## Structs
### ContractInfo
Structure to store information about registered utility contracts

*Used in contractsData mapping*


```solidity
struct ContractInfo {
    uint256 fee;
    bool isDeployable;
    uint256 registeredAt;
}
```

