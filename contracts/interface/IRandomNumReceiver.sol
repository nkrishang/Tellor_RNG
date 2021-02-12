/**
 * @authors: [@nkirshang]

 * A random number receiver (RNR) that requests (and subsequently) receives a random number from
 * the Tellor RNG.
 
 * SPDX-License-Identifier: MIT
**/

pragma solidity >=0.7.0;
pragma experimental ABIEncoderV2;

interface IRandomNumReceiver {

    /**
     * @dev Receive random number from RNG. Called by a IRandomNumGenerator contract.
     * @param _randomNumber The random number sent by the RNG i.e. IRandomNumGenerator.
     * @param _queuePosition The queue position of the address for which the random number is generated.
    **/
    function receiveRandomNumber(uint256 _randomNumber, uint256 _queuePosition) external;
}