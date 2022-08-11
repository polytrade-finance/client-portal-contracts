// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// NOT FOR PROD
contract LenderPool {
    IERC20 public immutable stable;
    address public immutable treasury;

    constructor(address _token, address _treasury) {
        stable = IERC20(_token);
        treasury = _treasury;
    }

    function requestFundInvoice(uint amount) external {
        stable.approve(address(treasury), amount);
    }
}
