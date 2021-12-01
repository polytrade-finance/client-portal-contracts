## `IPricingTable`

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

### `NewPricingItem(struct IPricingTable.PricingItem id)`

### `UpdatedPricingItem(struct IPricingTable.PricingItem id)`

### `RemovedPricingItem(bytes2 id)`

### `PricingItem`

uint8 minTenure

uint8 maxTenure

uint16 maxAdvancedRatio

uint16 minDiscountFee

uint16 minFactoringFee

uint256 minAmount

uint256 maxAmount
