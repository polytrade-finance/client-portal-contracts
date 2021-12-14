// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IPriceFeedUSDC {
    function getPrice() external view returns (uint);

    function getDecimals() external view returns (uint);
}
