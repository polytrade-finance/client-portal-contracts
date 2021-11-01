// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IPricingTable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Princing Table
/// @author Polytrade
contract PricingTable is IPricingTable, Ownable {
    mapping(uint => PricingItem) private pricingTable;

    uint private _pricingId;

    /**
     * @notice Add a Pricing Item to the Pricing Table
     * @dev Only Owner is authorized to add a Pricing Item
     * @param minTenure, minimum tenure expressed in percentage
     * @param maxTenure, maximum tenure expressed in percentage
     * @param maxAdvancedRatio, maximum advanced ratio expressed in percentage
     * @param minDiscountRange, minimum discount range expressed in percentage
     * @param minFactoringFee, minimum Factoring fee expressed in percentage
     * @param minAmount, minimum amount
     * @return returns the id of the pricing Item
     */
    function addPricingItem(
        uint8 minTenure,
        uint8 maxTenure,
        uint8 maxAdvancedRatio,
        uint8 minDiscountRange,
        uint8 minFactoringFee,
        uint minAmount
    ) external onlyOwner returns (uint) {
        PricingItem memory _pricingItem;

        _pricingId++;
        _pricingItem.minTenure = minTenure;
        _pricingItem.maxTenure = maxTenure;
        _pricingItem.minAmount = minAmount;
        _pricingItem.maxAdvancedRatio = maxAdvancedRatio;
        _pricingItem.minDiscountRange = minDiscountRange;
        _pricingItem.minFactoringFee = minFactoringFee;
        pricingTable[_pricingId] = _pricingItem;
        emit NewPricingItem(_pricingId);

        return _pricingId;
    }

    /**
     * @notice Remove a Pricing Item from the Pricing Table
     * @dev Only Owner is authorized to add a Pricing Item
     * @param id, id of the pricing Item
     */
    function removePricingItem(uint id) external onlyOwner {
        delete pricingTable[id];
        emit RemovedPricingItem(id);
    }

    /**
     * @notice Returns the pricing Item
     * @param id, id of the pricing Item
     * @return returns the PricingItem (struct)
     */
    function getPricingItem(uint id)
        external
        view
        returns (PricingItem memory)
    {
        return pricingTable[id];
    }
}
