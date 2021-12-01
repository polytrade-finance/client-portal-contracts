// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IOffer.sol";
import "../PricingTable/IPricingTable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Offers is Ownable {
    IPricingTable pricingTable;

    uint _precision = 1E4;
    uint decimals = 2;

    constructor(address pricingAddress) {
        pricingTable = IPricingTable(pricingAddress);
    }

    uint private countId;
    mapping(uint => bytes2) private OfferToPricingId;
    mapping(uint => OfferItem) public Offers;
    uint precision = 1E4;

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

        require((offer.advancedAmount + offer.reserve) == params.invoiceAmount);

        countId++;
        OfferToPricingId[countId] = pricingId;
        offer.params = params;
        Offers[countId] = offer;

        return countId;
    }

    // new state for offer - we ready to send trade tokens to user
    function reserveRefund(
        uint offerId,
        uint dueDate,
        uint16 lateFee
    ) public onlyOwner {
        require(OfferToPricingId[countId] != 0, "Offer doesn't exists");
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
