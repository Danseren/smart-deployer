// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import {DeployManager} from "../../contracts/DeployManager/DeployManager.sol";
import {IDeployManager} from "../../contracts/DeployManager/IDeployManager.sol";
import {IUtilityContract} from "../../contracts/UtilityContract/IUtilityContract.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

// Mock utility contract that successfully initializes
contract MockUtility is IUtilityContract, ERC165 {
    bool public initialized;
    bytes public lastInitData;

    /// @notice Simulates successful contract initialization
    /// @param data Initialization data to be stored
    /// @return Always returns true to simulate successful initialization
    function initialize(bytes memory data) external override returns (bool) {
        lastInitData = data;
        initialized = true;
        return true;
    }

    /// @notice Checks interface support for IUtilityContract
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Returns a placeholder deploy manager address
    function getDeployManager() external pure override returns (address) {
        return address(0);
    }
}

// Mock utility contract that fails initialization
contract MockUtilityFailInit is IUtilityContract, ERC165 {
    /// @notice Simulates failed contract initialization
    /// @return Always returns false to simulate initialization failure
    function initialize(bytes memory) external pure override returns (bool) {
        return false;
    }

    /// @notice Checks interface support for IUtilityContract
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Returns a placeholder deploy manager address
    function getDeployManager() external pure override returns (address) {
        return address(0);
    }
}

/// @title DeployManagerTest
/// @notice Comprehensive test suite for DeployManager contract
contract DeployManagerTest is Test {
    DeployManager public manager;
    MockUtility public mockUtility;
    MockUtilityFailInit public badMockUtility;
    address public owner;
    address public user;

    /// @notice Allows contract to receive ether for testing payable functions
    receive() external payable {}

    /// @notice Sets up the testing environment before each test
    /// @dev Initializes contracts, owner, and user addresses
    function setUp() public {
        owner = address(1);
        user = address(2);
        manager = new DeployManager();
        mockUtility = new MockUtility();
        badMockUtility = new MockUtilityFailInit();
    }

    /// @notice Tests adding a new contract with valid parameters
    /// @dev Verifies contract registration, fee, and active status
    function testAddNewContract() public {
        manager.addNewContract(address(mockUtility), 1 ether, true);
        (uint256 fee, bool isActive, uint256 registeredAt) = manager.contractsData(address(mockUtility));
        assertEq(fee, 1 ether);
        assertTrue(isActive);
        assertGt(registeredAt, 0);
    }

    /// @notice Ensures non-utility contracts cannot be added
    /// @dev Expects revert when attempting to register an invalid contract
    function testAddNewContractRejectsNotUtility() public {
        vm.expectRevert();
        manager.addNewContract(address(0x1234), 1 ether, true);
    }

    /// @notice Tests successful contract deployment
    /// @dev Verifies deployment process, initialization, and tracking
    function testDeploy() public {
        // Prepare contract for deployment
        manager.addNewContract(address(mockUtility), 0.1 ether, true);

        // Prepare deployment data and funds
        bytes memory initData = encodeInitData(user, 42);
        vm.deal(user, 1 ether);

        // Simulate user deployment
        vm.prank(user);
        address deployed = manager.deploy{value: 0.1 ether}(address(mockUtility), initData);

        // Validate deployment
        assertTrue(deployed != address(0));
        assertEq(MockUtility(deployed).initialized(), true);
        assertEq(MockUtility(deployed).lastInitData(), initData);
        assertEq(manager.deployedContracts(user, 0), deployed);
    }

    /// @notice Checks deployment fails for inactive contracts
    /// @dev Expects revert when attempting to deploy an inactive contract
    function testDeployFailsInactive() public {
        manager.addNewContract(address(mockUtility), 0.1 ether, false);
        bytes memory initData = encodeInitData(user, 42);
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert();
        manager.deploy{value: 0.1 ether}(address(mockUtility), initData);
    }

    /// @notice Ensures deployment fails with insufficient funds
    /// @dev Expects revert when deployment fee is not fully covered
    function testDeployFailsNotEnoughFunds() public {
        manager.addNewContract(address(mockUtility), 1 ether, true);
        bytes memory initData = encodeInitData(user, 42);
        vm.deal(user, 0.5 ether);
        vm.prank(user);
        vm.expectRevert();
        manager.deploy{value: 0.5 ether}(address(mockUtility), initData);
    }

    /// @notice Checks deployment fails for unregistered contracts
    /// @dev Expects revert when attempting to deploy an unregistered contract
    function testDeployFailsNotRegistered() public {
        bytes memory initData = encodeInitData(user, 42);
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert();
        manager.deploy{value: 0.1 ether}(address(mockUtility), initData);
    }

    /// @notice Tests updating contract deployment fee
    /// @dev Verifies fee can be modified by owner
    function testUpdateFee() public {
        manager.addNewContract(address(mockUtility), 1 ether, true);
        manager.updateFee(address(mockUtility), 2 ether);
        (uint256 fee,,) = manager.contractsData(address(mockUtility));
        assertEq(fee, 2 ether);
    }

    /// @notice Tests contract activation and deactivation
    /// @dev Verifies contract status can be toggled
    function testDeactivateAndActivateContract() public {
        manager.addNewContract(address(mockUtility), 1 ether, true);
        manager.deactivateContract(address(mockUtility));
        (, bool isActive,) = manager.contractsData(address(mockUtility));
        assertFalse(isActive);
        manager.activateContract(address(mockUtility));
        (, isActive,) = manager.contractsData(address(mockUtility));
        assertTrue(isActive);
    }

    /// @notice Checks ERC165 interface support
    /// @dev Verifies correct interface detection
    function testSupportsInterface() public view {
        assertTrue(manager.supportsInterface(type(IDeployManager).interfaceId));
        assertFalse(manager.supportsInterface(0x12345678));
    }

    /// @notice Ensures deployment fails if contract initialization fails
    /// @dev Expects revert when utility contract initialization returns false
    function testDeployFailsIfInitializationFails() public {
        manager.addNewContract(address(badMockUtility), 0.1 ether, true);
        bytes memory initData = encodeInitData(user, 42);
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert();
        manager.deploy{value: 0.1 ether}(address(badMockUtility), initData);
    }

    /// @notice Checks fee update fails for unregistered contracts
    /// @dev Expects revert when trying to update fee for non-existing contract
    function testUpdateFeeFailsIfNotRegistered() public {
        vm.expectRevert();
        manager.updateFee(address(0x1234), 1 ether);
    }

    /// @notice Ensures contract deactivation fails for unregistered contracts
    /// @dev Expects revert when trying to deactivate non-existing contract
    function testDeactivateContractFailsIfNotRegistered() public {
        vm.expectRevert();
        manager.deactivateContract(address(0x1234));
    }

    /// @notice Checks contract activation fails for unregistered contracts
    /// @dev Expects revert when trying to activate non-existing contract
    function testActivateContractFailsIfNotRegistered() public {
        vm.expectRevert();
        manager.activateContract(address(0x1234));
    }

    /// @notice Helper function to encode initialization data
    /// @param user_ User address to include in initialization
    /// @param value_ Arbitrary value to include in initialization
    /// @return Encoded initialization data
    function encodeInitData(address user_, uint256 value_) public pure returns (bytes memory) {
        return abi.encode(user_, value_);
    }
}
