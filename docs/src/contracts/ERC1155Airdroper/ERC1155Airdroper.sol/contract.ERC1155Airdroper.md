# ERC1155Airdroper
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\ERC1155Airdroper\ERC1155Airdroper.sol)

**Inherits:**
[AbstractUtilityContract](/contracts\UtilityContract\AbstractUtilityContract.sol\abstract.AbstractUtilityContract.md), Ownable

Utility contract for batch airdropping ERC1155 tokens

*Inherits from AbstractUtilityContract and Ownable for deployment and access control*


## State Variables
### MAX_AIRDROP_BATCH_SIZE
Maximum number of tokens that can be airdropped in a single transaction


```solidity
uint256 public constant MAX_AIRDROP_BATCH_SIZE = 10;
```


### token
ERC1155 token contract to be used for airdrops


```solidity
IERC1155 public token;
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

Performs batch airdrop of ERC1155 tokens

*Transfers tokens from treasury to specified receivers*


```solidity
function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receivers`|`address[]`|Array of recipient addresses|
|`amounts`|`uint256[]`|Array of token amounts to transfer|
|`tokenIds`|`uint256[]`|Array of token IDs to transfer|


### initialize

Initializes the utility contract with provided data

*Initializes the contract with deploy manager, token, treasury, and owner*


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
function getInitData(address _deployManager, address _token, address _treasury, address _owner)
    external
    pure
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployManager`|`address`|Address of the deploy manager|
|`_token`|`address`|Address of the ERC1155 token contract|
|`_treasury`|`address`|Address of the treasury holding tokens|
|`_owner`|`address`|Address of the contract owner|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|bytes Encoded initialization data|


## Errors
### RecieversLengthMismatch
*Error thrown when the number of receivers does not match other input arrays*


```solidity
error RecieversLengthMismatch();
```

### AmountsLengthMismatch
*Error thrown when the number of amounts does not match other input arrays*


```solidity
error AmountsLengthMismatch();
```

### BatchSizeExceeded
*Error thrown when attempting to airdrop more tokens than the batch size limit*


```solidity
error BatchSizeExceeded();
```

### NeedToApproveTokens
*Error thrown when the treasury has not approved the contract to transfer tokens*


```solidity
error NeedToApproveTokens();
```

