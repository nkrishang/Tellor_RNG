/**
 * @authors: [@nkirshang]

 * A (non-pseudo) random number generator (RNG) that uses Tellor oracle's ETH/USD price feed updates.
 
 * SPDX-License-Identifier: MIT
**/

pragma solidity >=0.7.0;
pragma experimental ABIEncoderV2;

interface IRandomNumberGenerator {

    /**
     * @dev Adds the caller in the RNG queue. Must be called by a IRandomNumReceiver contract.
     * @param _range A range for the random number given by the caller requesting a random number.
     * @return _queuePosition The queue position of the caller in the RNG.
    **/
    function randomNumberRequest(uint256 _range) external returns (uint256 _queuePosition);
}