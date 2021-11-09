// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct OfferParams {
    uint8 gracePeriod;
    uint8 tenure;
    uint16 factoringFee;
    uint16 discountFee;
    uint16 advanceFee;
    uint invoiceAmount;
    uint availableAmount;
}

struct OfferItem {
    uint8 status;
    address borrowerAddress;
    address tokenAddress;
    uint advancedAmount;
    uint reserve;
    uint disbursingAdvanceDate;
    OfferParams params;
}

//pricingId
//disbursingAdvanceDate

struct OfferItemAdvanceAllocated {
    string polytradeInvoiceNo;
    uint clientCreateDate;
    uint actualAmount;
    uint disbursingAdvanceDate;
    uint advancedAmount;
    uint reserveHeldAmount;
    uint dueDate;
    uint amountDue;
    uint totalFee;
}

struct OfferItemPaymentReceived {
    uint paymentDate;
    uint receivedAmount;
    uint unpaidAmount;
    string paymentRef;
}

//dueDate
//numberOfLateDays
//Total Fee
//latePercentage
//netAmount payable to client
//toPayTradeTokens

struct OfferItemRefunded {
    uint dueDate;
    uint16 lateFee;
    uint16 numberOfLateDays;
    uint totalFee;
    uint netAmount;
    uint rewards;
}

interface IOffer {
    function getAmountsForTransfers(uint _id)
        external
        returns (
            address _tokenAddress,
            uint _amount,
            address _address
        );

    function getAmountsForFinish(uint _id)
        external
        returns (uint _amount, address _address);

    function changeStatusFromTreasury(uint _id, uint8 status)
        external
        returns (bool);
}
