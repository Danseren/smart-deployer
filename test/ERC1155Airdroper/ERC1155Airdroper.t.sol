// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import {ERC1155Airdroper} from "../../contracts/ERC1155Airdroper/ERC1155Airdroper.sol";
import {MockERC1155} from "./MockERC1155.sol";
import {MockDeployManager} from "../DeployManager/MockDeployManager.sol";
import {DeployManager} from "../../contracts/DeployManager/DeployManager.sol";
import {IDeployManager} from "../../contracts/DeployManager/IDeployManager.sol";

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

    receive() external payable {}

    function setUp() public {
        airdropOwner = vm.addr(1);
        treasury = vm.addr(2);
        managerOwner = vm.addr(42);
        recievers = new address[](3);
        tokenIds = new uint256[](3);
        amounts = new uint256[](3);

        for (uint256 i = 0; i < 3; i++) {
            recievers[i] = vm.addr(3 + i);
            tokenIds[i] = 100 + i;
            amounts[i] = 10 * (i + 1);
        }

        token = new MockERC1155();
        airdroper = new ERC1155Airdroper();
        mockDeployManager = new MockDeployManager();

        for (uint256 i = 0; i < 3; i++) {
            token.mint(treasury, tokenIds[i], amounts[i]);
        }

        vm.prank(treasury);
        token.setApprovalForAll(address(airdroper), true);
        bytes memory initData = encodeInitData(address(mockDeployManager), address(token), treasury, airdropOwner);
        airdroper.initialize(initData);
    }

    function testAirdropSuccess() public {
        vm.prank(airdropOwner);
        airdroper.airdrop(recievers, amounts, tokenIds);

        for (uint256 i = 0; i < 3; i++) {
            assertEq(token.balanceOf(recievers[i], tokenIds[i]), amounts[i], "Receiver should get correct amount");
        }
    }

    function testAirdropBatchSizeExceeded() public {
        address[] memory bigRecievers = new address[](11);
        uint256[] memory bigTokensIds = new uint256[](11);
        uint256[] memory bigAmounts = new uint256[](11);

        for (uint256 i = 0; i < 11; i++) {
            bigRecievers[i] = vm.addr(1000 + i);
            bigTokensIds[i] = 10_000 + i;
            bigAmounts[i] = 1;
        }

        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(bigRecievers, bigAmounts, bigTokensIds);
    }

    function testAirdropReceivrsLengthMismatch() public {
        address[] memory badRecievers = new address[](2);
        uint256[] memory badTokenIds = new uint256[](3);
        uint256[] memory badAmounts = new uint256[](3);
        badRecievers[0] = vm.addr(10);
        badRecievers[1] = vm.addr(11);
        badTokenIds[0] = 1;
        badTokenIds[1] = 2;
        badTokenIds[2] = 3;
        badAmounts[0] = 1;
        badAmounts[1] = 2;
        badAmounts[2] = 3;

        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(badRecievers, badAmounts, badTokenIds);
    }

    function testAirdropAmountsLengthMismatch() public {
        address[] memory badRecievers = new address[](3);
        uint256[] memory badTokenIds = new uint256[](3);
        uint256[] memory badAmounts = new uint256[](2);

        for (uint256 i = 0; i < 3; i++) {
            badRecievers[i] = vm.addr(20 + i);
            badTokenIds[i] = 200 + i;
        }

        badAmounts[0] = 1;
        badAmounts[1] = 2;

        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(badRecievers, badAmounts, badTokenIds);
    }

    function testAirdropNotApproved() public {
        vm.prank(treasury);
        token.setApprovalForAll(address(airdroper), false);

        vm.prank(airdropOwner);
        vm.expectRevert();
        airdroper.airdrop(recievers, amounts, tokenIds);
        vm.expectRevert();
        airdroper.airdrop(recievers, amounts, tokenIds);
    }

    function testTemplateIsNotInitialized() public {
        ERC1155Airdroper template = new ERC1155Airdroper();
        assertFalse(template.initialized(), "Template should not be initialized");
    }

    function testDeployManagerSupportsInterfaceDirect() public {
        DeployManager deployManager = new DeployManager();
        bytes4 ifaces = type(IDeployManager).interfaceId;
        bool result = deployManager.supportsInterface(ifaces);
        assertTrue(result, "DeployManager should support IDeployManager interface");
    }

    function encodeInitData(address _deployManager, address _token, address _treasury, address _owner)
        public
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}
