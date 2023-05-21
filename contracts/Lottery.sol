// 1. Enter the lottery (paying some amount)
// 2. Pick a random winner (verfiabily random)
// 3. Winner to be selected in interval (automated)

// Chainlink Oracle -> Randomness, automated execution (Chainlink Keepers)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

//@title A title that should describe the contract/interface
// @author Dan She
//@notice Explain to an end user what this does
//dev Explain to a developer any extra details

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

error Lottery_NotEnoughETHEntered();

contract Lottery {
    // Contract State
    uint256 private immutable i_entranceFee;
    address payable[] private s_player;



    event LotteryEntered(address indexed player);

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee;
    }


    
    // set a USD price entrance fee
    function enterLottery() public payable{    
        if(msg.value < i_entranceFee){
            revert Lottery_NotEnoughETHEntered();}
        s_player.push(payable(msg.sender));

        emit LotteryEntered(msg.sender);

    } 

    //1. request random number 2. Derive winner from random number. 2 step transaction to avoid brute force attack
    function pickWinner() external

    }

    function getEntranceFee() public view returns(uint256){
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns(address){
        return s_player[index];

    }

}