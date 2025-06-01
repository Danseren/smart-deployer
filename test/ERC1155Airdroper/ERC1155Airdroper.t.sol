// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import {ERC1155Airdroper} from "../../contracts/ERC1155Airdroper/ERC1155Airdroper.sol";
import {MockERC1155} from "./MockERC1155.sol";
import {MockDeployManager} from "../DeployManager/MockDeployManager.sol";
import {DeployManager} from "../../contracts/DeployManager/DeployManager.sol";
import {IDeployManager} from "../../contracts/DeployManager/IDeployManager.sol";

/// @title ERC1155 Airdroper Test Suite
/// @notice Comprehensive test coverage for ERC1155 token airdrop functionality
contract ERC1155AirdroperTest is Test {
    ERC1155Airdroper public airdroper;
    MockERC1155 public token;
    MockDeployManager public mockDeployManager;
    address public airdropOwner;
    address public treasury;
    address public managerOwner;
    address[] public recievers;
    uint256[] public tokenIds;
    uint256[] public amounts;

    /// @notice Allows contract to receive ether for testing payable functions
    receive() external payable {}

    /// @notice Prepare test environment with predefined token and contract states
    /// @dev Sets up test addresses, mints tokens, and initializes contracts
    function setUp() public {
        // Initialize test addresses with unique identifiers
        airdropOwner = vm.addr(1);
        treasury = vm.addr(2);
        managerOwner = vm.addr(42);

        // Prepare test receivers, token IDs, and amounts
        recievers = new address[](3);
        tokenIds = new uint256[](3);
        amounts = new uint256[](3);

        // Populate test data with predictable values
        for (uint256 i = 0; i < 3; i++) {
            recievers[i] = vm.addr(3 + i);
            tokenIds[i] = 100 + i;
            amounts[i] = 10 * (i + 1);
        }

        // Deploy mock contracts for testing
        token = new MockERC1155();
        airdroper = new ERC1155Airdroper();
        mockDeployManager = new MockDeployManager();

        // Mint tokens to treasury for airdrop testing
        for (uint256 i = 0; i < 3; i++) {
            token.mint(treasury, tokenIds[i], amounts[i]);
        }

        // Approve airdroper to manage tokens
        vm.prank(treasury);
        token.setApprovalForAll(address(airdroper), true);

        // Initialize airdroper with mock deploy manager
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), treasury, airdropOwner);
        airdroper.initialize(initData);
    }

    /// @notice Verify successful token airdrop to multiple receivers
    /// @dev Checks that tokens are correctly transferred to specified addresses
    function testAirdropSuccess() public {
        vm.prank(airdropOwner);
        airdroper.airdrop(recievers, amounts, tokenIds);

        // Validate token balances for each receiver
        for (uint256 i = 0; i < 3; i++) {
            assertEq(token.balanceOf(recievers[i], tokenIds[i]), amounts[i], "Receiver should get correct amount");
        }
    }

    /// @notice Ensure airdrop fails when exceeding maximum batch size
    /// @dev Attempts to airdrop more tokens than the contract's batch limit
    function testAirdropBatchSizeExceeded() public {
        // Prepare oversized arrays to trigger batch size limit
        address[] memory bigRecievers = new address[](11);
        uint256[] memory bigTokensIds = new uint256[](11);
        uint256[] memory bigAmounts = new uint256[](11);

        // Populate arrays beyond batch size limit
        for (uint256 i = 0; i < 11; i++) {
            bigRecievers[i] = vm.addr(1000 + i);
            bigTokensIds[i] = 10_000 + i;
            bigAmounts[i] = 1;
        }

        // Expect revert due to batch size exceeded
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(bigRecievers, bigAmounts, bigTokensIds);
    }

    /// @notice Check airdrop fails with mismatched receiver array length
    /// @dev Verifies input validation for receiver array
    function testAirdropReceivrsLengthMismatch() public {
        // Prepare arrays with different lengths to trigger validation
        address[] memory badRecievers = new address[](2);
        uint256[] memory badTokenIds = new uint256[](3);
        uint256[] memory badAmounts = new uint256[](3);

        // Populate arrays with mismatched lengths
        badRecievers[0] = vm.addr(10);
        badRecievers[1] = vm.addr(11);
        badTokenIds[0] = 1;
        badTokenIds[1] = 2;
        badTokenIds[2] = 3;
        badAmounts[0] = 1;
        badAmounts[1] = 2;
        badAmounts[2] = 3;

        // Expect revert due to length mismatch
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(badRecievers, badAmounts, badTokenIds);
    }

    /// @notice Verify airdrop fails with mismatched amounts array length
    /// @dev Checks input validation for amounts array
    function testAirdropAmountsLengthMismatch() public {
        // Prepare arrays with different lengths
        address[] memory badRecievers = new address[](3);
        uint256[] memory badTokenIds = new uint256[](3);
        uint256[] memory badAmounts = new uint256[](2);

        // Populate arrays with mismatched lengths
        for (uint256 i = 0; i < 3; i++) {
            badRecievers[i] = vm.addr(20 + i);
            badTokenIds[i] = 200 + i;
        }

        badAmounts[0] = 1;
        badAmounts[1] = 2;

        // Expect revert due to length mismatch
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(badRecievers, badAmounts, badTokenIds);
    }

    /// @notice Check airdrop fails when tokens are not approved
    /// @dev Verifies token approval requirement
    function testAirdropNotApproved() public {
        // Revoke token approval
        vm.prank(treasury);
        token.setApprovalForAll(address(airdroper), false);

        // Expect revert due to lack of approval
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(recievers, amounts, tokenIds);
        vm.expectRevert();
        airdroper.airdrop(recievers, amounts, tokenIds);
    }

    /// @notice Verify contract is not pre-initialized
    /// @dev Ensures initialization can only happen once
    function testTemplateIsNotInitialized() public {
        ERC1155Airdroper template = new ERC1155Airdroper();
        assertFalse(template.initialized(), "Template should not be initialized");
    }

    /// @notice Verify DeployManager interface support
    /// @dev Checks interface compatibility of DeployManager
    function testDeployManagerSupportsInterfaceDirect() public {
        DeployManager deployManager = new DeployManager();
        bytes4 ifaces = type(IDeployManager).interfaceId;
        bool result = deployManager.supportsInterface(ifaces);
        assertTrue(result, "DeployManager should support IDeployManager interface");
    }

    /// @notice Helper function to encode initialization data
    /// @dev Prepares initialization parameters for contract setup
    function encodeInitData(address _deployManager, address _token, address _treasury, address _owner)
        public
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}
