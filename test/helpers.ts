import { ethers } from "hardhat";
import { BigNumber, utils } from "ethers";

export const ONE_DAY = 24 * 60 * 60;

export function n18(amount: string): BigNumber {
  return utils.parseUnits(amount, "ether");
}

export async function increaseTime(duration: number) {
  await ethers.provider.send("evm_increaseTime", [duration]);
  await ethers.provider.send("evm_mine", []);
}
