const ethers = require('ethers');
require('dotenv').config();

const main = async () => {

    const baseTokenURI = "ipfs://QmZbWNKJPAjxXuNFSEaksCJVd1M6DaKQViJBYPK2BdpDEP/";  
    const NFTCollectable = await hre.ethers.getContractFactory("NFTCollectable");
    const nftcollectable = await NFTCollectable.deploy(baseTokenURI);
  
    await nftcollectable.deployed();

    const allowlistedAddresses = [
        '0x6B0c04DADA62D5da2ab6702763209E0D7D2c591b ',
        '0xEc89B5481d661fb7C31b8724489e6918527f0C91',
        '0x3ec4aCf72f42E1Ec71acDB1FfEef71646162FaB6',
        '0x98294f86459A995329723579FA9869e59d1F75b7',
    ];

    const { Temp, PRIVATE_KEY } = process.env;

    let message = allowlistedAddresses[0];

    const signer = new ethers.Wallet(PRIVATE_KEY);

    let messageHash = ethers.utils.id(message);

    let messageBytes = ethers.utils.arrayify(messageHash);
    let signature = await signer.signMessage(messageBytes);
    console.log("Signature: ", signature);

    const recover = await nftcollectable.recoverSigner(messageHash, signature);
    console.log(recover);
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    }
    catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();
