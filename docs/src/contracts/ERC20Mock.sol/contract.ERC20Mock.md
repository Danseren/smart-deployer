# ERC20Mock
[Git Source](https://github.com-personal/danseren/smart-deployer/blob/5e1d785c7889313bede419942a1bc275bae6bb22/contracts\ERC20Mock.sol)

**Inherits:**
ERC20

A simple mock ERC20 token for testing and development purposes

*Mints a fixed amount of tokens to a specified recipient during deployment*


## Functions
### constructor

Initializes the mock token with a fixed supply

*Mints 10,000 tokens multiplied by the token's decimal precision*


```solidity
constructor(address recipient) payable ERC20("MyToken", "MTK");
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|Address that will receive the initial token supply|


