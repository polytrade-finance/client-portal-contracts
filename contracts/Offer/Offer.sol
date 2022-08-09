// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IOffer.sol";
import "../ILenderPool.sol";
import "../PricingTable/IPricingTable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Offer
/// @author Polytrade
contract Offers is IOffer, Ownable {
    using SafeERC20 for IERC20;

    IPricingTable public pricingTable;

    uint private _countId;
    uint16 private constant _PRECISION = 1E4;

    uint public totalAdvanced;
    uint public totalRefunded;

    address public treasury;
    address public treasuryManager;

    mapping(uint => uint16) private _offerToPricingId;
    mapping(uint => OfferItem) public offers;
    mapping(address => address) public stableToPool;

    constructor(address pricingTableAddress, address treasuryAddress) {
        require(
            pricingTableAddress != address(0) && treasuryAddress != address(0)
        );
        pricingTable = IPricingTable(pricingTableAddress);
        treasury = treasuryAddress;
        treasuryManager = _msgSender();
    }

    /**
     * @dev Set PricingTable linked to the contract to a new PricingTable (`pricingTable`)
     * Can only be called by the owner
     */
    function setPricingTableAddress(address _newPricingTable)
        external
        onlyOwner
    {
        require(_newPricingTable != address(0));
        address oldPricingTable = address(pricingTable);
        pricingTable = IPricingTable(_newPricingTable);
        emit NewPricingTableContract(oldPricingTable, _newPricingTable);
    }

    /**
     * @dev Set TreasuryAddress linked to the contract to a new treasuryAddress
     * Can only be called by the owner
     */
    function setTreasuryAddress(address _newTreasury) external {
        require(_msgSender() == treasuryManager, "Not treasuryManager");
        require(_newTreasury != address(0));
        address oldTreasury = treasury;
        treasury = _newTreasury;
        emit NewTreasuryAddress(oldTreasury, _newTreasury);
    }

    /**
     * @dev Set TreasuryManager linked to the contract to a new treasuryManager
     * Can only be called by the owner
     */
    function setTreasuryManager(address _newTreasuryManager) external {
        require(_msgSender() == treasuryManager, "Not treasuryManager");
        require(_newTreasuryManager != address(0));
        address oldTreasuryManager = treasury;
        treasuryManager = _newTreasuryManager;
        emit NewTreasuryManager(oldTreasuryManager, _newTreasuryManager);
    }

    /**
     * @dev Set LenderPoolAddress linked to the contract to a new lenderPoolAddress
     * Can only be called by the owner
     */
    function setLenderPoolAddress(
        address stableAddress,
        address lenderPoolAddress
    ) external onlyOwner {
        require(stableAddress != address(0) && lenderPoolAddress != address(0));
        stableToPool[stableAddress] = lenderPoolAddress;
        emit StableMappedToLenderPool(stableAddress, lenderPoolAddress);
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
    function checkOfferValidity(
        uint16 pricingId,
        uint16 tenure,
        uint16 advanceFee,
        uint16 discountFee,
        uint16 factoringFee,
        uint invoiceAmount,
        uint availableAmount
    ) external view returns (bool) {
        return
            _checkParams(
                pricingId,
                tenure,
                advanceFee,
                discountFee,
                factoringFee,
                invoiceAmount,
                availableAmount
            );
    }

    /**
     * @notice Create an offer, check if it fits pricingItem requirements and send Advance to treasury
     * @dev calls _checkParams and returns Error if params don't fit with the pricingID
     * @dev only `Owner` can create a new offer
     * @dev emits OfferCreated event
     * @dev send Advance Amount to treasury
     * @param pricingId, Id of the pricing Item
     * @param advanceFee;
     * @param discountFee;
     * @param factoringFee;
     * @param gracePeriod;
     * @param availableAmount;
     * @param invoiceAmount;
     * @param tenure;
     * @param stableAddress;
     */
    function createOffer(
        uint16 pricingId,
        uint16 advanceFee,
        uint16 discountFee,
        uint16 factoringFee,
        uint8 gracePeriod,
        uint invoiceAmount,
        uint availableAmount,
        uint16 tenure,
        address stableAddress
    ) public onlyOwner returns (uint) {
        require(
            stableToPool[stableAddress] != address(0),
            "Stable Address not whitelisted"
        );
        require(
            _checkParams(
                pricingId,
                tenure,
                advanceFee,
                discountFee,
                factoringFee,
                invoiceAmount,
                availableAmount
            ),
            "Invalid offer parameters"
        );

        OfferItem memory offer;
        offer.advancedAmount = _calculateAdvancedAmount(
            availableAmount,
            advanceFee
        );

        offer.reserve = (invoiceAmount - offer.advancedAmount);
        offer.disbursingAdvanceDate = uint64(block.timestamp);

        _countId++;
        _offerToPricingId[_countId] = pricingId;
        offer.params = OfferParams({
            gracePeriod: gracePeriod,
            tenure: tenure,
            factoringFee: factoringFee,
            discountFee: discountFee,
            advanceFee: advanceFee,
            stableAddress: stableAddress,
            invoiceAmount: invoiceAmount,
            availableAmount: availableAmount
        });
        offers[_countId] = offer;

        IERC20 stable = IERC20(stableAddress);
        uint8 decimals = IERC20Metadata(address(stable)).decimals();

        uint amount = offers[_countId].advancedAmount * (10**(decimals - 2));

        totalAdvanced += amount;

        ILenderPool(stableToPool[address(stable)]).requestFundInvoice(amount);

        stable.safeTransferFrom(
            stableToPool[address(stable)],
            treasury,
            amount
        );

        emit OfferCreated(_countId, pricingId);
        return _countId;
    }

    /**
     * @notice Send the reserve Refund to the treasury
     * @dev checks if Offer exists and if not refunded yet
     * @dev only `Owner` can call reserveRefund
     * @dev emits OfferReserveRefunded event
     * @param offerId, Id of the offer
     * @param dueDate, due date
     * @param lateFee, late fees (ratio)
     */
    function reserveRefund(
        uint offerId,
        uint64 dueDate,
        uint16 lateFee
    ) public onlyOwner {
        require(
            _offerToPricingId[offerId] != 0 &&
                offers[offerId].refunded.netAmount == 0,
            "Invalid Offer"
        );

        OfferItem memory offer = offers[offerId];
        OfferRefunded memory refunded;

        refunded.lateFee = lateFee;
        refunded.dueDate = dueDate;

        uint lateAmount = 0;
        if (block.timestamp > (dueDate + offer.params.gracePeriod)) {
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

        IERC20 stable = IERC20(offer.params.stableAddress);
        uint8 decimals = IERC20Metadata(address(stable)).decimals();

        uint amount = offers[offerId].refunded.netAmount * (10**(decimals - 2));

        totalRefunded += amount;

        ILenderPool(stableToPool[address(stable)]).requestFundInvoice(amount);

        stable.safeTransferFrom(
            stableToPool[address(stable)],
            treasury,
            amount
        );

        emit ReserveRefunded(offerId, amount);
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
        uint16 pricingId,
        uint16 tenure,
        uint16 advanceFee,
        uint16 discountFee,
        uint16 factoringFee,
        uint invoiceAmount,
        uint availableAmount
    ) private view returns (bool) {
        require(pricingTable.isPricingItemValid(pricingId));
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
     * @notice calculate the number of Late Days (Now - dueDate - gracePeriod)
     * @dev calculate based on `(block.timestamp - dueDate - gracePeriod) / 1 days` formula
     * @param dueDate, due date -> epoch timestamps format
     * @param gracePeriod, grace period -> expressed in seconds
     * @return uint24, number of late Days
     */
    function _calculateLateDays(uint dueDate, uint gracePeriod)
        private
        view
        returns (uint24)
    {
        return uint24(block.timestamp - dueDate - gracePeriod) / 1 days;
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
        pure
        returns (uint)
    {
        return (availableAmount * advanceFee) / _PRECISION;
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
        pure
        returns (uint)
    {
        return (invoiceAmount * factoringFee) / _PRECISION;
    }

    /**
     * @notice calculate the Discount Amount ((advancedAmount * discountFee) / 365) * tenure)
     * @dev calculate based on `((advancedAmount * discountFee) / 365) * tenure) / _precision` formula
     * @param advancedAmount, amount for the advanced amount
     * @param discountFee, ratio for the discount Fee
     * @param tenure, tenure
     * @return uint amount of the Discount
     */
    function _calculateDiscountAmount(
        uint advancedAmount,
        uint16 discountFee,
        uint16 tenure
    ) private pure returns (uint) {
        return (((advancedAmount * discountFee)) * tenure) / 365 / _PRECISION;
    }

    /**
     * @notice calculate the Late Amount (((lateFee * advancedAmount) / 365) * lateDays)
     * @dev calculate based on `(((lateFee * advancedAmount) / 365) * lateDays) / _precision` formula
     * @param advancedAmount, amount for the advanced amount
     * @param lateFee, ratio for the late Fee
     * @param lateDays, number of late days
     * @return uint, Late Amount
     */
    function _calculateLateAmount(
        uint advancedAmount,
        uint16 lateFee,
        uint24 lateDays
    ) private pure returns (uint) {
        return (((lateFee * advancedAmount) / 365) * lateDays) / _PRECISION;
    }
}
