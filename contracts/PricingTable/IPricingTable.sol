// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPricingTable {
    struct PricingItem {
        uint8 minTenure;
        uint8 maxTenure;
        uint8 maxAdvancedRatio;
        uint8 minDiscountRange;
        uint8 minFactoringFee;
        uint minAmount;
    }

    event NewPricingItem(uint id);
    event RemovedPricingItem(uint id);
}
