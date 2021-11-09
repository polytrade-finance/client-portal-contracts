// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IOffer.sol";
import "./PricingTable/IPricingTable.sol";
import "hardhat/console.sol";

contract Offers is Ownable {
    //    IPricingTable private _pricingTable;
    //    mapping(uint256 => OfferItem) private offers;
    //    mapping(uint256 => OfferItemAdvanceAllocated)
    //    private offersAdvancesAllocated;
    //    mapping(uint256 => OfferItemPaymentReceived) private offersPaymentsReceived;
    //    mapping(uint256 => OfferItemRefunded) private offersFundsRefunded;
    //    uint256 private offersCount;
    //    address private _treasuryAddress;
    //
    //    // getter for one offer
    //    function getOneOffer(uint256 _id) external view returns (OfferItem memory) {
    //        return offers[_id];
    //    }
    //
    //    // getter for offersCount
    //    function getOffersCount() external view returns (uint256) {
    //        return offersCount;
    //    }
    //
    //    // getter for pricing table inctance
    //    function getPricingTable() public view returns (IPricingTable) {
    //        return _pricingTable;
    //    }
    //
    //    function setNewTreasuryAddress(address _newAddress)
    //    public
    //    onlyOwner
    //    returns (bool)
    //    {
    //        require(_newAddress != address(0), "Address cannot be zero");
    //        emit TreasuryAddressSet(address(_treasuryAddress), _newAddress);
    //        _treasuryAddress = _newAddress;
    //        return true;
    //    }
    //
    //    // setter for pricing table contract address
    //    function setPricingTable(address _newPricingTableAddress)
    //    public
    //    onlyOwner
    //    returns (bool)
    //    {
    //        require(
    //            _newPricingTableAddress != address(0),
    //            "Address cannot be zero"
    //        );
    //        emit PricingTableSet(address(_pricingTable), _newPricingTableAddress);
    //        _pricingTable = IPricingTable(_newPricingTableAddress);
    //        return true;
    //    }
    //
    //    function isInMinMaxRange(
    //        uint256 _check,
    //        uint256 _min,
    //        uint256 _max
    //    ) private pure returns (bool) {
    //        return _check <= _max && _check >= _min;
    //    }
    //
    //    // check that offer's arguments are fit selected pricing table item
    //    function offerFitsPricingTableItem(
    //        OfferItem memory offer,
    //        PricingTableItem memory pricing
    //    ) internal pure returns (bool) {
    //        return
    //        isInMinMaxRange(
    //            offer.amount,
    //            pricing.minAmount,
    //            pricing.maxAmount
    //        ) &&
    //        isInMinMaxRange(
    //            offer.tenure,
    //            pricing.minTenure,
    //            pricing.maxTenure
    //        ) &&
    //        offer.grade == pricing.grade &&
    //        pricing.actual &&
    //        isInMinMaxRange(
    //            offer.factoringFee,
    //            pricing.minFactoringFee,
    //            pricing.maxFactoringFee
    //        ) &&
    //        isInMinMaxRange(
    //            offer.discount,
    //            pricing.minDiscountRange,
    //            pricing.maxDiscountRange
    //        ) &&
    //        offer.advancePercentage + offer.reservePercentage == 100000;
    //    }
    //
    //    // check that fund offer's state fits selected pricing table item
    //    function offerFundAllocateFitsPricingTableItem(
    //        OfferItemAdvanceAllocated memory offer,
    //        PricingTableItem memory pricing
    //    ) internal pure returns (bool) {
    //        return
    //        isInMinMaxRange(
    //            offer.actualAmount,
    //            pricing.minAmount,
    //            pricing.maxAmount
    //        ) &&
    //        offer.clientCreateDate > 0 &&
    //        offer.dueDate > offer.clientCreateDate;
    //        // TODO: what's more to check?
    //    }
    //
    //    // check for offer state doesn't goes down step-by-step
    //    function updateOfferStatus(uint256 _offerId, uint8 _newStatus) internal {
    //        require(
    //            _newStatus == offers[_offerId].status + 1,
    //            "Wrong status state"
    //        );
    //        offers[_offerId].status = _newStatus;
    //        emit OfferStatusUpdated(_offerId, _newStatus);
    //    }

    IPricingTable pricingTable;

    constructor(address pricingAddress) {
        pricingTable = IPricingTable(pricingAddress);
    }

    uint private countId;
    mapping(uint => bytes2) private OfferToPricingId;
    mapping(uint => OfferItem) public Offers;
    uint8 precision = 4;

    function createOffer(bytes2 pricingId, OfferParams memory params)
        public
        onlyOwner
        returns (uint)
    {
        require(
            pricingTable.isPricingItemValid(pricingId),
            "PricingItem not valid"
        );

        IPricingTable.PricingItem memory pricing;
        pricing = pricingTable.getPricingItem(pricingId);
        require(
            params.tenure >= pricing.minTenure &&
                params.tenure <= pricing.maxTenure,
            "Tenure not within range"
        );
        require(
            params.advanceFee <= pricing.maxAdvancedRatio,
            "Advance higher than max"
        );
        require(
            params.discountFee >= pricing.minDiscountFee,
            "Discount lower than min"
        );
        require(
            params.factoringFee >= pricing.minFactoringFee,
            "Factoring lower than min"
        );
        require(
            params.invoiceAmount >= pricing.minAmount &&
                params.invoiceAmount <= pricing.maxAmount,
            "Amount not within range"
        );
        require(
            params.invoiceAmount >= params.availableAmount,
            "Invoice amount > Available"
        );

        OfferItem memory offer;
        offer.advancedAmount =
            (params.availableAmount * params.advanceFee) /
            100;
        offer.reserve = (params.invoiceAmount - offer.advancedAmount);
        offer.disbursingAdvanceDate = block.timestamp;
        console.log("advancedAmount %s", offer.advancedAmount);
        console.log("reserve %s", offer.reserve);

        require((offer.advancedAmount + offer.reserve) == params.invoiceAmount);

        countId++;
        OfferToPricingId[countId] = pricingId;
        offer.params = params;
        Offers[countId] = offer;

        return countId;
    }

    //    //Buyer paymentDate
    //    //Buyer paymentRefNo
    //    //receivedAmount
    //    //unAppliedOrShortAmount
    //    //
    //    function offerPaymentReceived(
    //        uint offerId,
    //        uint paymentDate,
    //        uint receivedAmount,
    //        string paymentRef
    //    ) external onlyOwner {
    //        invoiceAmount - receivedAmount;
    //        //            offersPaymentsReceived[_id] = _offer;
    //        //            emit OfferPaymentReceived(_id, _offer);
    //    }

    // new state for offer - we ready to send trade tokens to user
    function offerReserveFundAllocated(
        uint offerId,
        uint dueDate,
        uint16 lateFee
    )
        public
        //        OfferItemRefunded memory _offer
        onlyOwner
    {
        OfferItem memory offer = Offers[offerId];
        //        offer.ad
        require(dueDate >= block.timestamp, "dueDate is invalid");
        uint numberOfLateDays = 3;
        //        block.timestamp - dueDate - offer.params.gracePeriod;
        uint lateAmount = (
            (((lateFee * offer.advancedAmount) / 365) * numberOfLateDays)
        );
        uint factoringAmount = (
            (offer.params.factoringFee * offer.params.invoiceAmount)
        );
        uint discountAmount = (
            (((offer.advancedAmount * offer.params.discountFee) / 365) *
                offer.params.tenure)
        );
        console.log("latedays: %s", numberOfLateDays);
        console.log("lateAmount: %s", lateAmount);
        console.log("factoring: %s", factoringAmount);
        console.log("discountAmount: %s", discountAmount);
        //        console.log('latedays: %s',numberOfLateDays);
        //            netAmount = ;
        //        offersFundsRefunded[_id] = _offer;
        //        emit OfferReserveFundAllocated(_id, _offer);
    }
    //
    //    // getter for external calls from treasury
    //    function getAmountsForTransfers(uint256 _id)
    //    external
    //    view
    //    returns (
    //        address,
    //        uint256,
    //        address
    //    )
    //    {
    //        return (
    //        offers[_id].tokenAddress,
    //        offersAdvancesAllocated[_id].advancedAmount * 10**15,
    //        offers[_id].offerAddress
    //        );
    //    }
    //
    //    function getAmountsForFinish(uint256 _id)
    //    external view
    //    returns (
    //        uint256,
    //        address
    //    )
    //    {
    //        return (
    //        offersFundsRefunded[_id].toPayTradeTokens * 10**15,
    //        offers[_id].offerAddress
    //        );
    //    }
    //
    //    // Treasury can move offer to new state
    //    function changeStatusFromTreasury(uint256 _id, uint8 status)
    //    external
    //    returns (bool)
    //    {
    //        require(msg.sender == _treasuryAddress, "Wrong treasury address");
    //        updateOfferStatus(_id, status);
    //        return true;
    //    }
    //
    //    //events
    //    event PricingTableSet(address oldAddress, address newAddress);
    //    event TreasuryAddressSet(address oldAddress, address newAddress);
    //    event OfferStatusUpdated(uint256 _id, uint256 newStatus);
    //    event NewOffer(uint256 _id);
    //
    //    event OfferFundAllocated(uint256 _id, OfferItemAdvanceAllocated _offer);
    //    event OfferPaymentReceived(uint256 _id, OfferItemPaymentReceived _offer);
    //    event OfferReserveFundAllocated(uint256 _id, OfferItemRefunded _offer);
}
