// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./IUtilityContract.sol";

contract InitializableStorage is IUtilityContract {

    uint256 public number;
    address public initializableStorage;
    bool private initialized;

    error AlreadyInitialized();

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function initialize(bytes memory _initData) external notInitialized returns(bool) {
        (uint256 _number, address _initializableStorage) = abi.decode(_initData, (uint256, address));

        number = _number;
        initializableStorage = _initializableStorage;

        initialized = true;
        return true;
    }

    function getInitData(uint256 _number, address _initializableStorage) public pure returns(bytes memory) {
        return abi.encode(_number, _initializableStorage);
    }    
}
