## `Offers`

### `constructor(address pricingAddress)` (public)

### `createOffer(bytes2 pricingId, struct OfferParams params) → uint256` (public)

Create an offer, check if it fits pricingItem requirements

calls _checkParams and returns Error if params don't fit with the pricingID
only `Owner` can create a new offer
emits OfferCreated event

### `reserveRefund(uint256 offerId, uint256 dueDate, uint16 lateFee)` (public)

Send the reserve Refund

checks if Offer exists and if not refunded yet
only `Owner` can call reserveRefund
emits OfferReserveRefunded event
