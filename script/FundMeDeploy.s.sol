// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Script.sol";
import "../src/FundMe.sol";

contract FundMeScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        //deploying on rinkeby with ETH/USD price feed
        FundMe fundMe = new FundMe(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);

        vm.stopBroadcast();

    }
}
