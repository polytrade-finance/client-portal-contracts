// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./IPriceFeeds.sol";
import "./AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Offer
/// @author Polytrade
contract PriceFeeds is IPriceFeeds, Ownable {
    /// Mapping stableAddress to its USD Aggregator
    mapping(address => AggregatorV3Interface) public stableAggregators;

    /**
     * @notice Link Stable Address to ChainLink Aggregator
     * @dev Add a mapping stableAddress to aggregator
     * @param stable, address of the ERC-20 stable smart contract
     * @param aggregator, address of the aggregator to map with the stableAddress
     */
    function setStableAggregator(address stable, address aggregator)
        external
        onlyOwner
    {
        stableAggregators[stable] = AggregatorV3Interface(aggregator);
    }

    /**
     * @notice Get the price of the stableAddress against USD dollar
     * @dev Query Chainlink aggregator to get Stable/USD price
     * @param stableAddress, address of the stable to be queried
     * @return price of the stable against USD dollar
     */
    function getPrice(address stableAddress) public view returns (uint) {
        (, int price, , , ) = stableAggregators[stableAddress]
            .latestRoundData();

        return uint(price);
    }

    /**
     * @notice Returns the decimal used for the stable
     * @dev Query Chainlink aggregator to get decimal
     * @param stableAddress, address of the stable to be queried
     * @return decimals of the USD
     */
    function getDecimals(address stableAddress) public view returns (uint) {
        return stableAggregators[stableAddress].decimals();
    }
}
