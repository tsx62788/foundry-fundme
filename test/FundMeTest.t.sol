// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "forge-std/Test.sol";
import "../src/FundMe.sol";
import "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    constructor() {}

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFifty() public {
        assertEq(fundMe.MINIMUM_USD(), 50e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetPriceFeedVersion() public {
        // --fork-url
        // AggregatorV3Interface is not exist at localhost blockchain
        assertEq(fundMe.getVersion(), 4);
    }
}
