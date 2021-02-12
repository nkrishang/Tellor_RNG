const TELLOR_RINKEBY_ADDRESS = "0xFe41Cb708CD98C5B20423433309E55b53F79134a";

async function main() {

  const [deployer] = await ethers.getSigners();

//   const receiverFactory = await ethers.getContractFactory("RandomNumReceiver");
//   const receiver = await receiverFactory.deploy(TELLOR_RINKEBY_ADDRESS); // Deploy with UsingTellor address

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

//   console.log(
//     "Receiver contract address:",
//     receiver.address
//   );
  
  const generatorFactory = await ethers.getContractFactory("RandomNumGenerator");
  const generator = await generatorFactory.deploy(TELLOR_RINKEBY_ADDRESS); // Deploy with UsingTellor address

  console.log("Generator contract address:", generator.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
});