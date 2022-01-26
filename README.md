# DEFI-Farm-Project
TokenFarm contract allows users to stake and unstake ACCEPTED tokens only.  User will receive Dapp token as incentive for staking

//TokenFarm contract allows users to stake and unstake ACCEPTED tokens only.
//They will receiove Dapp token as incentive for staking
//Users can unstake their tokens and the contract will keep track of the value of each token staked.
//Uses Chainlink Aggregator, pricefeed to get value of tokens.
//Allows users to get the exact value of the amount of tokens staked whether its DAI,ETH, and other apprvoed tokens

//Updates: test.js files need updates
//Updates: When user unstakes tokens they should be removed from the stakers list.

Truffle configured to run on Ropsten network:
1. create .env file - npm install dotenv --save
2. MNEMONIC - "paste your MNEMONIC in the dotenv file"
3. Instead of (2) create MNEMONIC variable in Truffle-config file. Replace "process.env.MNEMONIC" with MNEMONIC variable.
4. Set your infura endpoint as well.

