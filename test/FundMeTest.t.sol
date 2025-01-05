// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
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

}