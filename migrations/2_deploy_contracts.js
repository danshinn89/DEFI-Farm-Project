var Token = artifacts.require("./DappToken.sol");
var TokenFarm = artifacts.require("./TokenFarm.sol");

require("dotenv").config({ path: "../.env" });
console.log(process.env);


module.exports = async function (deployer) {
  let addr = await web3.eth.getAccounts();
  await deployer.deploy(Token);
  const token = await Token.deployed();
  await deployer.deploy(TokenFarm, Token.address);
  let instance = await Token.deployed();
  //Transfer tokens to the TokenFarm for testing purposes
  //await instance.transfer(TokenFarm.address, web3.utils.toBN("process.env.INITIAL_TOKENS"));





};
