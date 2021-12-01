# Polytrade - Smart contracts - Solidity

## `PricingTable`

### `addPricingItem(bytes2 pricingId, uint8 minTenure, uint8 maxTenure, uint16 maxAdvancedRatio, uint16 minDiscountRange, uint16 minFactoringFee, uint256 minAmount, uint256 maxAmount)` (external)

Add a Pricing Item to the Pricing Table

Only Owner is authorized to add a Pricing Item

### `updatePricingItem(bytes2 pricingId, uint8 minTenure, uint8 maxTenure, uint16 maxAdvancedRatio, uint16 minDiscountRange, uint16 minFactoringFee, uint256 minAmount, uint256 maxAmount, bool status)` (external)

Add a Pricing Item to the Pricing Table

Only Owner is authorized to add a Pricing Item

### `removePricingItem(bytes2 id)` (external)

Remove a Pricing Item from the Pricing Table

Only Owner is authorized to add a Pricing Item

### `getPricingItem(bytes2 id) → struct IPricingTable.PricingItem` (external)

Returns the pricing Item

### `isPricingItemValid(bytes2 id) → bool` (external)

Returns if the pricing Item is valid

## `Offers`

### `constructor(address pricingAddress)` (public)

### `createOffer(bytes2 pricingId, struct OfferParams params) → uint256` (public)

Create an offer, check if it fits pricingItem requirements

calls \_checkParams and returns Error if params don't fit with the pricingID
only `Owner` can create a new offer
emits OfferCreated event

### `reserveRefund(uint256 offerId, uint256 dueDate, uint16 lateFee)` (public)

Send the reserve Refund

checks if Offer exists and if not refunded yet
only `Owner` can call reserveRefund
emits OfferReserveRefunded event
