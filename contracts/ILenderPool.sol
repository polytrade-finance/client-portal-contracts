// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface ILenderPool {
    function requestFundInvoice(uint amount) external;
}
