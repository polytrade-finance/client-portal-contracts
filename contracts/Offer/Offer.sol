// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IOffer.sol";
import "../PricingTable/IPricingTable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Offer
/// @author Polytrade
contract Offers is IOffer, Ownable {
    IPricingTable public pricingTable;

    uint private _countId;
    uint private _precision = 1E4;

    mapping(uint => bytes2) private _offerToPricingId;
    mapping(uint => OfferItem) public offers;

    constructor(address pricingAddress) {
        pricingTable = IPricingTable(pricingAddress);
    }

    /**
     * @notice Create an offer, check if it fits pricingItem requirements
     * @dev calls _checkParams and returns Error if params don't fit with the pricingID
     * @dev only `Owner` can create a new offer
     * @dev emits OfferCreated event
     * @param pricingId, Id of the pricing Item
     * @param params, OfferParams(gracePeriod, tenure, factoringFee, discountFee, advanceFee, invoiceAmount, availableAmount)
     */
    function createOffer(bytes2 pricingId, OfferParams memory params)
        public
        onlyOwner
        returns (uint)
    {
        require(
            _checkParams(
                pricingId,
                params.tenure,
                params.advanceFee,
                params.discountFee,
                params.factoringFee,
                params.invoiceAmount,
                params.availableAmount
            ),
            "Invalid offer parameters"
        );

        OfferItem memory offer;
        offer.advancedAmount = _calculateAdvancedAmount(
            params.availableAmount,
            params.advanceFee
        );

        offer.reserve = (params.invoiceAmount - offer.advancedAmount);
        offer.disbursingAdvanceDate = block.timestamp;

        require(
            (offer.advancedAmount + offer.reserve) == params.invoiceAmount,
            "advanced + reserve != invoice"
        );

        _countId++;
        _offerToPricingId[_countId] = pricingId;
        offer.params = params;
        offers[_countId] = offer;

        emit OfferCreated(_countId - 1, pricingId);
        return _countId;
    }

    /**
     * @notice Send the reserve Refund
     * @dev checks if Offer exists and if not refunded yet
     * @dev only `Owner` can call reserveRefund
     * @dev emits OfferReserveRefunded event
     * @param offerId, Id of the offer
     * @param dueDate, due date
     * @param lateFee, late fees (ratio)
     */
    function reserveRefund(
        uint offerId,
        uint dueDate,
        uint16 lateFee
    ) public onlyOwner {
        require(_offerToPricingId[offerId] != 0, "Offer doesn't exists");
        require(
            Offers[offerId].refunded.netAmount == 0,
            "Offer already refunded"
        );

        OfferItem memory offer = Offers[offerId];
        OfferRefunded memory refunded;

        refunded.lateFee = lateFee;
        refunded.dueDate = dueDate;

        uint lateAmount = 0;
        if (
            block.timestamp > (dueDate + offer.params.gracePeriod) &&
            block.timestamp - dueDate > offer.params.gracePeriod
        ) {
            refunded.numberOfLateDays = _calculateLateDays(
                dueDate,
                offer.params.gracePeriod
            );
            lateAmount = _calculateLateAmount(
                lateFee,
                refunded.numberOfLateDays,
                offer.advancedAmount
            );
        }

        uint factoringAmount = _calculateFactoringAmount(
            offer.params.invoiceAmount,
            offer.params.factoringFee
        );

        uint discountAmount = _calculateDiscountAmount(
            offer.advancedAmount,
            offer.params.discountFee,
            offer.params.tenure
        );

        refunded.totalCalculatedFees =
            (lateAmount + factoringAmount + discountAmount) /
            precision;
        refunded.netAmount = offer.reserve - refunded.totalCalculatedFees;

        Offers[offerId].refunded = refunded;
    }

    function _checkParams(
        bytes2 pricingId,
        uint8 tenure,
        uint16 advanceFee,
        uint16 discountFee,
        uint16 factoringFee,
        uint invoiceAmount,
        uint availableAmount
    ) private view returns (bool) {
        IPricingTable.PricingItem memory pricing = pricingTable.getPricingItem(
            pricingId
        );
        if (tenure < pricing.minTenure || tenure > pricing.maxTenure)
            revert InvalidTenure(tenure, pricing.minTenure, pricing.maxTenure);
        if (advanceFee > pricing.maxAdvancedRatio)
            revert InvalidAdvanceFee(advanceFee, pricing.maxAdvancedRatio);
        if (discountFee < pricing.minDiscountFee)
            revert InvalidDiscountFee(discountFee, pricing.minDiscountFee);
        if (factoringFee < pricing.minFactoringFee)
            revert InvalidFactoringFee(factoringFee, pricing.minFactoringFee);
        if (
            invoiceAmount < pricing.minAmount ||
            invoiceAmount > pricing.maxAmount
        )
            revert InvalidInvoiceAmount(
                invoiceAmount,
                pricing.minAmount,
                pricing.maxAmount
            );
        if (invoiceAmount < availableAmount)
            revert InvalidAvailableAmount(availableAmount, invoiceAmount);
        return true;
    }

    function _calculateAdvancedAmount(uint availableAmount, uint16 advanceFee)
        private
        view
        returns (uint)
    {
        return (availableAmount * advanceFee) / precision;
    }

    function _calculateFactoringAmount(uint invoiceAmount, uint16 factoringFee)
        private
        view
        returns (uint)
    {
        return (invoiceAmount * factoringFee) / precision;
    }

    function _calculateDiscountAmount(
        uint advancedAmount,
        uint16 discountFee,
        uint8 tenure
    ) private view returns (uint) {
        return (((advancedAmount * discountFee) / 365) * tenure) / precision;
    }

    function _calculateLateAmount(
        uint16 lateFee,
        uint24 lateDays,
        uint advancedAmount
    ) private view returns (uint) {
        return (((lateFee * advancedAmount) / 365) * lateDays) / precision;
    }

    function _calculateLateDays(uint dueDate, uint gracePeriod)
        private
        view
        returns (uint24)
    {
        return uint24(block.timestamp - dueDate - gracePeriod) / 1 days;
    }
}
