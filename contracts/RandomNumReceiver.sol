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

    // State variables

    IRandomNumGenerator public rng;
    uint256 public latestRandomNumber;

    // functions

    /**
     * @dev Receive random number from RNG. Called by a IRandomNumGenerator contract.
     * @param _randomNumber The random number sent by the RNG i.e. IRandomNumGenerator.
    **/
    function receiveRandomNumber(uint256 _randomNumber) external {

    }
}   
