// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "forge-std/Script.sol";
import "../src/FundMe.sol";
import "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    constructor() {}

    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (address ethToUsdPriceFeed, ) = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethToUsdPriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}
