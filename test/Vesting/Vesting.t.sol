// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import {Vesting} from "../../contracts/Vesting/Vesting.sol";
import {IVesting} from "contracts/Vesting/IVesting.sol";
import {MockERC20} from "test/ERC20Airdroper/MockERC20.sol";
import {MockDeployManager} from "test/DeployManager/MockDeployManager.sol";

/// @title Vesting Contract Test Suite
/// @notice Comprehensive test coverage for token vesting mechanism
contract VestingTest is Test {
    Vesting public vesting;
    MockERC20 public token;
    MockDeployManager public mockDeployManager;
    address public vestingOwner;
    address public beneficiary;
    address public managerOwner;

    // Event definitions for vm.expectEmit
    event TokensWithdrawn(address indexed to, uint256 amount);
    event vestingCreated(address indexed beneficiary, uint256 amount, uint256 creationTime);
    event Claim(address indexed beneficiary, uint256 amount, uint256 timestamp);

    /// @notice Allows contract to receive ether for testing payable functions
    receive() external payable {}

    /// @notice Prepare test environment with predefined token and contract states
    /// @dev Initializes test addresses, deploys mock contracts, and sets up initial token balance
    function setUp() public {
        // Initialize test addresses with unique identifiers
        vestingOwner = vm.addr(1);
        beneficiary = vm.addr(2);
        managerOwner = vm.addr(42);

        // Deploy mock contracts for testing
        token = new MockERC20();
        vesting = new Vesting();
        mockDeployManager = new MockDeployManager();

        // Mint tokens to vesting contract
        token.mint(address(vesting), 10_000 * 1e18);

        // Initialize vesting contract with mock deploy manager
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), vestingOwner);
        vesting.initialize(initData);
    }

    /// @notice Verify successful vesting schedule creation and token claim
    /// @dev Checks that tokens can be claimed after cliff period
    function testStartVestingAndClaim() public {
        // Create vesting schedule with standard parameters
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });

        // Start vesting schedule
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // Warp past cliff period
        vm.warp(block.timestamp + 3);

        // Claim tokens as beneficiary
        vm.prank(beneficiary);
        vesting.claim();

        // Verify tokens were transferred
        assertGt(token.balanceOf(beneficiary), 0, "Beneficiary should have claimed tokens");
    }

    /// @notice Ensure tokens cannot be claimed before cliff period
    /// @dev Checks that premature claim attempts are rejected
    function testVestingCliff() public {
        // Create vesting schedule with longer cliff
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 10,
            duration: 20,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });

        // Start vesting schedule
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // Attempt to claim before cliff period
        vm.warp(block.timestamp + 5);
        vm.prank(beneficiary);
        vm.expectRevert();
        vesting.claim();
    }

    /// @notice Verify claim cooldown mechanism
    /// @dev Checks that claims are restricted by cooldown period
    function testVestingCooldown() public {
        // Prepare vesting parameters with specific cooldown
        uint256 blockTimestamp = block.timestamp;
        uint256 cliff = 1;
        uint256 duration = 10;
        uint256 claimCooldown = 5;
        uint256 startTime = blockTimestamp + 1;

        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: startTime,
            cliff: cliff,
            duration: duration,
            claimCooldown: claimCooldown,
            minClaimAmount: 100 * 1e18
        });

        // Start vesting schedule
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // First claim after cliff
        uint256 afterCliff = startTime + cliff + 1;
        vm.warp(afterCliff);
        vm.prank(beneficiary);
        vesting.claim();

        // Attempt premature second claim
        vm.warp(afterCliff + 1);
        vm.prank(beneficiary);
        vm.expectRevert();
        vesting.claim();

        // Claim after cooldown period
        vm.warp(afterCliff + claimCooldown + 1);
        vm.prank(beneficiary);
        vesting.claim();

        // Verify tokens were transferred
        assertGt(token.balanceOf(beneficiary), 0, "Beneficiary should have claimed tokens after cooldown");
    }

    /// @notice Check minimum claim amount restriction
    /// @dev Ensures claims below minimum amount are rejected
    function testVestingMinClaimAmount() public {
        // Create vesting schedule with high minimum claim amount
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 900 * 1e18
        });

        // Start vesting schedule
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // Attempt to claim below minimum amount
        vm.warp(block.timestamp + 2);
        vm.prank(beneficiary);
        vm.expectRevert();
        vesting.claim();
    }

    /// @notice Verify contract template is not pre-initialized
    /// @dev Ensures initialization can only happen once
    function testTemplateIsNotInitialized() public {
        Vesting template = new Vesting();
        assertFalse(template.initialized(), "Template should not be initialized");
    }

    /// @notice Test unallocated token withdrawal mechanism
    /// @dev Checks owner can withdraw excess tokens and access controls
    function testWithdrawUnallocatedSuccess() public {
        // Mint additional tokens to vesting contract
        uint256 extra = 500 * 1e18;
        token.mint(address(vesting), extra);
        address receiver = vm.addr(99);

        // Calculate expected withdrawable amount
        uint256 before = token.balanceOf(receiver);
        uint256 expected = token.balanceOf(address(vesting)) - vesting.allocatedTokens();

        // Verify non-owner cannot withdraw
        vm.prank(beneficiary);
        vm.expectRevert();
        vesting.withdrawUnallocated(receiver);

        // Owner withdraws unallocated tokens
        vm.prank(vestingOwner);
        vm.expectEmit(true, false, false, true);
        emit TokensWithdrawn(receiver, expected);
        vesting.withdrawUnallocated(receiver);

        // Verify tokens were transferred correctly
        assertEq(token.balanceOf(receiver), before + expected, "Receiver should get unallocated tokens");

        // Contract's unallocated balance is now zero
        uint256 allocated = vesting.allocatedTokens();
        uint256 afterContract = token.balanceOf(address(vesting));
        assertEq(afterContract - allocated, 0, "No unallocated tokens should remain");
    }

    /// @notice Verify withdrawal fails when no unallocated tokens exist
    /// @dev Checks revert when attempting to withdraw fully allocated tokens
    function testWithdrawUnallocatedRevertIfNothing() public {
        // Allocate entire contract balance
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 10_000 * 1e18, // matches contract balance
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });

        // Start vesting schedule
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // Attempt to withdraw
        address receiver = vm.addr(99);
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.withdrawUnallocated(receiver);
    }

    /// @notice Test various input validation scenarios for vesting schedule creation
    /// @dev Checks revert conditions for invalid vesting parameters
    function testStartVestingRevertsZeroAddress() public {
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: address(0),
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.startVesting(params);
    }

    /// @notice Verify vesting creation fails with zero total amount
    function testStartVestingRevertsZeroAmount() public {
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 0,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.startVesting(params);
    }

    /// @notice Ensure vesting creation fails with zero duration
    function testStartVestingRevertsZeroDuration() public {
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 0,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.startVesting(params);
    }

    /// @notice Check that cooldown cannot be longer than vesting duration
    function testStartVestingRevertsCooldownLongerThanDuration() public {
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 20,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.startVesting(params);
    }

    /// @notice Verify vesting creation fails with start time in the past
    function testStartVestingRevertsStartTimeInPast() public {
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp - 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.startVesting(params);
    }

    /// @notice Check that vesting creation fails with insufficient contract balance
    function testStartVestingRevertsInsufficientBalance() public {
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 100_000 * 1e18, // more than contract balance
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.startVesting(params);
    }

    /// @notice Verify that creating a vesting schedule for an existing beneficiary fails
    function testStartVestingRevertsAlreadyExists() public {
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // Try to start again before claimed
        vm.prank(vestingOwner);
        vm.expectRevert();
        vesting.startVesting(params);
    }

    /// @notice Test vesting info retrieval and initialization data generation
    /// @dev Verifies getVestingInfo and getInitData functions
    function testGetVestingInfoAndInitData() public {
        // Create vesting schedule
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // Verify vesting info retrieval
        IVesting.VestingInfo memory info = vesting.getVestingInfo(beneficiary);
        assertEq(info.totalAmount, 1000 * 1e18);
        assertEq(info.created, true);

        // Verify initialization data generation
        bytes memory data = vesting.getInitData(address(mockDeployManager), address(token), vestingOwner);
        (address d, address t, address o) = abi.decode(data, (address, address, address));
        assertEq(d, address(mockDeployManager));
        assertEq(t, address(token));
        assertEq(o, vestingOwner);
    }

    /// @notice Test vested and claimable amount view functions
    /// @dev Checks vestedAmount and claimableAmount calculations
    function testVestingAndClaimableAmountViews() public {
        // Create vesting schedule
        IVesting.VestingParams memory params = IVesting.VestingParams({
            beneficiary: beneficiary,
            totalAmount: 1000 * 1e18,
            startTime: block.timestamp + 1,
            cliff: 1,
            duration: 10,
            claimCooldown: 2,
            minClaimAmount: 100 * 1e18
        });
        vm.prank(vestingOwner);
        vesting.startVesting(params);

        // Verify zero amounts before cliff
        assertEq(vesting.vestedAmount(beneficiary), 0);
        assertEq(vesting.claimableAmount(beneficiary), 0);

        // Verify non-zero amounts after cliff
        vm.warp(block.timestamp + 3);
        assertGt(vesting.vestedAmount(beneficiary), 0);
        assertGt(vesting.claimableAmount(beneficiary), 0);
    }

    /// @notice Helper function to encode initialization data
    /// @dev Prepares initialization parameters for contract setup
    function encodeInitData(address _deployManager, address _token, address _owner)
        public
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _owner);
    }
}
