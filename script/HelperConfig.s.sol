// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "forge-std/Script.sol";
import "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address ethToUsdPriceFeed;
        address daiToUsdPriceFeed;
    }
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIALANSWER = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaPriceFeed();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getOrCreateAnvilPriceFeed();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetPriceFeed();
        }
    }

    function getSepoliaPriceFeed()
        internal
        pure
        returns (NetworkConfig memory sepoliaPriceFeed)
    {
        sepoliaPriceFeed = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306,
            0x14866185B1962B63C3Ea9E03Bc1da838bab34C19
        );
    }

    function getMainnetPriceFeed()
        internal
        pure
        returns (NetworkConfig memory mainnetPriceFeed)
    {
        mainnetPriceFeed = NetworkConfig(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            0x773616E4d11A78F511299002da57A0a94577F1f4
        );
    }

    function getOrCreateAnvilPriceFeed()
        internal
        returns (NetworkConfig memory anvilPriceFeed)
    {
        if (address(activeNetworkConfig.ethToUsdPriceFeed) != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIALANSWER
        );

        vm.stopBroadcast();
        anvilPriceFeed = NetworkConfig(
            address(mockV3Aggregator),
            address(mockV3Aggregator)
        );
    }
}
