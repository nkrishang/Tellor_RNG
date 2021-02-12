/**
 * @authors: [@nkirshang]

 * A (non-pseudo) random number generator (RNG) that uses Tellor oracle's ETH/USD price feed updates.
 
 * SPDX-License-Identifier: MIT
**/

pragma solidity >=0.7.0;
pragma experimental ABIEncoderV2;

import "usingtellor/contracts/UsingTellor.sol";
import "./interface/IRandomNumGenerator.sol";
import "./interface/IRandomNumReceiver.sol";

contract RandomNumGenerator is UsingTellor, IRandomNumGenerator {

    /// @dev The Tellor request id for ETH/USD price feed
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
        address payable _tellorAddress
    ) UsingTellor(_tellorAddress) {

        valueAtLastUpdate = 0;
        blockTimestampAtLastUpdate = 0;

        requestQueue.first = 1;
        requestQueue.last = 0;
    }

    /// @dev Send random number to an IRandomNumReceiver contract.
    function generateRandomNumber() external override {

        (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(TELLOR_REQUEST_ID);

        require(ifRetrieve, "The latest price update could not be retrieved from Tellor.");
        require(_timestampRetrieved > blockTimestampAtLastUpdate, "Only one random number generated per price update.");
        require(valueAtLastUpdate != value, "Cannot generate a truly random number if the asset value hasn't changed.");

        (valueAtLastUpdate, blockTimestampAtLastUpdate) = (value, _timestampRetrieved);

        (address receiverAddress, uint256 queuePosition) = dequeue();
        IRandomNumReceiver randomNumberReceiver = IRandomNumReceiver(receiverAddress);
        uint256 numRange = range[receiverAddress];

        uint256 randomNumber = calculateRandomNumber(value, _timestampRetrieved, numRange);
        randomNumberReceiver.receiveRandomNumber(randomNumber, queuePosition);

        emit RandomNumberGenerated(randomNumber, receiverAddress);
    }

    /**
     * @dev Process a request for random number by an IRandomNumReceiver contract.
     * @param _range A range for the random number given by the caller requesting a random number.
     * @return The queue position of the random number request.
    **/
    function randomNumberRequest(uint256 _range) external override returns (uint256) {

        require(_range < 10000000, "The range for the random number must be less than the blocknumber.");
        address randomNumberReceiver = msg.sender;

        range[randomNumberReceiver] = _range;
        uint256 queuePosition = enqueue(randomNumberReceiver);

        emit RandomNumberRequested(randomNumberReceiver, queuePosition);
        
        return queuePosition;
    }

    /**
     * @dev Calculate random number.
     * @param _value The latest ETH/USD price updated by Tellor.
     * @param _timestamp The timestamp at which Tellor updated the ETH/USD price feed.
     * @param _range The range the random number belongs to.
     * @return The random number.
    **/
    function calculateRandomNumber(
        uint256 _value, 
        uint256 _timestamp,
        uint256 _range
    ) internal view returns (uint256) {

        uint256 randomNumber =  ((_value*_timestamp) + block.number) % _range;
        return randomNumber;
    }

    /// @dev Add address to the request queue.
    function enqueue(address _receiver) internal returns (uint256) {
        requestQueue.last += 1;
        requestQueue.queue[requestQueue.last] = _receiver;

        return (requestQueue.last - requestQueue.first + 1);
    }

    /// @dev Remove address from the request queue.
    function dequeue() internal returns (address, uint256) {

        require(requestQueue.last >= requestQueue.first, "The queue is empty");

        uint queuePosition = requestQueue.first;

        address receiver = requestQueue.queue[queuePosition];
        delete requestQueue.queue[queuePosition];
        requestQueue.first += 1;

        return (receiver, queuePosition);
    }

}
