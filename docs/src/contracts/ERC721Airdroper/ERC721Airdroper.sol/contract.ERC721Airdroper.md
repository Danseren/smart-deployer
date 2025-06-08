# ERC721Airdroper
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\ERC721Airdroper\ERC721Airdroper.sol)

**Inherits:**
[AbstractUtilityContract](/contracts\UtilityContract\AbstractUtilityContract.sol\abstract.AbstractUtilityContract.md), Ownable

Utility contract for batch airdropping ERC721 tokens

*Inherits from AbstractUtilityContract and Ownable for deployment and access control*


## State Variables
### MAX_AIRDROP_BATCH_SIZE
Maximum number of NFTs that can be airdropped in a single transaction


```solidity
uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;
```


### token
ERC721 token contract to be used for airdrops


```solidity
IERC721 public token;
```


### treasury
Treasury address holding the NFTs for airdrop


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

Performs batch airdrop of ERC721 tokens

*Transfers NFTs from treasury to specified receivers*


```solidity
function airdrop(address[] calldata receivers, uint256[] calldata tokenIds) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receivers`|`address[]`|Array of recipient addresses|
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
|`_token`|`address`|Address of the ERC721 token contract|
|`_treasury`|`address`|Address of the treasury holding NFTs|
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

### NeedToApproveTokens
*Error thrown when the treasury has not approved the contract to transfer tokens*


```solidity
error NeedToApproveTokens();
```

### BatchSizeExceeded
*Error thrown when attempting to airdrop more NFTs than the batch size limit*


```solidity
error BatchSizeExceeded();
```

