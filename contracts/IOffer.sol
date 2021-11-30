// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// Tenure is not within minimum and maximum authorized
/// @param tenure, actual tenure
/// @param minTenure, minimum tenure
/// @param maxTenure, maximum tenure
error InvalidTenure(uint8 tenure, uint8 minTenure, uint8 maxTenure);

/// AdvanceFee is higher than the maxAdvancedRatio
/// @param advanceFee, actual advanceFee
/// @param maxAdvancedRatio, maximum advanced ratio
error InvalidAdvanceFee(uint16 advanceFee, uint16 maxAdvancedRatio);

/// DiscountFee is lower than the minDiscountFee
/// @param discountFee, actual discountFee
/// @param minDiscountFee, minimum discount fee
error InvalidDiscountFee(uint16 discountFee, uint16 minDiscountFee);

/// FactoringFee is lower than the minDiscountFee
/// @param factoringFee, actual factoringFee
/// @param minFactoringFee, minimum factoring fee
error InvalidFactoringFee(uint16 factoringFee, uint16 minFactoringFee);

/// InvoiceAmount is not within minimum and maximum authorized
/// @param invoiceAmount, actual invoice amount
/// @param minAmount, minimum invoice amount
/// @param maxAmount, maximum invoice amount
error InvalidInvoiceAmount(uint invoiceAmount, uint minAmount, uint maxAmount);

/// Available Amount is higher than Invoice Amount
/// @param availableAmount, actual available amount
/// @param invoiceAmount, actual invoice amount
error InvalidAvailableAmount(uint availableAmount, uint invoiceAmount);

struct OfferItem {
    uint8 status;
    address borrowerAddress;
    address tokenAddress;
    uint advancedAmount;
    uint reserve;
    uint disbursingAdvanceDate;
    OfferParams params;
    OfferRefunded refunded;
}

struct OfferParams {
    uint8 gracePeriod;
    uint8 tenure;
    uint16 factoringFee;
    uint16 discountFee;
    uint16 advanceFee;
    uint invoiceAmount;
    uint availableAmount;
}

struct OfferRefunded {
    uint dueDate;
    uint16 lateFee;
    uint24 numberOfLateDays;
    uint totalCalculatedFees;
    uint netAmount;
    uint rewards;
}

interface IOffer {}
