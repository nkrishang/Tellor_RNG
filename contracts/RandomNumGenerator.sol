/**
 * @authors: [@nkirshang]

 * A (non-pseudo) random number generator (RNG) that uses Tellor oracle's ETH/USD price feed updates.
 
 * SPDX-License-Identifier: MIT
**/

pragma solidity >=0.7.0;
pragma experimental ABIEncoderV2;

import "usingtellor/contracts/UsingTellor.sol";
import "hardhat/console.sol"; // To be removed in production.

import "./interace/IRandomNumGenerator.sol"
import "./interace/IRandomNumReceiver.sol"

contract RandomNumGenerator is UsingTellor, IRandomNumGenerator {

    uint256 public TELLOR_REQUEST_ID = 1;

    /// @dev The latest ETH/USD price set when the contract sends the caller a random number.
    uint256 public valueAtLastUpdate;

    /// @dev The timeStamp of the latest price update.
    uint256 public blockTimestampAtLastUpdate;

    /// @dev The queue of contract addresses that have requested a random number.
    struct Queue {
        mapping(uint256 => address) queue;
        uint256 first;
        uint256 last;
    }

    Queue public requestQueue;

    /// @dev Contract address that has requested a random number => requested range of random number.
    mapping(address => uint256) public range;

    event RandomNumberGenerated(uint256 _randomNumber, address indexed _receiver);
    event RandomNumberRequested(address indexed _receiver, uint256 _queuePosition);

    constructor(
        address payable _tellorAddress,
        uint256 _valueAtLastUpdate,
        uint256 _blockTimestampAtLastUpdate
    ) UsingTellor(_tellorAddress) {

        valueAtLastUpdate =_valueAtLastUpdate;
        blockTimestampAtLastUpdate = _blockTimestampAtLastUpdate;

        // Initializing the request queue struct.
        requestQueue.first = 1;
        requestQueue.last = 0;
    }

    function generateRandomNumber() external {

        (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(TELLOR_REQUEST_ID);

        require(ifRetrieve, "The latest price update could not be retrieved from Tellor."); // Check if it's the right usage.
        require(_timestampRetrieved > blockTimestampAtLastUpdate, "Only one random number generated per price update.")
        require(valueAtLastUpdate != value, "Cannot generate a truly random number if the asset value hasn't changed.");

        (valueAtLastUpdate, blockTimestampAtLastUpdate) = (value, _timestampRetrieved);

        address receiverAddress = dequeue();
        IRandomNumReceiver randomNumberReceiver = IRandomNumReceiver(receiverAddress);
        uint256 numRange = range[receiverAddress];

        uint256 randomNumber = calculateRandomNumber(value, _timestampRetrieved, numRange)
        randomNumberReceiver.receiveRandomNumber(randomNumber);

        emit RandomNumberGenerated(randomNumber, receiverAddress);
    }

    function requestRandomNumber(uint256 _range) external returns (uint256) {

        require(_range < block.number, "The range for the random number must be less than the blocknumber.")

        address randomNumberReceiver = msg.sender;

        range[randomNumberReceiver] = _range;
        uint256 queuePosition = enqueue(randomNumberReceiver);

        emit RandomNumberRequested(randomNumberReceiver, _queuePosition);
        
        return queuePosition;
    }

    function calculateRandomNumber(
        uint256 _value, 
        uint256 _timestamp,
        uint256 _range
    ) internal returns (uint256) {

        uint256 randomNumber =  ((_value*_timestamp) + block.number) % _range;
        return randomNumber;
    }

    function enqueue(address _receiver) internal returns (uint256) {
        requestQueue.last += 1;
        requestQueue.queue[requestQueue.last] = _receiver

        return (requestQueue.last - requestQueue.first + 1);
    }

    function dequeue() internal returns (address) {

        require(requestQueue.last >= requestQueue.first, "The queue is empty");

        address receiver = requestQueue.queue[requestQueue.first];
        delete requestQueue.queue[requestQueue.first];
        requestQueue.first += 1;

        return receiver;
    }

}
