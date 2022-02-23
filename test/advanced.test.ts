import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Offers, PricingTable, Token } from "../typechain";
import { getTimestamp, increaseTime, ONE_DAY } from "./helpers";
import { parseUnits } from "ethers/lib/utils";
import { constants } from "ethers";

describe("PricingTable", function () {
  let pricingTable: PricingTable;
  let offers: Offers;
  let usdcContract: Token;
  let decimals: number;
  let timestamp: number;
  let accounts: SignerWithAddress[];
  let addresses: string[];
  let treasury: string;
  let lenderPool: string;

  before(async () => {
    accounts = await ethers.getSigners();
    addresses = accounts.map((account: SignerWithAddress) => account.address);
    treasury = addresses[2];
    lenderPool = addresses[8];
    decimals = 8;
  });

  beforeEach(async () => {
    timestamp = await getTimestamp();
    if (usdcContract) {
      await usdcContract
        .connect(accounts[2])
        .transfer(addresses[1], await usdcContract.balanceOf(treasury));
    }
  });

  describe("Advanced Test", () => {
    it("Should return the new PrincingTable once deployed", async function () {
      const PricingTable = await ethers.getContractFactory("PricingTable");
      pricingTable = await PricingTable.deploy();
      await pricingTable.deployed();
    });

    it("Should add 606A pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x606A", 0, 10, 90, 65, 12, 5000, 10000)
        .then((tx) => tx.wait());
    });

    it("Should fail add existing pricing Item", async () => {
      await expect(
        pricingTable.addPricingItem("0x606A", 0, 10, 90, 65, 12, 5000, 10000)
      ).to.be.revertedWith("Already exists, please update");
    });

    it("Should check 606A before update", async () => {
      const pricingItem = await pricingTable.getPricingItem("0x606A");
      expect(pricingItem.minTenure).to.equal(0);
    });

    it("Should update 606A pricing Item", async () => {
      await pricingTable
        .updatePricingItem("0x606A", 1, 10, 90, 65, 12, 5000, 10000, true)
        .then((tx) => tx.wait());
    });

    it("Should check if 606A has been updated", async () => {
      const pricingItem = await pricingTable.getPricingItem("0x606A");
      expect(pricingItem.minTenure).to.equal(1);
    });

    it("Should check if 606A is valid pricing Item", async () => {
      expect(await pricingTable.isPricingItemValid("0x606A")).to.equal(true);
    });

    it("Should remove 606A pricing Item", async () => {
      await pricingTable.removePricingItem("0x606A").then((tx) => tx.wait());
    });

    it("Should fail update inexisting pricing Item", async () => {
      await expect(
        pricingTable.updatePricingItem(
          "0x606A",
          0,
          10,
          90,
          65,
          12,
          5000,
          10000,
          true
        )
      ).to.be.revertedWith("Invalid Pricing Item");
    });

    it("Should check if 606A is invalid pricing Item", async () => {
      expect(await pricingTable.isPricingItemValid("0x606A")).to.equal(false);
    });

    it("Should add 606A pricing Item again", async () => {
      await pricingTable
        .addPricingItem("0x606A", 20, 60, 90, 65, 12, 5000, 10000)
        .then((tx) => tx.wait());
    });

    it("Should add 01A2 pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x01A2", 1, 1, 1, 1, 1, 1, 1)
        .then((tx) => tx.wait());
    });

    it("Should add 57A2 pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x57A2", 60, 90, 9000, 375, 105, 8000000, 10000000)
        .then((tx) => tx.wait());
    });

    it("Should add 41A2 pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x41A2", 60, 89, 9000, 700, 173, 500000, 1000000)
        .then((tx) => tx.wait());
    });

    it("Should add 643A pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x643A", 30, 59, 9000, 375, 70, 8000100, 10000000)
        .then((tx) => tx.wait());
    });

    it("Should add 684B pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x684B", 90, 119, 9000, 400, 20, 8000100, 10000000)
        .then((tx) => tx.wait());
    });

    it("Should add 624B pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x624B", 20, 29, 9000, 400, 50, 8000100, 10000000)
        .then((tx) => tx.wait());
    });

    it("Should add 647A pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x647A", 60, 89, 9000, 700, 173, 500000, 1000000)
        .then((tx) => tx.wait());
    });

    it("Should add 668B pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x668B", 90, 119, 9000, 750, 200, 500000, 1000000)
        .then((tx) => tx.wait());
    });

    it("Should add 689C pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x689C", 120, 180, 9000, 800, 227, 500000, 1000000)
        .then((tx) => tx.wait());
    });

    it("Should add 629C pricing Item", async () => {
      await pricingTable
        .addPricingItem("0x629C", 30, 59, 9000, 800, 160, 500000, 1000000)
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

    it("Should return USDC once deployed", async function () {
      const USDC = await ethers.getContractFactory("Token");
      usdcContract = await USDC.deploy("USD Coin", "USDC", decimals);
      await usdcContract.deployed();
    });

    it("Should fail deploying Offer Contract", async () => {
      const Offers = await ethers.getContractFactory("Offers");
      await expect(Offers.deploy(ethers.constants.AddressZero, treasury)).to.be
        .reverted;
    });

    it("Should deploy Offer Contract", async () => {
      const Offers = await ethers.getContractFactory("Offers");
      offers = await Offers.deploy(pricingTable.address, treasury);
      await offers.deployed();
    });

    it("Should set stable to lender address", async () => {
      await offers.setLenderPoolAddress(usdcContract.address, lenderPool);
    });

    it("Should fail set stable to lender address", async () => {
      await expect(
        offers.setLenderPoolAddress(constants.AddressZero, lenderPool)
      ).to.be.reverted;
    });

    it("Should fail setting pricingTable to address(0)", async () => {
      await expect(offers.setPricingTableAddress(constants.AddressZero)).to.be
        .reverted;
    });

    it("Should set pricingTable to address(1)", async () => {
      await offers.setPricingTableAddress(
        "0x0000000000000000000000000000000000000001"
      );
      expect(await offers.pricingTable()).to.equal(
        "0x0000000000000000000000000000000000000001"
      );
    });

    it("Should set pricingTable to previous PricingTable", async () => {
      await offers.setPricingTableAddress(pricingTable.address);
      expect(await offers.pricingTable()).to.equal(pricingTable.address);
    });

    it("Should set treasury to address(0)", async () => {
      await expect(offers.setTreasuryAddress(constants.AddressZero)).to.be
        .reverted;
    });

    it("Should set treasury to address(1)", async () => {
      await offers.setTreasuryAddress(
        "0x0000000000000000000000000000000000000001"
      );
      expect(await offers.treasury()).to.equal(
        "0x0000000000000000000000000000000000000001"
      );
    });

    it("Should set treasury to previous treasury", async () => {
      await offers.setTreasuryAddress(treasury);
      expect(await offers.treasury()).to.equal(treasury);
    });

    it("Should send 100,000,000 USDT to Offer Contract", async () => {
      await usdcContract.transfer(lenderPool, parseUnits("1000000", decimals));
      expect(await usdcContract.balanceOf(lenderPool)).to.equal(
        parseUnits("1000000", decimals)
      );

      await usdcContract
        .connect(accounts[8])
        .approve(offers.address, constants.MaxUint256);
    });

    it("Should check validity of the offer", async () => {
      expect(
        await offers.checkOfferValidity("0x606a", 60, 90, 75, 20, 9000, 9000)
      ).to.equal(true);
    });

    it("Should fail checking validity on wrong pricing Id", async () => {
      await expect(
        offers.checkOfferValidity("0x6099", 60, 90, 75, 20, 9000, 9000)
      ).to.be.reverted;
    });

    it("Should fail creating the first offer if stable not registered", async () => {
      await expect(
        offers.createOffer(
          "0x606a",
          90,
          75,
          20,
          1,
          9000,
          9000,
          60,
          addresses[1]
        )
      ).to.be.revertedWith("Stable Address not whitelisted");
    });

    it("Should create first offer", async () => {
      await offers.createOffer(
        "0x606a",
        90,
        75,
        20,
        1,
        9000,
        9000,
        60,
        usdcContract.address
      );
      const date = Math.floor(Date.now() / 1000);
      await offers.reserveRefund(1, date + 60 * 60, 2);

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("89.82", decimals)
      );
    });

    it("Should create Offer(2) scenario 1 grade A with Invoice == Available", async (offerId: number = 2) => {
      await offers.createOffer(
        "0x57A2",
        8800,
        390,
        135,
        1,
        8934578,
        8934578,
        79,
        usdcContract.address
      );

      const offer = await offers.offers(offerId);
      expect(offer.advancedAmount).to.equal("7862428");
      expect(offer.reserve).to.equal("1072150");
      expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

      expect(offer.params.gracePeriod).to.equal(1);
      expect(offer.params.tenure).to.equal(79);
      expect(offer.params.factoringFee).to.equal(135);
      expect(offer.params.discountFee).to.equal(390);
      expect(offer.params.advanceFee).to.equal(8800);
      expect(offer.params.invoiceAmount).to.equal("8934578");
      expect(offer.params.availableAmount).to.equal("8934578");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("78624.28", decimals)
      );
    });

    it("Should reserveRefund for Offer(2) scenario 1 grade A with Invoice == Available", async (offerId: number = 2) => {
      await offers.reserveRefund(offerId, timestamp, 0);
      const offer = await offers.offers(offerId);
      expect(offer.refunded.dueDate).to.equal(timestamp);
      expect(offer.refunded.lateFee).to.equal(0);
      expect(offer.refunded.numberOfLateDays).to.equal(0);
      expect(offer.refunded.totalCalculatedFees).to.equal("186983");
      expect(offer.refunded.netAmount).to.equal("885167");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("8851.67", decimals)
      );
    });

    it("Should create Offer(3) scenario 2 grade A with Invoice == Available", async (offerId: number = 3) => {
      await offers.createOffer(
        "0x643A",
        8500,
        375,
        80,
        1,
        8934578,
        8934578,
        45,
        usdcContract.address
      );

      const offer = await offers.offers(offerId);
      expect(offer.advancedAmount).to.equal("7594391");
      expect(offer.reserve).to.equal("1340187");
      expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

      expect(offer.params.gracePeriod).to.equal(1);
      expect(offer.params.tenure).to.equal(45);
      expect(offer.params.factoringFee).to.equal(80);
      expect(offer.params.discountFee).to.equal(375);
      expect(offer.params.advanceFee).to.equal(8500);
      expect(offer.params.invoiceAmount).to.equal("8934578");
      expect(offer.params.availableAmount).to.equal("8934578");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("75943.91", decimals)
      );
    });

    it("Should reserveRefund for Offer(3) scenario 2 grade A with Invoice == Available", async (offerId: number = 3) => {
      await offers.reserveRefund(offerId, timestamp, 0);
      const offer = await offers.offers(offerId);
      expect(offer.refunded.dueDate).to.equal(timestamp);
      expect(offer.refunded.lateFee).to.equal(0);
      expect(offer.refunded.numberOfLateDays).to.equal(0);
      expect(offer.refunded.totalCalculatedFees).to.equal("106587");
      expect(offer.refunded.netAmount).to.equal("1233600");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("12336.0", decimals)
      );
    });

    it("Should create Offer(4) scenario 3 grade B with Invoice == Available", async (offerId: number = 4) => {
      await offers.createOffer(
        "0x684B",
        7000,
        445,
        256,
        1,
        8934578,
        8934578,
        100,
        usdcContract.address
      );

      const offer = await offers.offers(offerId);
      expect(offer.advancedAmount).to.equal("6254204");
      expect(offer.reserve).to.equal("2680374");
      expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

      expect(offer.params.gracePeriod).to.equal(1);
      expect(offer.params.tenure).to.equal(100);
      expect(offer.params.factoringFee).to.equal(256);
      expect(offer.params.discountFee).to.equal(445);
      expect(offer.params.advanceFee).to.equal(7000);
      expect(offer.params.invoiceAmount).to.equal("8934578");
      expect(offer.params.availableAmount).to.equal("8934578");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("62542.04", decimals)
      );
    });

    it("Should reserveRefund Offer(4) scenario 3 grade B with Invoice == Available", async (offerId: number = 4) => {
      await offers.reserveRefund(offerId, timestamp, 0);
      const offer = await offers.offers(offerId);
      expect(offer.refunded.dueDate).to.equal(timestamp);
      expect(offer.refunded.lateFee).to.equal(0);
      expect(offer.refunded.numberOfLateDays).to.equal(0);
      expect(offer.refunded.totalCalculatedFees).to.equal("304974");
      expect(offer.refunded.netAmount).to.equal("2375400");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("23754.0", decimals)
      );
    });

    it("Should fail creating Offer(5) scenario 4 grade B with Invoice == Available", async () => {
      await expect(
        offers.createOffer(
          "0x624B",
          7200,
          430,
          40,
          1,
          8934578,
          8934578,
          22,
          usdcContract.address
        )
      ).to.be.revertedWith("InvalidFactoringFee(40, 50)");
    });

    it("Should create Offer(5) scenario 1 grade B with Invoice != Available", async (offerId: number = 5) => {
      await offers.createOffer(
        "0x647A",
        8000,
        750,
        180,
        2,
        1000000,
        900000,
        60,
        usdcContract.address
      );

      const offer = await offers.offers(offerId);
      expect(offer.advancedAmount).to.equal("720000");
      expect(offer.reserve).to.equal("280000");
      expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

      expect(offer.params.gracePeriod).to.equal(2);
      expect(offer.params.tenure).to.equal(60);
      expect(offer.params.factoringFee).to.equal(180);
      expect(offer.params.discountFee).to.equal(750);
      expect(offer.params.advanceFee).to.equal(8000);
      expect(offer.params.invoiceAmount).to.equal("1000000");
      expect(offer.params.availableAmount).to.equal("900000");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("7200.0", decimals)
      );
    });

    it("Should reserveRefund for Offer(5) scenario 1 grade B with Invoice != Available", async (offerId: number = 5) => {
      const now = timestamp;

      await increaseTime(ONE_DAY * 8);
      await offers.reserveRefund(offerId, now, 2750);
      const offer = await offers.offers(offerId);
      expect(offer.refunded.dueDate).to.equal(timestamp);
      expect(offer.refunded.lateFee).to.equal(2750);
      expect(offer.refunded.numberOfLateDays).to.equal(8);
      expect(offer.refunded.totalCalculatedFees).to.equal("31215");
      expect(offer.refunded.netAmount).to.equal("248785");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("2487.85", decimals)
      );
    });

    it("Should create Offer(6) scenario 2 grade B with Invoice != Available", async (offerId: number = 6) => {
      await offers.createOffer(
        "0x668B",
        8900,
        800,
        253,
        6,
        1000000,
        900000,
        95,
        usdcContract.address
      );
      const offer = await offers.offers(offerId);
      expect(offer.advancedAmount).to.equal("801000");
      expect(offer.reserve).to.equal("199000");
      expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

      expect(offer.params.gracePeriod).to.equal(6);
      expect(offer.params.tenure).to.equal(95);
      expect(offer.params.factoringFee).to.equal(253);
      expect(offer.params.discountFee).to.equal(800);
      expect(offer.params.advanceFee).to.equal(8900);
      expect(offer.params.invoiceAmount).to.equal("1000000");
      expect(offer.params.availableAmount).to.equal("900000");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("8010.0", decimals)
      );
    });

    it("Should reserveRefund for Offer(6) scenario 1 grade B with Invoice != Available", async (offerId: number = 6) => {
      await offers.reserveRefund(offerId, timestamp + ONE_DAY * 10, 2750);
      const offer = await offers.offers(offerId);
      expect(offer.refunded.dueDate).to.equal(timestamp + ONE_DAY * 10);
      expect(offer.refunded.lateFee).to.equal(2750);
      expect(offer.refunded.numberOfLateDays).to.equal(0);
      expect(offer.refunded.totalCalculatedFees).to.equal("41978");
      expect(offer.refunded.netAmount).to.equal("157022");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("1570.22", decimals)
      );
    });

    it("Should fail create Offer scenario 3 grade C with InvalidDiscountFee", async () => {
      await expect(
        offers.createOffer(
          "0x689C",
          7200,
          730,
          227,
          5,
          1000000,
          900000,
          120,
          usdcContract.address
        )
      ).to.be.revertedWith("InvalidDiscountFee(730, 800)");
    });

    it("Should create Offer(7) scenario 4 grade C with Invoice != Available", async (offerId: number = 7) => {
      await offers.createOffer(
        "0x629C",
        9000,
        820,
        195,
        9,
        1000000,
        900000,
        30,
        usdcContract.address
      );

      const offer = await offers.offers(offerId);
      expect(offer.advancedAmount).to.equal("810000");
      expect(offer.reserve).to.equal("190000");
      expect(offer.disbursingAdvanceDate).to.be.above(timestamp);

      expect(offer.params.gracePeriod).to.equal(9);
      expect(offer.params.tenure).to.equal(30);
      expect(offer.params.factoringFee).to.equal(195);
      expect(offer.params.discountFee).to.equal(820);
      expect(offer.params.advanceFee).to.equal(9000);
      expect(offer.params.invoiceAmount).to.equal("1000000");
      expect(offer.params.availableAmount).to.equal("900000");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("8100.0", decimals)
      );
    });

    it("Should reserveRefund for Offer(7) scenario 4 grade C with Invoice != Available", async (offerId: number = 7) => {
      await offers.reserveRefund(offerId, timestamp + 9 * ONE_DAY, 2750);
      const offer = await offers.offers(offerId);
      expect(offer.refunded.dueDate).to.equal(timestamp + 9 * ONE_DAY);
      expect(offer.refunded.lateFee).to.equal(2750);
      expect(offer.refunded.numberOfLateDays).to.equal(0);
      expect(offer.refunded.totalCalculatedFees).to.equal("24959");
      expect(offer.refunded.netAmount).to.equal("165041");

      expect(await usdcContract.balanceOf(treasury)).to.equal(
        parseUnits("1650.41", decimals)
      );
    });

    it("Should fail reserveRefund if already refunded for Offer(7) ", async (offerId: number = 7) => {
      await expect(
        offers.reserveRefund(offerId, timestamp + 9 * ONE_DAY, 2750)
      ).to.be.revertedWith("Invalid Offer");
    });

    it("Should fail reserveRefund for inexisting Offer(8) ", async (offerId: number = 8) => {
      await expect(
        offers.reserveRefund(offerId, timestamp + 9 * ONE_DAY, 2750)
      ).to.be.revertedWith("Invalid Offer");
    });

    it("Should fail create Offer with InvalidAdvanceFee", async () => {
      await expect(
        offers.createOffer(
          "0x689C",
          9200,
          800,
          227,
          5,
          1000000,
          900000,
          120,
          usdcContract.address
        )
      ).to.be.revertedWith("InvalidAdvanceFee(9200, 9000)");
    });

    it("Should fail create Offer with InvalidFactoringFee", async () => {
      await expect(
        offers.createOffer(
          "0x689C",
          9000,
          800,
          127,
          5,
          1000000,
          900000,
          120,
          usdcContract.address
        )
      ).to.be.revertedWith("InvalidFactoringFee(127, 227)");
    });

    it("Should fail create Offer with InvalidAmount", async () => {
      await expect(
        offers.createOffer(
          "0x689C",
          9000,
          800,
          227,
          5,
          10000000,
          9000000,
          120,
          usdcContract.address
        )
      ).to.be.revertedWith("InvalidInvoiceAmount(10000000, 500000, 1000000)");
    });

    it("Should fail create Offer with Invalid Tenure", async () => {
      await expect(
        offers.createOffer(
          "0x689C",
          9000,
          800,
          227,
          5,
          10000000,
          9000000,
          20,
          usdcContract.address
        )
      ).to.be.revertedWith("InvalidTenure(20, 120, 180)");
    });

    it("Should fail create Offer with available amount higher than invoice amount", async () => {
      await expect(
        offers.createOffer(
          "0x689C",
          9000,
          800,
          227,
          5,
          900000,
          1000000,
          120,
          usdcContract.address
        )
      ).to.be.revertedWith("InvalidAvailableAmount(1000000, 900000)");
    });
  });
});
