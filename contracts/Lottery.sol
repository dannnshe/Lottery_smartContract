// 1. Enter the lottery (paying some amount)
// 2. Pick a random winner (verfiabily random)
// 3. Winner to be selected in interval (automated)

// Chainlink Oracle -> Randomness, automated execution (Chainlink Keepers)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


error Lottery_NotEnoughETHEntered();
error 

contract Lottery {
    // Contract State
    uint256 private immutable i_entranceFee;
    address payable[] private s_player;

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee;
    }


    
    // set a USD price entrance fee
    function enterLottery() public payable{    
        if(msg.value < i_entranceFee){
            revert Lottery_NotEnoughETHEntered();}
        s_player.push(payable(msg.sender));

    } 
    // function pickWinner(){

    // }

    function getEntranceFee() public view returns(uint256){
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns(address){
        return s_player[index];

    }

}