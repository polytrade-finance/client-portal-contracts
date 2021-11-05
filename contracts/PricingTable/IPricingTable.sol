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
        uint maxAmount;
    }

    function getPricingItem(bytes2 id)
        external
        view
        returns (PricingItem memory);

    function isPricingItemValid(bytes2 id) external view returns (bool);

    event NewPricingItem(bytes2 id);
    event RemovedPricingItem(bytes2 id);
}
