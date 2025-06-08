# VestingLib
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\Vesting\VestingLib.sol)

Library for calculating vested and claimable token amounts

*Provides utility functions for vesting schedule calculations*


## Functions
### vestedAmount

Calculates the total amount of tokens vested at the current time

*Computes vested tokens based on the vesting schedule, considering cliff period*


```solidity
function vestedAmount(IVesting.VestingInfo storage v) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`v`|`IVesting.VestingInfo`|Storage reference to the VestingInfo struct|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of tokens vested|


### claimableAmount

Calculates the amount of tokens currently available to claim

*Computes claimable tokens by subtracting already claimed tokens from vested amount*


```solidity
function claimableAmount(IVesting.VestingInfo storage v) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`v`|`IVesting.VestingInfo`|Storage reference to the VestingInfo struct|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of tokens that can be claimed|


