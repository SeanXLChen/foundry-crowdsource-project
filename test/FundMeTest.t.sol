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
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // send USER some ETH
    }

    modifier fundUserOneETH() {
        vm.prank(USER); // The next tx will be from USER
        fundMe.fund{value: ONE_ETH}(); // 1 ETH from USER
        _;
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // 你(测试执行者) -> FundMeTest合约 -> DeployFundMe合约 -> FundMe合约
    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), msg.sender); 
        // fails as msg.sender is not the owner, owner of fundMe is FundMeTest
        assertEq(fundMe.getOwner(), msg.sender);
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

    function testFundUpdatesFundedDataStructure() public fundUserOneETH {
        assertEq(fundMe.getAddressToAmountFunded(USER), ONE_ETH);
    }

    function testAddsFunderToTheFundersArray() public fundUserOneETH {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public fundUserOneETH {
        vm.prank(USER); // The next tx will be from USER
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public fundUserOneETH {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // starting owner balance
        uint256 startingFundMeBalance = address(fundMe).balance; // starting contract balance
        
        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // set gas price
        vm.prank(fundMe.getOwner()); // The next tx will be from the owner
        fundMe.withdraw(); // withdraw all funds
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // gas used

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // ending owner balance
        uint256 endingFundMeBalance = address(fundMe).balance; // ending contract balance

        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public fundUserOneETH {
        // Arrange
        uint160 numberOfFunders = 10; // uint160 to match address compatibility
        uint160 startingFunderIndex = 1; // USER is already funded at index 0
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            address funder = address(uint160(USER) + i);
            // vm.prank(funder);
            // vm.deal(funder, STARTING_BALANCE);
            hoax(funder, STARTING_BALANCE);
            fundMe.fund{value: ONE_ETH}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }
}