// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @title Offer
/// @author Polytrade
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

    /**
     * @notice Add a Pricing Item to the Pricing Table
     * @dev Only Owner is authorized to add a Pricing Item
     * @param pricingId, pricingId (hex format)
     * @param minTenure, minimum tenure expressed in percentage
     * @param maxTenure, maximum tenure expressed in percentage
     * @param maxAdvancedRatio, maximum advanced ratio expressed in percentage
     * @param minDiscountRange, minimum discount range expressed in percentage
     * @param minFactoringFee, minimum Factoring fee expressed in percentage
     * @param minAmount, minimum amount
     * @param maxAmount, maximum amount
     */
    function addPricingItem(
        bytes2 pricingId,
        uint8 minTenure,
        uint8 maxTenure,
        uint16 maxAdvancedRatio,
        uint16 minDiscountRange,
        uint16 minFactoringFee,
        uint minAmount,
        uint maxAmount
    ) external;

    /**
     * @notice Add a Pricing Item to the Pricing Table
     * @dev Only Owner is authorized to add a Pricing Item
     * @param pricingId, pricingId (hex format)
     * @param minTenure, minimum tenure expressed in percentage
     * @param maxTenure, maximum tenure expressed in percentage
     * @param maxAdvancedRatio, maximum advanced ratio expressed in percentage
     * @param minDiscountRange, minimum discount range expressed in percentage
     * @param minFactoringFee, minimum Factoring fee expressed in percentage
     * @param minAmount, minimum amount
     * @param maxAmount, maximum amount
     */
    function updatePricingItem(
        bytes2 pricingId,
        uint8 minTenure,
        uint8 maxTenure,
        uint16 maxAdvancedRatio,
        uint16 minDiscountRange,
        uint16 minFactoringFee,
        uint minAmount,
        uint maxAmount,
        bool status
    ) external;

    /**
     * @notice Remove a Pricing Item from the Pricing Table
     * @dev Only Owner is authorized to add a Pricing Item
     * @param id, id of the pricing Item
     */
    function removePricingItem(bytes2 id) external;

    /**
     * @notice Returns the pricing Item
     * @param id, id of the pricing Item
     * @return returns the PricingItem (struct)
     */
    function getPricingItem(bytes2 id)
        external
        view
        returns (PricingItem memory);

    /**
     * @notice Returns if the pricing Item is valid
     * @param id, id of the pricing Item
     * @return returns boolean if pricing is valid or not
     */
    function isPricingItemValid(bytes2 id) external view returns (bool);

    event NewPricingItem(PricingItem id);
    event UpdatedPricingItem(PricingItem id);
    event RemovedPricingItem(bytes2 id);
}
