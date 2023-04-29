// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Daimyo is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
     uint256 maxSupply = 10000;
     bool publicMintOpen = false;
     bool allowListMintOpen = false;
     uint256 public nftPerWalletLimit = 1;

     mapping (address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Daimyo", "Dmy") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    
    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    function allowListMint() public payable {
        require(allowListMintOpen, "Allowlist mint closed");
        require(allowList[msg.sender], "you are not whitelisted");//getting whitlisted address from the allowlist mapping
        require(msg.value == 0.01 ether , "insuffficent ether");
        
        internalMint();
    }

    function publicMint() public payable {
        require(publicMintOpen, "publicMint closed");
        require(msg.value == 0.1 ether,"insufficient ether");

        internalMint();
    }

    function OwnerMint() public onlyOwner {
         uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }


    function internalMint () internal {
        uint256 ownerTokenCount = balanceOf(msg.sender);
        require(ownerTokenCount < nftPerWalletLimit);//can only mint one nft
        require(totalSupply() < maxSupply, "Sold Out"); //sold out after total supply hits max supply
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    //to add allowlisted addresses
     function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }
  
    function withdraw() public payable onlyOwner {
      // This will payout the owner of the contract balance.
     (bool os, ) = payable(owner()).call{value: address(this).balance}("");
     require(os);
    
     }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
