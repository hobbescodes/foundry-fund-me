// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {DeployFundMe} from "../script/DeployFundMe.s.sol";

import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // address owner = address(this); <-- this is if the test contract is isolated. If we are using DeployFundMe in our testing suite, then we need to use msg.sender, because DeployFundMe is deployed by msg.sender.
    address owner = msg.sender;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumUSDIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwner() public view {
        assertEq(fundMe.i_owner(), owner);
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }
}
