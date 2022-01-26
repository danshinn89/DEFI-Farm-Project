// SPDX-License-Identifier: MIT

//TokenFarm contract allows users to stake and unstake ACCEPTED tokens only.
//They will receiove Dapp token as incentive for staking
//Users can unstake their tokens and the contract will keep track of the value of each token staked.
//Uses Chainlink Aggregator, pricefeed to get value of tokens.
//Allows users to get the exact value of the amount of tokens staked whether its DAI,ETH, and other apprvoed tokens

//Updates: test.js files need updates
//         When user unstakes tokens they should be removed from the stakers list.

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable {
    // mapping token address -> staker address -> amount
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping(address => address) public tokenPriceFeedMapping;
    address[] public stakers;
    address[] public allowedTokens;
    IERC20 public dappToken;

    constructor(address _dappTokenAddress) public {
        dappToken = IERC20(_dappTokenAddress);
    }

    //must have this funtion to set the pricefeed contract address for the particular token
    function setPriceFeedContract(address _token, address _priceFeed)
        public
        onlyOwner
    {
        //token pricefeed mapping of the token
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    function issueTokens() public onlyOwner {
        // Issue tokens to all stakers
        for (
            uint256 stakersIndex = 0;
            stakersIndex < stakers.length;
            stakersIndex++
        ) {
            address recipient = stakers[stakersIndex];
            //send them a token reward based on total value locked
            //DappToken is teh token reward
            //Calls userTotalValue function to get the value amount of users account
            uint256 userTotalValue = getUserTotalValue(recipient);
            //sending dapptoken to the receipent
            //using the userTotalValue function. However much they have in total value staked we will issue as a reward
            dappToken.transfer(recipient, userTotalValue);
        }
    }

    //we want to return teh total value to get  getUserTotalValue number
    function getUserTotalValue(address _user) public view returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0, "No tokens staked!");
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            //we need the value of a single token out of the list of allowed tokens this user may have deposited
            totalValue =
                totalValue +
                getUserSingleTokenValue(
                    _user,
                    allowedTokens[allowedTokensIndex]
                );
        }
        return totalValue;
    }

    function getUserSingleTokenValue(address _user, address _token)
        public
        view
        returns (uint256)
    {
        //If the user has not staked any tokens return 0
        if (uniqueTokensStaked[_user] <= 0) {
            return 0;
        }

        (uint256 price, uint256 decimals) = getTokenValue(_token);
        ((stakingBalance[_token][_user] * price) / (10**decimals));
    }

    function getTokenValue(address _token)
        public
        view
        returns (uint256, uint256)
    {
        address priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        //grabbing the int256 price from pricefeed.latestRoundData()
        (, int256 price, , , ) = priceFeed.latestRoundData();
        //we also need to get the decimals the pricefeed contract has so we use the same units
        uint256 decimals = uint256(priceFeed.decimals());
        //return both price and decimals
        return (uint256(price), decimals);
    }

    function stakeTokens(uint256 _amount, address _token) public {
        require(_amount > 0, "Amount must be more than 0");
        require(tokenIsAllowed(_token), "Token is currently no allowed");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        updateUniqueTokensStaked(msg.sender, _token);
        stakingBalance[_token][msg.sender] =
            stakingBalance[_token][msg.sender] +
            _amount;
        if (uniqueTokensStaked[msg.sender] == 1) {
            stakers.push(msg.sender);
        }
    }

    function unstakeTokens(address _token) public {
        //is this vulnerable to reentrancy attacks?
        //revist and update
        uint256 balance = stakingBalance[_token][msg.sender];
        require(balance > 0, "Staking balance cannot be 0");
        IERC20(_token).transfer(msg.sender, balance);
        stakingBalance[_token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
        //update: try to update stakers array to remove this user from the list after they have unstaked their tokens
        //stakers[_token][msg.sender].splice;
    }

    function updateUniqueTokensStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user] <= 0) {
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
        }
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function tokenIsAllowed(address _token) public returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            if (allowedTokens[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
    }
}
