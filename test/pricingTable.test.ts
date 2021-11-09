import { expect } from "chai";
import { ethers } from "hardhat";
import { Offers, PricingTable } from "../typechain";
import { ONE_DAY } from "./helpers";

describe("PricingTable", function () {
  let pricingTable: PricingTable;
  let offers: Offers;
  let timestamp: number;
  beforeEach(async () => {
    timestamp = (await ethers.provider.getBlock(ethers.provider.blockNumber))
      .timestamp;
    console.log(timestamp);
  });

  it("Should return the new greeting once it's changed", async function () {
    const PricingTable = await ethers.getContractFactory("PricingTable");
    pricingTable = await PricingTable.deploy();
    await pricingTable.deployed();
  });

  it("Should add a pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x606A", 20, 60, 90, 65, 12, 5000, 10000)
      .then((tx) => tx.wait());
  });

  it("Should add a pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x01A2", 1, 1, 1, 1, 1, 1, 1)
      .then((tx) => tx.wait());
  });

  it("Should add a pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x57A2", 60, 90, 9000, 375, 105, 8000000, 10000000)
      .then((tx) => tx.wait());
  });

  it("Should add a pricing Item", async () => {
    await pricingTable
      .addPricingItem("0x41A2", 60, 89, 9000, 700, 173, 500000, 1000000)
      .then((tx) => tx.wait());
  });

  it("Should return a pricingItem", async () => {
    const pricingItem = await pricingTable.getPricingItem("0x01a2");

    expect(pricingItem.minTenure).to.equal(1);
    expect(pricingItem.maxTenure).to.equal(1);
    expect(pricingItem.maxAdvancedRatio).to.equal(1);
    expect(pricingItem.minDiscountFee).to.equal(1);
    expect(pricingItem.minFactoringFee).to.equal(1);
    expect(pricingItem.minAmount).to.equal(1);
    expect(pricingItem.maxAmount).to.equal(1);
  });

  it("Should remove a pricingItem", async () => {
    await pricingTable.removePricingItem("0x01a2");
  });

  it("Should remove 0 if pricingItem has been deleted", async () => {
    const pricingItem = await pricingTable.getPricingItem("0x01a2");
    expect(pricingItem.minTenure).to.equal(0);
    expect(pricingItem.maxTenure).to.equal(0);
    expect(pricingItem.maxAdvancedRatio).to.equal(0);
    expect(pricingItem.minDiscountFee).to.equal(0);
    expect(pricingItem.minFactoringFee).to.equal(0);
    expect(pricingItem.minAmount).to.equal(0);
  });

  it("Should deploy Offer Contract", async () => {
    const Offers = await ethers.getContractFactory("Offers");
    offers = await Offers.deploy(pricingTable.address);
    await offers.deployed();

    await offers.createOffer("0x606a", {
      advanceFee: 90,
      discountFee: 75,
      factoringFee: 20,
      gracePeriod: 1,
      availableAmount: 9000,
      invoiceAmount: 9000,
      tenure: 60,
      // tokenAddress: "0x2e3c1bAe5D365D1dcd0EaC91B00d54518717Ee06",
    });

    console.log((await offers.Offers(1)).toString());

    const date = Math.floor(Date.now() / 1000);
    await offers.reserveRefund(1, date + 60 * 60, 2);
  });

  it("Should create second Offer with Invoice == Available", async () => {
    await offers.createOffer("0x57A2", {
      advanceFee: 8800,
      discountFee: 390,
      factoringFee: 135,
      gracePeriod: 1,
      availableAmount: 8934578, // 89345.78
      invoiceAmount: 8934578, // 89345.78
      tenure: 79,
      // tokenAddress: "0x2e3c1bAe5D365D1dcd0EaC91B00d54518717Ee06",
    });

    console.log((await offers.Offers(1)).toString());

    const date = Math.floor(Date.now() / 1000);
    await offers.reserveRefund(2, date + 60 * 60, 2);
  });

  it("Should create second Offer with Invoice != Available", async () => {
    console.log("------");
    console.log("------");
    console.log("------");
    await offers.createOffer("0x41A2", {
      advanceFee: 8000,
      discountFee: 750,
      factoringFee: 180,
      gracePeriod: 2,
      invoiceAmount: 1000000, // 89345.78
      availableAmount: 900000, // 89345.78
      tenure: 60,
      // tokenAddress: "0x2e3c1bAe5D365D1dcd0EaC91B00d54518717Ee06",
    });
    const date = Math.floor(Date.now() / 1000);

    await offers.reserveRefund(3, date - 24 * 60 * 60 * 10, 2750);
  });
  // 89345.78;
});
