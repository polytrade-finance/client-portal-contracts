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
            offers[offerId].refunded.netAmount == 0,
            "Offer already refunded"
        );

        OfferItem memory offer = offers[offerId];
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
                offer.advancedAmount,
                lateFee,
                refunded.numberOfLateDays
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

        refunded.totalCalculatedFees = (lateAmount +
            factoringAmount +
            discountAmount);
        refunded.netAmount = offer.reserve - refunded.totalCalculatedFees;

        offers[offerId].refunded = refunded;
        emit ReserveRefunded(offerId, refunded.netAmount);
    }

    /**
     * @notice check if params fit with the pricingItem
     * @dev checks every params and returns a custom Error
     * @param pricingId, Id of the pricing Item
     * @param tenure, tenure expressed in number of days
     * @param advanceFee, ratio for the advance Fee
     * @param discountFee, ratio for the discount Fee
     * @param factoringFee, ratio for the factoring Fee
     * @param invoiceAmount, amount for the invoice
     * @param availableAmount, amount for the available amount
     */
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

    /**
     * @notice calculate the advanced Amount (availableAmount * advanceFee)
     * @dev calculate based on `(availableAmount * advanceFee)/ _precision` formula
     * @param availableAmount, amount for the available amount
     * @param advanceFee, ratio for the advance Fee
     * @return uint amount of the advanced
     */
    function _calculateAdvancedAmount(uint availableAmount, uint16 advanceFee)
        private
        view
        returns (uint)
    {
        return (availableAmount * advanceFee) / _precision;
    }

    /**
     * @notice calculate the Factoring Amount (invoiceAmount * factoringFee)
     * @dev calculate based on `(invoiceAmount * factoringFee) / _precision` formula
     * @param invoiceAmount, amount for the invoice amount
     * @param factoringFee, ratio for the factoring Fee
     * @return uint amount of the factoring
     */
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
