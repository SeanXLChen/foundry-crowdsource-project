// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract addresses across different chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    // If on local anvil chain, deploy mocks
    // otherwise, use real addresses from the live chain
    struct NetworkConfig {
        string name;
        address priceFeed; // ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        // sepolia chain id: 11155111
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }

    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // return price feed address for sepolia eth/usd
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            name: "Sepolia",
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        // return price feed address for anvil eth/usd

        // 1. Deploy the mocks
        // 2. Return the mock address

        vm.startBroadcast();
        
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            name: "Anvil",
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return anvilConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // return price feed address for mainnet eth/usd
        NetworkConfig memory mainnetConfig = NetworkConfig({
            name: "Mainnet",
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }
}