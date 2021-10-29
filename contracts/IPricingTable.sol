// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPricingTable {
    //    function getPricingTableItem(uint256 _id) returns
    event PricingDeprecated(uint id);
    event NewPricingItem(uint id);
}

struct PricingItem {
    uint minAmount;
    uint maxAmount;
    uint minAdvancedRatio;
    uint maxAdvancedRatio;
    uint minDiscountRange;
    uint maxDiscountRange;
    uint minFactoringFee;
    uint maxFactoringFee;
}
