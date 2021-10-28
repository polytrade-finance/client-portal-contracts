import { ethers } from "hardhat";
import { BigNumber, utils } from "ethers";

function n18(amount: string): BigNumber {
  return utils.parseUnits(amount, "ether");
}

async function increaseTime(duration: number) {
  await ethers.provider.send("evm_increaseTime", [duration]);
  await ethers.provider.send("evm_mine", []);
}

module.exports = {
  n18,
  increaseTime,
};
