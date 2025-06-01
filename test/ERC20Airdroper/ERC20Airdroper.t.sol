// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import {ERC20Airdroper} from "../../contracts/ERC20Airdroper/ERC20Airdroper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DeployManager} from "../../contracts/DeployManager/DeployManager.sol";
import {IDeployManager} from "../../contracts/DeployManager/IDeployManager.sol";
import {MockERC20} from "./MockERC20.sol";
import {MockDeployManager} from "../DeployManager/MockDeployManager.sol";

contract ERC20AirdroperTest is Test {
    ERC20Airdroper public airdroper;
    MockERC20 public token;
    address public airdropOwner;
    address public treasury;
    address public managerOwner;
    address[] public receivers;
    uint256[] public amounts;
    MockDeployManager mockDeployManager;

    receive() external payable {}

    /// @notice Prepare test environment with predefined token and contract states
    function setUp() public {
        // Initialize test addresses and mock contracts
        airdropOwner = vm.addr(1);
        treasury = vm.addr(2);
        managerOwner = vm.addr(42);

        // Prepare test receivers with incremental token amounts
        receivers = new address[](3);
        amounts = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            receivers[i] = vm.addr(3 + i);
            amounts[i] = 100 * (i + 1);
        }

        // Setup mock token, airdroper, and deploy manager
        token = new MockERC20();
        airdroper = new ERC20Airdroper();
        mockDeployManager = new MockDeployManager();
        mockDeployManager.setSupports(true);

        // Prepare token for airdrop testing
        token.mint(treasury, 1000);
        vm.prank(treasury);
        token.approve(address(airdroper), 1000);

        // Initialize airdroper with mock deploy manager
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), 1000, treasury, airdropOwner);
        airdroper.initialize(initData);
        vm.deal(managerOwner, 0);
    }

    /// @notice Verify deploy manager interface support during initialization
    function testDeployManagerSupportInterface() public {
        mockDeployManager.setSupports(true);
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), 1000, treasury, airdropOwner);
        ERC20Airdroper newAirdroper = new ERC20Airdroper();
        newAirdroper.initialize(initData);
    }

    /// @notice Ensure initialization fails when deploy manager does not support interface
    function testDeployManagerDoesNotSupportInterface() public {
        mockDeployManager.setSupports(false);
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), 1000, treasury, airdropOwner);
        ERC20Airdroper newAirdroper = new ERC20Airdroper();
        vm.expectRevert();
        newAirdroper.initialize(initData);
    }

    /// @notice Prevent multiple initializations of the same contract
    function testReconnectDeployManager() public {
        mockDeployManager.setSupports(true);
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), 1000, treasury, airdropOwner);
        ERC20Airdroper newAirdroper = new ERC20Airdroper();
        newAirdroper.initialize(initData);

        // Attempt to re-initialize (should revert)
        vm.expectRevert();
        newAirdroper.initialize(initData);
    }

    /// @notice Validate successful token distribution across multiple receivers
    function testAirdropSuccess() public {
        // Approve tokens for airdrop
        vm.prank(airdropOwner);
        token.approve(address(airdroper), 600);

        // Perform airdrop
        vm.prank(airdropOwner);
        airdroper.airdrop(receivers, amounts);

        // Verify token distribution
        assertEq(token.balanceOf(receivers[0]), 100, "Receiver 0 should get 100");
        assertEq(token.balanceOf(receivers[1]), 200, "Receiver 1 should get 200");
        assertEq(token.balanceOf(receivers[2]), 300, "Receiver 2 should get 300");
    }

    /// @notice Check airdrop fails when exceeding maximum batch size
    function testAirdropBatchSizeExceeded() public {
        // Create oversized arrays to trigger batch size limit
        address[] memory bigReceivers = new address[](301);
        uint256[] memory bigAmounts = new uint256[](301);
        for (uint256 i = 0; i < 301; i++) {
            bigReceivers[i] = address(uint160(i + 10));
            bigAmounts[i] = 1;
        }

        // Attempt airdrop with too many recipients
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(bigReceivers, bigAmounts);
    }

    /// @notice Ensure airdrop fails with mismatched receiver and amount arrays
    function testAirdropArraysLengthMismatch() public {
        // Prepare arrays with different lengths
        address[] memory badReceivers = new address[](2);
        uint256[] memory badAmounts = new uint256[](3);
        badReceivers[0] = address(0x1);
        badReceivers[1] = address(0x2);
        badAmounts[0] = 1;
        badAmounts[1] = 2;
        badAmounts[2] = 3;

        // Attempt airdrop with mismatched array lengths
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(badReceivers, badAmounts);
    }

    /// @notice Verify airdrop fails with insufficient token approvals
    function testAirdropNotEnoghAppvedTokens() public {
        // Approve insufficient tokens
        vm.prank(treasury);
        token.approve(address(airdroper), 10);

        // Attempt airdrop with insufficient approved tokens
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(receivers, amounts);
    }

    /// @notice Validate correct encoding of initialization parameters
    function testGetInitData() public view {
        bytes memory data = airdroper.getInitData(address(0xDEAD), address(token), 1000, treasury, airdropOwner);
        (address deployManager, address _token, uint256 amount, address _treasury, address owner) =
            abi.decode(data, (address, address, uint256, address, address));

        // Validate encoded parameters
        assertEq(deployManager, address(0xDEAD));
        assertEq(_token, address(token));
        assertEq(amount, 1000);
        assertEq(_treasury, treasury);
        assertEq(owner, airdropOwner);
    }

    /// @notice Test contract deployment through DeployManager
    function testDeployViaDeployManager() public {
        // Create and configure deploy manager
        vm.prank(managerOwner);
        DeployManager deployManager = new DeployManager();
        ERC20Airdroper template = new ERC20Airdroper();

        // Register contract template
        vm.prank(managerOwner);
        deployManager.addNewContract(address(template), 0.5 ether, true);

        // Prepare initialization data
        bytes memory initData = encodeInitData(address(deployManager), address(token), 1000, treasury, airdropOwner);

        // Fund deployment and track owner balance
        vm.deal(address(this), 1 ether);
        uint256 ownerBalanceBefore = managerOwner.balance;

        // Deploy via manager
        address deployed = deployManager.deploy{value: 0.5 ether}(address(template), initData);
        uint256 ownerBalanceAfter = managerOwner.balance;

        // Verify deployment and fee transfer
        assertEq(ownerBalanceAfter - ownerBalanceBefore, 0.5 ether, "Owner should receive the fee");

        // Validate deployed contract parameters
        ERC20Airdroper deployedAirdroper = ERC20Airdroper(deployed);
        assertEq(address(deployedAirdroper.token()), address(token));
        assertEq(deployedAirdroper.amount(), 1000);
        assertEq(deployedAirdroper.treasury(), treasury);
        assertEq(deployedAirdroper.owner(), airdropOwner);
    }

    /// @notice Verify contract template is not pre-initialized
    function testTemplateIsNotInitialized() public {
        ERC20Airdroper template = new ERC20Airdroper();
        assertFalse(template.initialized(), "Template should not be initialized");
    }

    /// @notice Verify DeployManager interface support
    function testDeployManagerSupportsInterfaceDirect() public {
        DeployManager deployManager = new DeployManager();
        bytes4 iface = type(IDeployManager).interfaceId;
        bool result = deployManager.supportsInterface(iface);
        assertTrue(result, "DeployManager should support IDeployManager interface");
    }

    /// @notice Log interface ID for debugging
    function testLogInterfaceId() public {
        bytes4 iface = type(IDeployManager).interfaceId;
        emit log_bytes32(bytes32(iface));
        DeployManager deployManager = new DeployManager();
        bool result = deployManager.supportsInterface(iface);
        emit log_named_uint("supportsInterface result", result ? 1 : 0);
    }

    /// @notice Additional verification of DeployManager interface support
    function testSupportsInterfaceOnDeployManager() public {
        DeployManager deployManager = new DeployManager();
        bytes4 iface = type(IDeployManager).interfaceId;
        assertTrue(deployManager.supportsInterface(iface), "Should support IDeployManager");
    }

    /// @notice Helper function to encode initialization data
    function encodeInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
        public
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _amount, _treasury, _owner);
    }
}
