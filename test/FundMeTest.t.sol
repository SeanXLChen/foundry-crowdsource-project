// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant ONE_ETH = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // send USER some ETH
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // 你(测试执行者) -> FundMeTest合约 -> DeployFundMe合约 -> FundMe合约
    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), msg.sender); 
        // fails as msg.sender is not the owner, owner of fundMe is FundMeTest
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // test这种需要请求链上数据的，需要define rpc, 不然会默认用anvil local network
    // `forge test --fork-url $SEPOLIA_RPC_URL`
    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund{value: 1e14}(); // 0.0001 ETH
    }

    function testFundFailsWithoutETH() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund(); // 0.0 ETH
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next tx will be from USER
        fundMe.fund{value: ONE_ETH}(); // 1 ETH from USER
        assertEq(fundMe.getAddressToAmountFunded(USER), ONE_ETH);
    }

    function testAddsFunderToTheFundersArray() public {
        vm.prank(USER); // The next tx will be from USER
        fundMe.fund{value: ONE_ETH}(); // 1 ETH from USER
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER); // The next tx will be from USER
        fundMe.fund{value: ONE_ETH}(); // 1 ETH from USER

        vm.expectRevert();
        vm.prank(USER); // The next tx will be from USER
        fundMe.withdraw();
    }
}