// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IPricingTable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Princing Table
/// @author Polytrade
contract PricingTable is IPricingTable, Ownable {
    mapping(bytes2 => PricingItem) private pricingItems;
    mapping(bytes2 => bool) private pricingStatus;

    uint private _pricingId;

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
     * @return returns the id of the pricing Item
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
    ) external onlyOwner {
        require(!pricingStatus[pricingId], "Already exists, please update");
        PricingItem memory _pricingItem;

        _pricingItem.minTenure = minTenure;
        _pricingItem.maxTenure = maxTenure;
        _pricingItem.minAmount = minAmount;
        _pricingItem.maxAmount = maxAmount;
        _pricingItem.maxAdvancedRatio = maxAdvancedRatio;
        _pricingItem.minDiscountFee = minDiscountRange;
        _pricingItem.minFactoringFee = minFactoringFee;
        pricingItems[pricingId] = _pricingItem;
        pricingStatus[pricingId] = true;
        emit NewPricingItem(pricingId);
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
