// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

  const baseTokenURI = "ipfs://QmZbWNKJPAjxXuNFSEaksCJVd1M6DaKQViJBYPK2BdpDEP/";

  const [owner, user1] = await hre.ethers.getSigners();

  const NFTCollectable = await hre.ethers.getContractFactory("NFTCollectable");
  const nftcollectable = await NFTCollectable.deploy(baseTokenURI);

  await nftcollectable.deployed();

  console.log(
    `contract deployed At ${nftcollectable.address}`
  );

  let txn = await nftcollectable.reserveNFT();
  await txn.wait();

  let mintNfts = await nftcollectable.mintNfts("3",{ value: ethers.utils.parseEther('0.03') });
  await mintNfts.wait();

  let Ownertokens = await nftcollectable.tokensOfOwner( owner.address )
  console.log("Owner has tokens: ", Ownertokens);
  console.log("Owner Address: ", owner.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
