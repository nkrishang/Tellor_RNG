# Random Number Generator using Tellor
An on-chain, (non-pseudo) random number generator (RNG) that uses Tellor oracle's ETH/USD price feed updates.

### Contracts deployed on Rinkeby
- RandomNumGenerator.sol : [0x9a86f28bc657f4ab12dc352bcb21372d7e9aeb71](https://rinkeby.etherscan.io/address/0x9a86f28bc657f4ab12dc352bcb21372d7e9aeb71)
- RandomNumReceiver.sol : [0x1A04f58426C62Ec19c9758390aB6c2228052A1F4](https://rinkeby.etherscan.io/address/0x1A04f58426C62Ec19c9758390aB6c2228052A1F4)
- `NewValue` event listener server running on Replit [here.](https://repl.it/@nkrishang/TellorRNG)
 
## The general problem with on-chain RNGs
![Generic RNG architecture](https://i.ibb.co/Ln66z95/rng-graphic-one.png)

As is well known by this point, this formula for churning out random numbers is vulnerable to miner attacks and the like. Block variables can be manipulated and any amount 
of complex math can be reverse engineered. 

To build a genuine on-chain random number, the random number generated must be a function of values that neither the contract, nor the caller knows before the caller calls
a random number generator function. Moreover, these 'unknown' values must be terribly hard to manipulate and fix, beforehand.

Tellor helps us accomplish both. This project leverages **1)** Tellor's nature as an oracle, providing a periodically updating feed of values not known beforehand, and
**2)** the security provided by Tellor's proof of work system.

## The architechture of a Tellor RNG
![Solution architecture](https://i.ibb.co/F3vgjpy/rng-graphic-two.png)

Let's say a protocol like Pool Together wishes to use this RNG. Simply put, the flow will be as follows:

- We implement RandomNumGenerator.sol i.e. the random number generator. [View contract.](https://github.com/nkrishang/Tellor_RNG/blob/master/contracts/RandomNumGenerator.sol)
- Some protocol, like Pool Together, makes a request for a random number. They are added to the queue in RandomNumGenerator.sol.
- The requesting protocol will implement the IRandomNumReceiver interface and can be called back from `generateRandomNumber` when the number is available.
- Anyone can call `generateRandomNumber` post a new price update. I have an express server listening for the `NewValue` event on Tellor's core contract on Rinkeby, [here.](https://repl.it/@nkrishang/TellorRNG)

## Why is this solution better than any generic on-chain RNG?

The Tellor RNG derives its randomness from the fact that the exact value of the next ETH/USD price update, and the timestamp of that update are unknowable beforehand, 
and extremely difficult to manipulate.

The Tellor protocol requires 5 miners to solve a proof of work challenge to be able to submit price values to the block about to be mined. For a malicious actor to cheat the RNG
and predict these two values, they would have to **1)** manage to get all of the first 5 miners to input the same price value, and **2)** ensure that all 5 proof of work
challenges are completed by the exact desired timetamp. This is terribly difficult.

Can the Tellor RNG be manipulated? Absolutely. The usefulness of the Tellor RNG is a function of Tellor's decentralization, mining difficulty and block rate.
