// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/FundMe.sol";
import "../src/tests/MockV3Aggregator.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    MockV3Aggregator mockV3Aggregator;
    address payable owner;
    address payable funder;
    address payable funder2;
    address payable funder3;
    address payable funder4;

    function setUp() public {
        funder = payable(address(0x1));
        funder2 = payable(address(0x2));
        funder3 = payable(address(0x3));
        funder4 = payable(address(0x4));
        owner = payable(address(0x5));

        mockV3Aggregator = new MockV3Aggregator(8, 200000000000);

        vm.prank(owner);
        fundMe = new FundMe(address(mockV3Aggregator));
        
    }

    function testSetsAggregatorAddressesCorrectly() public {
        AggregatorV3Interface expectedPriceFeed = fundMe.getPriceFeed();

        assertEq(address(expectedPriceFeed), address(mockV3Aggregator));
    }

    function testNeedMoreEth() public {
        vm.expectRevert(bytes("You need to spend more ETH!"));
        fundMe.fund();
    }

    function testUpdatesAmountFundedMapping() public {
        fundMe.fund{ value: 50 * 10**18 }();
        uint256 expectedAmountFunded = fundMe.getAddressToAmountFunded(address(this));
        assertEq(expectedAmountFunded, 50 * 10**18);
    }

    function testAddsToFundersArray() public {
        fundMe.fund{ value: 50 * 10**18 }();
        address expectedFunderAddress = fundMe.getFunder(0);
        assertEq(expectedFunderAddress, address(this));
    }

    function testWithdrawsEthFromSingleFunder() public {
        uint256 startingContractBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = owner.balance;

        fundMe.fund{ value: 50 * 10**18 }();

        assertEq(address(fundMe).balance, startingContractBalance + 50 * 10**18 );

        vm.prank(owner);
        fundMe.withdraw();

        assertEq(owner.balance, startingOwnerBalance + 50 * 10**18 );
        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawsEthFromMultipleFunders() public {
        // TODO: account for overflow/underflow with funders by giving starting balances during hoax
        // uint256 startingFunderBalance = funder.balance;
        // uint256 startingFunder2Balance = funder2.balance;
        // uint256 startingFunder3Balance = funder3.balance;
        // uint256 startingFunder4Balance = funder4.balance;
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingContractBalance = address(fundMe).balance;

        hoax(funder);
        fundMe.fund{ value: 1 ether }();

        hoax(funder2);
        fundMe.fund{ value: 1 ether }();

        hoax(funder3);
        fundMe.fund{ value: 1 ether }();

        hoax(funder4);
        fundMe.fund{ value: 1 ether }();

        assertEq(address(fundMe).balance, startingContractBalance + 4 ether);

        vm.prank(owner);
        fundMe.withdraw();

        assertEq(owner.balance, startingOwnerBalance + 4 ether );
        assertEq(address(fundMe).balance, 0);
    }

    function testOnlyOwnerCanWithdraw() public {
        fundMe.fund{ value: 1 ether }();

        startHoax(funder);
        vm.expectRevert(FundMe__NotOwner.selector);
        fundMe.withdraw();
    }
}
