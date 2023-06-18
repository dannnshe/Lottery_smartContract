// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

error Lottery__NotEnoughETHEntered();
error Lottery__TransferFailed();
error Lottery_NotOpen();

contract Lottery is VRFConsumerBaseV2, KeeperCompatibleInterface {
    /*Types declarations*/

    enum LotteryState {
        OPEN,
        CALCULATING
    } // 0=OPEN, 1= CALCULATING

    //  State Variable

    uint256 private immutable i_entranceFee;
    address payable[] private s_player;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinatorV2;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    //Lottery Variable
    address private s_recentWinner;
    LotteryState private s_lotteryState;

    event LotteryEntered(address indexed player);
    event RequestedLotteryWinner(uint256 indexed requestedId);
    event WinnerPicked(address indexed recentWinner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCondinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subsciptionId = subsciptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lotteryState = LotteryState.OPEN; // or RaffleState(0)
    }

    // set a USD price entrance fee
    function enterLottery() public payable {
        if (msg.value < i_entranceFee) {
            revert Lottery__NotEnoughETHEntered();
        }
        if (s_lotteryState != LotteryState.OPEN) {
            revert Lottery_NotOpen();
        }
        s_player.push(payable(msg.sender));

        emit LotteryEntered(msg.sender);
    }

    /**
     * @notice method that is simulated by the keepers to see if any work actually
     * needs to be performed. This method does does not actually need to be
     * executable, and since it is only ever simulated it can consume lots of gas.
     * @dev To ensure that it is never called, you may want to add the
     * cannotExecute modifier from KeeperBase to your implementation of this
     * method.
     * @param checkData specified in the upkeep registration so it is always the
     * same for a registered upkeep. This can easily be broken down into specific
     * arguments using `abi.decode`, so multiple upkeeps can be registered on the
     * same contract and easily differentiated by the contract.
     * @return upkeepNeeded boolean to indicate whether the keeper should call
     * performUpkeep or not.
     * @return performData bytes that the keeper should call performUpkeep with, if
     * upkeep is needed. If you would like to encode data to decode later, try
     * `abi.encode`.
     * THis is the function that the Chainlink Keeper nodes call, they look for the 'upKeepNeeded' to return true.
     * The following should be true in order to return true. 1. Our time interval should have passed.
     * 2. Lottery should have at least 1 player and have ETH.
     * 3. Our subcription is funded with LINK
     * 4. Our lottery should be in an 'open' state.
     */
    function checkUpkeep(
        bytes calldata /*checkData*/
    ) external overide returns (bool upkeepNeeded, bytes memory /*performData*/);

    //1. request random number 2. Derive winner from random number. 2 step transaction to avoid brute force attack
    function requestWinner() external {
        //this function is called by chainlink network.
        s_lotteryState = LotteryState.CALCULATING;
        uint356 requestId = i_vrfCordinator.requestRandomWords( //return a unit256 requestId
            i_gasLane, //gasLane
            s_subsciptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedLotteryWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        // use Module % operation find winner in s_player. 202 % 10. What's doesn't divid evenly into 202. 2 in the array is winner
        uint256 indexOfWinner = randomWords[0] % s_player.length;
        address payable recentWinner = s_player[indexOfWinner];
        s_recentWinner = recentWinner;
        s_lotteryState = LotteryState.OPEN;
        s_players = new address payable[](0); //reset player's array after winner is determined.
        (bool sucess, ) = recentWinner.call{value: address(this).balance}("");

        if (!success) {
            revert Lottery__TransferFailed();
        }

        emit WinnerPicked(recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_player[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getPlayers() {}

    function getLasTimeStamp() {}

    function getInterval() {}

    function getEntranceFee() {}

    function getNumberOfPlayers() {}
}
