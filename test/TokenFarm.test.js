const Token = artifacts.require("DappToken");
const TokenFarm = artifacts.require("TokenFarm");

const chai = require("./chaisetup.js");
const BN = web3.utils.BN;
const expect = chai.expect;

contract("TokenFarm", async function (accounts) {
    const [initialHolder, recipient, anotherAccount] = accounts;

    it("there shouldnt be any coins in my account", async () => {
        let instance = await Token.deployed();
        return expect(instance.balanceOf.call(initialHolder)).to.eventually.be.a.bignumber.equal(new BN(0));
    });

});