// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "forge-std/Test.sol";
import "../src/FundMe.sol";
import "../script/DeployFundMe.s.sol";
import "forge-std/StdCheats.sol";

contract FundMeTest is StdCheats, Test {
    FundMe fundMe;
    uint256 constant AMOUNT = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 10 ether;
    address immutable i_user = makeAddr("user");
    uint256 constant GAS_PRICE = 1;

    constructor() {}

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(i_user, INITIAL_BALANCE); // supply eth for test
    }

    modifier funded(uint256 amount) {
        vm.prank(i_user); // the next tx will be send from i_user
        fundMe.fund{value: amount}();
        _;
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

    function testFundFailedWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateAddressToAmountFundedAndFunder()
        public
        funded(AMOUNT)
    {
        uint256 _realAmount = fundMe.getAddressToAmountFunded(i_user);
        assertEq(_realAmount, AMOUNT);
        address _funder = fundMe.getFunder(0);
        assertEq(_funder, i_user);
    }

    function testOnlyOwnerCanWithdraw() public funded(AMOUNT) {
        vm.startPrank(i_user);
        vm.expectRevert();
        fundMe.cheaperWithdraw();
        vm.stopPrank();
    }

    function testWithdrawWithSingleFunder() public funded(AMOUNT) {
        // must use address(fundMe) not the address(this),cause address(this) is the FundMeTest addr.
        uint256 _totalBalance = address(fundMe).balance +
            fundMe.getOwner().balance;
        // uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);
        uint256 _withdrawAfterOwnerBalance = fundMe.getOwner().balance;
        uint256 _withdrawAfterFundMeBalance = address(fundMe).balance;
        assertEq(_withdrawAfterFundMeBalance, 0);
        assertEq(_totalBalance, _withdrawAfterOwnerBalance);
    }

    function testWithdrawWithMultipleFunder() public {
        uint160 _numberOfFunders = 10;
        uint160 _startIndex = 1;
        for (uint160 i = _startIndex; i < _numberOfFunders; i++) {
            hoax(address(i), INITIAL_BALANCE);
            fundMe.fund{value: AMOUNT}();
            testWithdrawWithSingleFunder();
        }
    }
}
