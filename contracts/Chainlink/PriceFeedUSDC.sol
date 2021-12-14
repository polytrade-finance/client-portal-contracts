// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IPriceFeedUSDC.sol";
import "./AggregatorV3Interface.sol";

contract PriceFeedUSDC is IPriceFeedUSDC {
    AggregatorV3Interface immutable aggregator;

    constructor() {
        aggregator = AggregatorV3Interface(
            0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7
        );
    }

    function getPrice() public view returns (uint) {
        (, int price, , , ) = aggregator.latestRoundData();

        return uint(price);
    }

    function getDecimals() public view returns (uint) {
        return aggregator.decimals();
    }
}
