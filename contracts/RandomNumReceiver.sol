/**
 * @authors: [@nkirshang]

 * A random number receiver (RNR) that requests (and subsequently) receives a random number from
 * the Tellor RNG.
 
 * SPDX-License-Identifier: MIT
**/

pragma solidity >=0.7.0;
pragma experimental ABIEncoderV2;

import "usingtellor/contracts/UsingTellor.sol";
import "hardhat/console.sol"; // To be removed in production.

import "./interace/IRandomNumGenerator.sol"
import "./interace/IRandomNumReceiver.sol"

contract RandomNumReceiver is UsingTellor, IRandomNumReceiver {

    /// @dev The RNG responsible for generating random numbers for the receiver.
    IRandomNumGenerator public rng;

    /// @dev Queue position for th random number returned by RNG => address of the caller at that queue position.
    mapping (uint256 => address) queuePositionToAddress;

    /// @dev To emit when RNG calls reeiver with a random number.
    event RandomNumberReceived(uint256 _randomNumber, address indexed _caller)

    /// @dev To emit with the queue position of the receiver, in the RNG contract.
    event InQueueForRandomNumber(uint256 _queuePosition, address indexed _caller);


    /**
     * @dev Receive random number from RNG. Called by a IRandomNumGenerator contract.
     * @param _randomNumber The random number sent by the RNG i.e. IRandomNumGenerator.
    **/
    function receiveRandomNumber(uint256 _randomNumber, uint256 _queuePosition) external {

        require(msg.sender == rng, "Only the authorized RNG can send a random number.");

        address caller = queuePositionToAddress[_queuePosition];
        emit RandomNumberReceived(_randomNumber, caller);
    }

    /**
     * @dev Request random number from RNG.
     * @param _range A range for the random number given by the caller requesting a random number.
    **/
    function requestRandomNumber(uint256 _range) external {

        uint256 queuePosition = rng.randomNumberRequest(_range);
        queuePositionToAddress[queuePosition] = msg.sender;
        
        emit InQueueForRandomNumber(queuePosition, msg.sender);
    }
}   
