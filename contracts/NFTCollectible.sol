//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTCollectable is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant PRICE = 0.01 ether;
    uint256 public constant MAX_PER_MINT = 5;

    mapping(address => bool) public isAllowlistAddress;
    mapping(bytes => bool) public signatureIsUsed;

    string public baseTokenURI;

    constructor(string memory baseURI) ERC721("NFT Collectible", "NFTC") {
        setBasedURI(baseURI);
    }

    function reserveNFT() public onlyOwner {
        uint256 totalMinted = _tokenIds.current();

        require(totalMinted.add(10) < MAX_SUPPLY, "Not enough NFT's");

        for (uint256 i = 0; i < 10; i++) {
            _mintSingleNFT();
        }
    }

    function setAllowlist(address[] calldata allowedUser) public onlyOwner {
        for (uint256 i = 0; i < allowedUser.length; i++) {
            isAllowlistAddress[allowedUser[i]] = true;
        }
    }

    function setBasedURI(string memory _baseURI) public onlyOwner {
        baseTokenURI = _baseURI;
    }

    function preSale(bytes32 hash, bytes memory signature,uint256 _count) public payable {
        uint256 totalMinted = _tokenIds.current();
        uint256 preSalePrice = 0.005 ether;
        uint256 maxPreSale = 2;

        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFT's");
        require(
            _count > 0 && _count <= maxPreSale,
            "Cannot mint specified mumber of NFT's"
        );
        require(
            msg.value >= preSalePrice.mul(_count),
            "Not enough ether to purchage NFT's"
        );
        // require(isAllowlistAddress[msg.sender], "User is not allowed");

        require(recoverSigner(hash, signature) == owner(),"Address is not allowlisted");

        require(!signatureIsUsed[signature], "Signature is allready used");

        for (uint256 i = 0; i < _count; i++) {
            _mintSingleNFT();
        }

        // isAllowlistAddress[msg.sender] = false;
        signatureIsUsed[signature] = true;
    }

    function mintNfts(uint256 _count) public payable {
        uint256 totalMinted = _tokenIds.current();

        require(
            totalMinted.add(_count) <= MAX_SUPPLY,
            "Not enogh NFT left for mint"
        );
        require(
            _count > 0 && _count <= MAX_SUPPLY,
            "Cannot mint given number of NFT's"
        );
        require(
            msg.value >= PRICE.mul(_count),
            "Not enough ether to purchage NFT's"
        );
        // require( totalMinted >= MAX_SUPPLY, "Not enogh NFT left for mint_");

        for (uint256 i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function withdraw() public payable onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Not enough balance to withdraw");
        (bool success, ) = (msg.sender).call{value: contractBalance}("");
        require(success, "Transaction Failed");
    }

    function _mintSingleNFT() private {
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);
        _tokenIds.increment();
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        public
        pure
        returns (address)
    {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        return ECDSA.recover(messageDigest, signature);
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 totalUserTokens = balanceOf(_owner);

        uint256[] memory tokenIds = new uint256[](totalUserTokens);

        for (uint256 i = 0; i < totalUserTokens; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokenIds;
    }
}
