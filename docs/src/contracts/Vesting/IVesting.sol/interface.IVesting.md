# IVesting
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\Vesting\IVesting.sol)

Defines the core functionality for a token vesting contract

*Provides structures and methods for creating and managing token vesting schedules*


## Functions
### claim

Allows beneficiary to claim vested tokens


```solidity
function claim() external;
```

### startVesting

Starts a new vesting schedule


```solidity
function startVesting(VestingParams calldata params) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`VestingParams`|Vesting parameters for the new schedule|


### vestedAmount

Calculates the total amount of tokens vested for a beneficiary


```solidity
function vestedAmount(address _claimer) external view returns (uint256);
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
function claimableAmount(address _claimer) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_claimer`|`address`|Address of the beneficiary|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Claimable amount of tokens|


### withdrawUnallocated

Withdraws unallocated tokens


```solidity
function withdrawUnallocated(address _to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address to receive unallocated tokens|


### getVestingInfo

Returns the vesting info for a beneficiary


```solidity
function getVestingInfo(address _claimer) external view returns (VestingInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_claimer`|`address`|Address of the beneficiary|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`VestingInfo`|Vesting info for the beneficiary|


### getInitData

Generates initialization data for the contract


```solidity
function getInitData(address _deployManager, address _token, address _owner) external view returns (bytes memory);
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


## Events
### VestingCreated
Event emitted when a new vesting schedule is created


```solidity
event VestingCreated(address indexed beneficiary, uint256 amount, uint256 creationTime);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`beneficiary`|`address`|Address of the token recipient|
|`amount`|`uint256`|Total amount of tokens to be vested|
|`creationTime`|`uint256`|Timestamp of vesting schedule creation|

### TokensWithdrawn
Event emitted when tokens are withdrawn


```solidity
event TokensWithdrawn(address indexed to, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address receiving the withdrawn tokens|
|`amount`|`uint256`|Amount of tokens withdrawn|

### Claim
Event emitted when tokens are claimed


```solidity
event Claim(address indexed beneficiary, uint256 amount, uint256 timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`beneficiary`|`address`|Address claiming the tokens|
|`amount`|`uint256`|Amount of tokens claimed|
|`timestamp`|`uint256`|Timestamp of the claim|

## Errors
### VestingNotFound
*Error thrown when attempting to interact with a non-existent vesting schedule*


```solidity
error VestingNotFound();
```

### ClaimNotAvailable
*Error thrown when trying to claim tokens before they are available*


```solidity
error ClaimNotAvailable(uint256 blockTimestamp, uint256 availableFrom);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`blockTimestamp`|`uint256`|Current block timestamp|
|`availableFrom`|`uint256`|Timestamp when tokens become available|

### NothingToClaim
*Error thrown when there are no tokens available to claim*


```solidity
error NothingToClaim();
```

### InfsufficientBalance
*Error thrown when attempting to claim more tokens than available*


```solidity
error InfsufficientBalance(uint256 availableBalance, uint256 totalAmount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`availableBalance`|`uint256`|Current available balance|
|`totalAmount`|`uint256`|Total amount requested|

### VestingAlreadyExist
*Error thrown when trying to create a vesting schedule that already exists*


```solidity
error VestingAlreadyExist();
```

### AmountCantBeZero
*Error thrown when attempting to create a vesting schedule with zero amount*


```solidity
error AmountCantBeZero();
```

### StartTimeShouldBeFuture
*Error thrown when vesting start time is not in the future*


```solidity
error StartTimeShouldBeFuture(uint256 startTime, uint256 blockTimestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`startTime`|`uint256`|Proposed start time|
|`blockTimestamp`|`uint256`|Current block timestamp|

### DurationCantBeZero
*Error thrown when vesting duration is zero*


```solidity
error DurationCantBeZero();
```

### CooldownCantBeLongerThanDuration
*Error thrown when claim cooldown is longer than vesting duration*


```solidity
error CooldownCantBeLongerThanDuration();
```

### InvalidBeneficiary
*Error thrown when beneficiary address is invalid*


```solidity
error InvalidBeneficiary();
```

### BelowMinimalClaimAmount
*Error thrown when claim amount is below the minimum claim amount*


```solidity
error BelowMinimalClaimAmount(uint256 minClaimAmount, uint256 lastClaimTime);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`minClaimAmount`|`uint256`|Minimum allowed claim amount|
|`lastClaimTime`|`uint256`|Timestamp of last claim|

### CooldownNotPassed
*Error thrown when claim cooldown period has not passed*


```solidity
error CooldownNotPassed(uint256 blockTimestamp, uint256 lastClaimTime);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`blockTimestamp`|`uint256`|Current block timestamp|
|`lastClaimTime`|`uint256`|Timestamp of last claim|

### NothingToWithdraw
*Error thrown when there are no tokens to withdraw*


```solidity
error NothingToWithdraw();
```

## Structs
### VestingInfo
Information about a beneficiary's vesting schedule


```solidity
struct VestingInfo {
    uint256 totalAmount;
    uint256 startTime;
    uint256 cliff;
    uint256 duration;
    uint256 claimed;
    uint256 lastClaimTime;
    uint256 claimCooldown;
    uint256 minClaimAmount;
    bool created;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`totalAmount`|`uint256`|Total number of tokens to be vested|
|`startTime`|`uint256`|Timestamp when vesting begins|
|`cliff`|`uint256`|Duration of the cliff period in seconds|
|`duration`|`uint256`|Total duration of the vesting period in seconds|
|`claimed`|`uint256`|Amount of tokens already claimed|
|`lastClaimTime`|`uint256`|Timestamp of the last claim|
|`claimCooldown`|`uint256`|Minimum time interval between claims in seconds|
|`minClaimAmount`|`uint256`|Minimum amount that can be claimed in a single transaction|
|`created`|`bool`|Indicates whether the vesting schedule has been created|

### VestingParams
Parameters for creating a new vesting schedule in startVesting function


```solidity
struct VestingParams {
    address beneficiary;
    uint256 totalAmount;
    uint256 startTime;
    uint256 cliff;
    uint256 duration;
    uint256 claimCooldown;
    uint256 minClaimAmount;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`beneficiary`|`address`|Address that will receive vested tokens|
|`totalAmount`|`uint256`|Total number of tokens to be vested|
|`startTime`|`uint256`|Timestamp when vesting begins|
|`cliff`|`uint256`|Duration of the cliff period in seconds|
|`duration`|`uint256`|Total duration of the vesting period in seconds|
|`claimCooldown`|`uint256`|Minimum time interval between claims in seconds|
|`minClaimAmount`|`uint256`|Minimum amount that can be claimed in a single transaction|

