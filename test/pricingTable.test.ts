import { expect } from "chai";
import { ethers } from "hardhat";
import { Offers, PricingTable } from "../typechain";

describe("PricingTable", function () {
  let pricingTable: PricingTable;
  let offers: Offers;
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

  it("Should return a pricingItem", async () => {
    const pricingItem = await pricingTable.getPricingItem("0x01a2");

    expect(pricingItem.minTenure).to.equal(1);
    expect(pricingItem.maxTenure).to.equal(1);
    expect(pricingItem.maxAdvancedRatio).to.equal(1);
    expect(pricingItem.minDiscountFee).to.equal(1);
    expect(pricingItem.minFactoringFee).to.equal(1);
    expect(pricingItem.minAmount).to.equal(1);
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
    await offers.offerReserveFundAllocated(1, date + 60 * 60, 2);
  });
});
