// 1. Enter the lottery (paying some amount)
// 2. Pick a random winner (verfiabily random)
// 3. Winner to be selected in interval (automated)

// Chainlink Oracle -> Randomness, automated execution (Chainlink Keepers)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Lottery {
    uint256 private s_entranceFee;

    constructor(uint256 entranceFee){
        s_entranceFee = entranceFee;
    }


    
    // set a USD price entrance fee
    function enterLottery(){    

    } 
    // function pickWinner(){

    // }

}