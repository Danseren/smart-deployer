# Vesting
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\Vesting\Vesting.sol)

**Inherits:**
[IVesting](/contracts\Vesting\IVesting.sol\interface.IVesting.md), [AbstractUtilityContract](/contracts\UtilityContract\AbstractUtilityContract.sol\abstract.AbstractUtilityContract.md), Ownable

Implements a token vesting mechanism with flexible scheduling

*Allows creating vesting schedules with cliff periods, custom durations, and claim restrictions*


## State Variables
### token
ERC20 token used for vesting


```solidity
IERC20 public token;
```


### allocatedTokens
Total number of tokens currently allocated in vesting schedules


```solidity
uint256 public allocatedTokens;
```


### vestings
Mapping of beneficiary addresses to their vesting schedules


```solidity
mapping(address => IVesting.VestingInfo) public vestings;
```


## Functions
### constructor

Use VestingLib for VestingInfo struct operations

Initializes the contract with deploy manager, token, and owner


```solidity
constructor() payable Ownable(msg.sender);
```

### claim

Allows beneficiary to claim vested tokens


```solidity
function claim() public;
```

### startVesting

Starts a new vesting schedule


```solidity
function startVesting(IVesting.VestingParams calldata params) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`IVesting.VestingParams`|Vesting parameters for the new schedule|


### withdrawUnallocated

Withdraws unallocated tokens


```solidity
function withdrawUnallocated(address _to) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address to receive unallocated tokens|


### initialize


```solidity
function initialize(bytes memory _initData) external override notInitialized returns (bool);
```

### vestedAmount

Calculates the total amount of tokens vested for a beneficiary


```solidity
function vestedAmount(address _claimer) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_claimer`|`address`|Address of the beneficiary|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total vested amount|


### claimableAmount

Calculates the amount of tokens currently claimable


```solidity
function claimableAmount(address _claimer) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_claimer`|`address`|Address of the beneficiary|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Claimable amount of tokens|


### getVestingInfo

Returns the vesting info for a beneficiary


```solidity
function getVestingInfo(address _claimer) public view returns (IVesting.VestingInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_claimer`|`address`|Address of the beneficiary|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IVesting.VestingInfo`|Vesting info for the beneficiary|


### getInitData

Generates initialization data for the contract


```solidity
function getInitData(address _deployManager, address _token, address _owner) external pure returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployManager`|`address`|Address of the deploy manager|
|`_token`|`address`|Address of the token contract|
|`_owner`|`address`|Address of the contract owner|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Encoded initialization data|


