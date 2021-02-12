# Random Number Generator using Tellor
An on-chain, (non-pseudo) random number generator (RNG) that uses Tellor oracle's ETH/USD price feed updates.
 
## The general problem with on chain RNGs
![Generic RNG architecture](https://i.ibb.co/Ln66z95/rng-graphic-one.png)

As is well known by this point, this formula for churning out random numbers is vulnerable to miner attacks and the like. Block variables can be manipulated and any amount 
of complex math can be reverse engineered. 

To build a genuine on-chain random number, the random number generated must be a function of values that neither the contract, nor the caller know before the caller calls
a random number generator function. Moreover, these 'unknown' values must be terribly hard to manipulate and fix, beforehand.

Tellor helps us accomplish both. This project leverages **1)** Tellor's nature as an oracle, providing a periodically updating feed of values not known beforehand, and
**2)** the security provided by Tellor's proof of work system.

## The architechture of a Tellor RNG
![Solution architecture](https://i.ibb.co/F3vgjpy/rng-graphic-two.png)

Let's say a protocol like Pool Together wishes to use this RNG. Simply put, the flow will be as follows:

- We implement RandomNumGenerator.sol i.e. the random number generator. [View contract.](https://github.com/nkrishang/Tellor_RNG/blob/master/contracts/RandomNumGenerator.sol)
- Some protocol, like Pool Together, makes a request for a random number. They are added to the queue in RandomNumGenerator.sol.
- The requesting protocol will implement the IRandomNumReceiver interface and can be called back from generateRandomNumber when the number is available.
