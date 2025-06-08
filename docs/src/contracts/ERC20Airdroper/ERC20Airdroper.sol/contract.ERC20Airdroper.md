# ERC20Airdroper
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\ERC20Airdroper\ERC20Airdroper.sol)

**Inherits:**
[AbstractUtilityContract](/contracts\UtilityContract\AbstractUtilityContract.sol\abstract.AbstractUtilityContract.md), Ownable

Utility contract for batch airdropping ERC20 tokens

*Inherits from AbstractUtilityContract and Ownable for deployment and access control*


## State Variables
### MAX_AIRDROP_BATCH_SIZE
Maximum number of recipients that can be airdropped to in a single transaction


```solidity
uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;
```


### token
ERC20 token contract to be used for airdrops


```solidity
IERC20 public token;
```


### amount
Amount of tokens to be distributed to each recipient


```solidity
uint256 public amount;
```


### treasury
Treasury address holding the tokens for airdrop


```solidity
address public treasury;
```


## Functions
### constructor

Constructor initializes the contract with the sender as the initial owner


```solidity
constructor() payable Ownable(msg.sender);
```

### airdrop

Performs batch airdrop of ERC20 tokens

*Transfers tokens from treasury to specified receivers*


```solidity
function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receivers`|`address[]`|Array of recipient addresses|
|`amounts`|`uint256[]`|Array of token amounts to transfer to each recipient|


### initialize

Initializes the utility contract with provided data

*Initializes the contract with deploy manager, token, amount, treasury, and owner*


```solidity
function initialize(bytes memory _initData) external override notInitialized returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_initData`|`bytes`|Encoded initialization parameters|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Success status of initialization|


### getInitData

Generates initialization data for the contract

*Encodes initialization parameters for use with deploy manager*


```solidity
function getInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
    external
    pure
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployManager`|`address`|Address of the deploy manager|
|`_token`|`address`|Address of the ERC20 token contract|
|`_amount`|`uint256`|Amount of tokens to be distributed to each recipient|
|`_treasury`|`address`|Address of the treasury holding tokens|
|`_owner`|`address`|Address of the contract owner|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|bytes Encoded initialization data|


## Errors
### ArraysLengthMismatch
*Error thrown when input arrays have mismatched lengths*


```solidity
error ArraysLengthMismatch();
```

### NotEnoughApprovedTokens
*Error thrown when the treasury has not approved enough tokens*


```solidity
error NotEnoughApprovedTokens();
```

### TransferFailed
*Error thrown when token transfer fails*


```solidity
error TransferFailed();
```

### BatchSizeExceeded
*Error thrown when attempting to airdrop to more recipients than the batch size limit*


```solidity
error BatchSizeExceeded();
```

