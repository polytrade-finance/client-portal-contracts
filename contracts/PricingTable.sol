// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPricingTable.sol";
import "hardhat/console.sol";

contract PricingTable is IPricingTable, Ownable {
    mapping(uint => PricingItem) private pricingTable;

    uint private pricingCount;
    uint private constant PRECISION = 6;

    // getter for one pricing table item
    function getPricingTableItem(uint _id)
        external
        view
        returns (PricingItem memory)
    {
        return pricingTable[_id];
    }

    // add new pricing table item to storage
    function addPricingItem(
        uint minAdvancedRatio,
        uint maxAdvancedRatio,
        uint minDiscountRange,
        uint maxDiscountRange,
        uint minFactoringFee,
        uint maxFactoringFee
    ) external onlyOwner returns (uint) {
        require(
            _checkRange(minAdvancedRatio) &&
                _checkRange(maxAdvancedRatio) &&
                _checkRange(minDiscountRange) &&
                _checkRange(maxDiscountRange) &&
                _checkRange(minFactoringFee) &&
                _checkRange(maxFactoringFee),
            "Wrong Pricing"
        );
        pricingCount++;
        console.log("%s", pricingCount);
        pricingTable[pricingCount];
        //        pricingTable[pricingCount]
        //        emit NewPricingItem(pricingCount);
        return pricingCount;
    }

    // deprecate pricing table item
    function deprecatePricingTableItem(uint _id)
        external
        onlyOwner
        returns (bool)
    {
        //        pricingTable[_id].actual = false;
        //        emit PricingDeprecated(_id);
        return true;
    }

    function _checkRange(uint amount) private pure returns (bool) {
        return amount > 0 && amount <= 100000;
    }
}
