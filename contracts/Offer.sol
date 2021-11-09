//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.9;
//
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "./IOffer.sol";
//import "./PricingTable/IPricingTable.sol";
//import "hardhat/console.sol";
//import "./IOffer.sol";
//
//contract Offers is Ownable {
//    IPricingTable pricingTable;
//
//    uint _precision = 1E4;
//    uint decimals = 2;
//
//    constructor(address pricingAddress) {
//        pricingTable = IPricingTable(pricingAddress);
//    }
//
//    uint private countId;
//    mapping(uint => bytes2) private OfferToPricingId;
//    mapping(uint => OfferItem) public Offers;
//    uint precision = 1E4;
//
//    function createOffer(bytes2 pricingId, OfferParams memory params)
//        public
//        onlyOwner
//        returns (uint)
//    {
//        require(
//            pricingTable.isPricingItemValid(pricingId),
//            "PricingItem not valid"
//        );
//
//        IPricingTable.PricingItem memory pricing;
//        pricing = pricingTable.getPricingItem(pricingId);
//        require(
//            params.tenure >= pricing.minTenure &&
//                params.tenure <= pricing.maxTenure,
//            "Tenure not within range"
//        );
//        require(
//            params.advanceFee <= pricing.maxAdvancedRatio,
//            "Advance higher than max"
//        );
//        require(
//            params.discountFee >= pricing.minDiscountFee,
//            "Discount lower than min"
//        );
//        require(
//            params.factoringFee >= pricing.minFactoringFee,
//            "Factoring lower than min"
//        );
//        require(
//            params.invoiceAmount >= pricing.minAmount &&
//                params.invoiceAmount <= pricing.maxAmount,
//            "Amount not within range"
//        );
//        require(
//            params.invoiceAmount >= params.availableAmount,
//            "Invoice amount > Available"
//        );
//
//        OfferItem memory offer;
//        offer.advancedAmount =
//            (params.availableAmount * params.advanceFee) /
//            precision;
//        console.log("%s:    advanced", offer.advancedAmount);
//        //        console.log("%s:    advancedAmount %s", params.invoiceAmount);
//
//        offer.reserve = (params.invoiceAmount - offer.advancedAmount);
//        offer.disbursingAdvanceDate = block.timestamp;
//        console.log("reserve %s", offer.reserve);
//
//        require((offer.advancedAmount + offer.reserve) == params.invoiceAmount);
//
//        countId++;
//        OfferToPricingId[countId] = pricingId;
//        offer.params = params;
//        Offers[countId] = offer;
//
//        return countId;
//    }
//
//    //    //Buyer paymentDate
//    //    //Buyer paymentRefNo
//    //    //receivedAmount
//    //    //unAppliedOrShortAmount
//    //    //
//    //    function offerPaymentReceived(
//    //        uint offerId,
//    //        uint paymentDate,
//    //        uint receivedAmount,
//    //        string paymentRef
//    //    ) external onlyOwner {
//    //        invoiceAmount - receivedAmount;
//    //        //            offersPaymentsReceived[_id] = _offer;
//    //        //            emit OfferPaymentReceived(_id, _offer);
//    //    }
//
//    // new state for offer - we ready to send trade tokens to user
//    function reserveRefund(
//        uint offerId,
//        uint dueDate,
//        uint16 lateFee
//    ) public onlyOwner {
//        OfferItem memory offer = Offers[offerId];
//
//        uint totalFees;
//        if (
//            block.timestamp > (dueDate + offer.params.gracePeriod) &&
//            block.timestamp - dueDate > offer.params.gracePeriod
//        ) {
//            uint numberOfLateDays = (block.timestamp -
//                dueDate -
//                offer.params.gracePeriod) / 1 days;
//            console.log("%s nb of late", numberOfLateDays);
//            console.log("%s 1day", (((lateFee * offer.advancedAmount) / 365)));
//            //            totalFees += (((lateFee * offer.advancedAmount) / 365) * numberOfLateDays);
//            console.log("lateFees = %s", totalFees);
//        }
//
//        uint factoringAmount = (
//            (offer.params.factoringFee * offer.params.invoiceAmount)
//        );
//
//        totalFees += factoringAmount;
//        console.log("%s after factoring", totalFees);
//        uint discountAmount = (
//            (((offer.advancedAmount * offer.params.discountFee) / 365) *
//                offer.params.tenure)
//        );
//
//        totalFees += discountAmount;
//
//        console.log("%s after discount", totalFees);
//
//        totalFees /= precision;
//
//        console.log("%s after precision", totalFees);
//        console.log("discountAmount: %s", discountAmount);
//        console.log("factoring: %s", factoringAmount);
//        //        emit OfferReserveFundAllocated(_id, _offer);
//    }
//
//    //
//    //    function getAmountsForFinish(uint256 _id)
//    //    external view
//    //    returns (
//    //        uint256,
//    //        address
//    //    )
//    //    {
//    //        return (
//    //        offersFundsRefunded[_id].toPayTradeTokens * 10**15,
//    //        offers[_id].offerAddress
//    //        );
//    //    }
//    //
//    //    // Treasury can move offer to new state
//    //    function changeStatusFromTreasury(uint256 _id, uint8 status)
//    //    external
//    //    returns (bool)
//    //    {
//    //        require(msg.sender == _treasuryAddress, "Wrong treasury address");
//    //        updateOfferStatus(_id, status);
//    //        return true;
//    //    }
//    //
//    //    //events
//    //    event PricingTableSet(address oldAddress, address newAddress);
//    //    event TreasuryAddressSet(address oldAddress, address newAddress);
//    //    event OfferStatusUpdated(uint256 _id, uint256 newStatus);
//    //    event NewOffer(uint256 _id);
//    //
//    //    event OfferFundAllocated(uint256 _id, OfferItemAdvanceAllocated _offer);
//    //    event OfferPaymentReceived(uint256 _id, OfferItemPaymentReceived _offer);
//    //    event OfferReserveFundAllocated(uint256 _id, OfferItemRefunded _offer);
//}
