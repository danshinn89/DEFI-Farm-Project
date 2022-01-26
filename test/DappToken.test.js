const Token = artifacts.require("DappToken");

var chai = require("chai");
const BN = web3.utils.BN;
const chaiBN = require("chai-bn")(BN);
chai.use(chaiBN);

var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);

const expect = chai.expect;

contract("Token Test", async accounts => {
    const [initialHolder, recipient, anotherAccount] = accounts;

    it("all tokens should be in my account", async () => {
        let instance = await Token.deployed();
        let totalSupply = await instance.totalSupply();
        //let balance = await instanceof.balanceOf(accounts[0]);
        expect(await instance.balanceOf(accounts[0])).to.be.a.bignumber.equal(totalSupply);
    })

    //send tokens fails. expected promise pending
    it("I can send tokens from Account 1 to Account 2", async () => {
        const sendTokens = 1;
        let instance = await Token.deployed();
        let totalSupply = await instance.totalSupply();
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply);
        await expect(instance.transfer(recipient, sendTokens)).to.eventually.be.fulfilled;
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply.sub(new BN(sendTokens)));
        await expect(instance.balanceOf(recipient)).to.eventually.be.a.bignumber.equal(new BN(sendTokens));
    });


});
