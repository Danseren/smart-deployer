// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import {ERC721Airdroper} from "../../contracts/ERC721Airdroper/ERC721Airdroper.sol";
import {MockERC721} from "./MockERC721.sol";
import {MockDeployManager} from "test/DeployManager/MockDeployManager.sol";
import {DeployManager} from "../../contracts/DeployManager/DeployManager.sol";
import {IDeployManager} from "../../contracts/DeployManager/IDeployManager.sol";

/// @notice Comprehensive test suite for ERC721Airdroper contract
contract ERC721AirdroperTest is Test {
    ERC721Airdroper public airdroper;
    MockERC721 public token;
    MockDeployManager public mockDeployManager;
    address public airdropOwner;
    address public treasury;
    address public managerOwner;
    address[] public receivers;
    uint256[] public tokenIds;

    /// @notice Allows contract to receive ether for testing payable functions
    receive() external payable {}

    /// @notice Prepare test environment with predefined token and contract states
    function setUp() public {
        // Initialize test addresses and mock contracts
        airdropOwner = vm.addr(1);
        treasury = vm.addr(2);
        managerOwner = vm.addr(42);

        // Prepare test receivers with unique token IDs
        receivers = new address[](3);
        tokenIds = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            receivers[i] = vm.addr(3 + i);
            tokenIds[i] = 100 + i;
        }

        // Setup mock token, airdroper, and deploy manager
        token = new MockERC721();
        airdroper = new ERC721Airdroper();
        mockDeployManager = new MockDeployManager();

        // Mint tokens to treasury for airdrop
        for (uint256 i = 0; i < 3; i++) {
            token.mint(treasury, tokenIds[i]);
        }

        // Approve airdroper to manage tokens
        vm.prank(treasury);
        token.setApprovalForAll(address(airdroper), true);

        // Initialize airdroper with mock deploy manager
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), treasury, airdropOwner);
        airdroper.initialize(initData);
    }

    /// @notice Validate successful NFT distribution across multiple receivers
    function testAirdropSuccess() public {
        vm.prank(airdropOwner);
        airdroper.airdrop(receivers, tokenIds);

        // Verify each token is transferred to the correct receiver
        for (uint256 i = 0; i < 3; i++) {
            assertEq(token.ownerOf(tokenIds[i]), receivers[i], "Receiver should own token");
        }
    }

    /// @notice Check airdrop fails when exceeding maximum batch size
    function testAirdropBatchSizeExceeded() public {
        // Create oversized arrays to trigger batch size limit
        address[] memory bigReceivers = new address[](301);
        uint256[] memory bigTokenIds = new uint256[](301);

        for (uint256 i = 0; i < 301; i++) {
            bigReceivers[i] = vm.addr(1000 + i);
            bigTokenIds[i] = 10000 + i;
        }

        // Attempt airdrop with too many recipients
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(bigReceivers, bigTokenIds);
    }

    /// @notice Ensure airdrop fails with mismatched receiver and token ID arrays
    function testAirdropArraysLengthMismatch() public {
        // Prepare arrays with different lengths
        address[] memory badReceivers = new address[](2);
        uint256[] memory badTokenIds = new uint256[](3);
        badReceivers[0] = vm.addr(10);
        badReceivers[1] = vm.addr(11);
        badTokenIds[0] = 1;
        badTokenIds[1] = 2;
        badTokenIds[2] = 3;

        // Attempt airdrop with mismatched array lengths
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(badReceivers, badTokenIds);
    }

    /// @notice Verify airdrop fails when treasury revokes token approval
    function testAirdroNotApproved() public {
        // Remove approval for token transfers
        vm.prank(treasury);
        token.setApprovalForAll(address(airdroper), false);

        // Attempt airdrop without approval
        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(receivers, tokenIds);
    }

    /// @notice Verify contract template is not pre-initialized
    function testTmplateIsNotInitialized() public {
        ERC721Airdroper template = new ERC721Airdroper();
        assertFalse(template.initialized(), "Template should not be initialized");
    }

    /// @notice Verify DeployManager interface support
    function testDeployManagerSupportsInterfaseDirect() public {
        DeployManager deployManager = new DeployManager();
        bytes4 iface = type(IDeployManager).interfaceId;
        bool result = deployManager.supportsInterface(iface);
        assertTrue(result, "DeployManager should support IDeployManager interface");
    }

    /// @notice Helper function to encode initialization data
    function encodeInitData(address _deployManager, address _token, address _treasury, address _owner)
        public
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}
