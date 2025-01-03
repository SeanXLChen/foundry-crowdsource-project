// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // us -> FundMeTest -> FundMe
    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), msg.sender); 
        // fails as msg.sender is not the owner, owner of fundMe is FundMeTest
        assertEq(fundMe.i_owner(), address(this));
    }
}