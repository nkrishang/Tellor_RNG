const { expect } = require("chai");
const { ethers } = require("hardhat");


// For more on how to test events with ethers, see - https://github.com/ethers-io/ethers.js/issues/283

describe("Market contract - Listing flow",  function() {

    const TELLOR_RINKEBY_ADDRESS = "0xFe41Cb708CD98C5B20423433309E55b53F79134a";
    let generator;
    let receiver;

    beforeEach(async function() {

        // Deploying the arbitrator contract.
        const GeneratorFactory = await ethers.getContractFactory("RandomNumGenerator");
        generator = await GeneratorFactory.deploy(TELLOR_RINKEBY_ADDRESS);

        // Deploying the market contract && getting signers.
        const ReceiverFactory = await ethers.getContractFactory("RandomNumReceiver");
        receiver = await ReceiverFactory.deploy(TELLOR_RINKEBY_ADDRESS, generator.address);
    });

    it("Should request for random number", async function() {

        const queuePositionPromise = new Promise((resolve, reject) => {

            receiver.on("InQueueForRandomNumber", (position, addr, event) => {
                event.removeListener();
        
                console.log(`Queue Position: ${position.toString()}`);
                console.log(`Address of request-er: ${addr}`);
        
                resolve();
            })
        
            setTimeout(() => {
                reject(new Error("Timout for InQueueForRandomNumber"))
            }, 60000);
        })

        await receiver.requestRandomNumber(10);
        await queuePositionPromise;
    })

    it("Should emit RandomNumberGenerated", async function() {

        const queuePositionPromise = new Promise((resolve, reject) => {

            receiver.on("InQueueForRandomNumber", (position, addr, event) => {
                event.removeListener();
        
                console.log(`Queue Position: ${position.toString()}`);
                console.log(`Address of request-er: ${addr}`);
        
                resolve();
            })
        
            setTimeout(() => {
                reject(new Error("Timeout for InQueueForRandomNumber"))
            }, 60000);
        })

        const numberGeneratedPromise = new Promise((resolve, reject) => {

            receiver.on("RandomNumberGenerated", (randomNumber, receiverAddr, event) => {
                event.removeListener();
        
                console.log(`Random Number: ${randomNumber.toString()}`);
                console.log(`Address of receiver: ${receiverAddr}`);

                expect(addr).to.equal(RNG.address);
        
                resolve();
            })
        
            setTimeout(() => {
                reject(new Error("Timeout for RandomNumberGenerated"))
            }, 60000);
        })

        await receiver.requestRandomNumber(10);
        await queuePositionPromise;
        await generator.generateRandomNumber();
        await numberGeneratedPromise;
    })
})