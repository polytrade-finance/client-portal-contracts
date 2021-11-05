// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPricingTable {
    struct PricingItem {
        uint8 minTenure;
        uint8 maxTenure;
        uint16 maxAdvancedRatio;
        uint16 minDiscountFee;
        uint16 minFactoringFee;
        uint minAmount;
    }

    event NewPricingItem(uint id);
    event RemovedPricingItem(uint id);
}
