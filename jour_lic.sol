// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract CreatorMintedNonTransferableNFT is ERC721, Ownable {
    using Strings for uint256;
    string ipfsHash = "QmNZ52p8ayxWJfEiGm7yTdYCrDgvKAorm4H8zoGRN211HH";

    uint256 private _tokenIdCounter;

    struct NFTMetadata {
        string displayName;
        uint256 number;
        string ipfsHash;  // 新增：存儲每個 NFT 的 IPFS 哈希
    }

    // Mapping from token ID to metadata
    mapping(uint256 => NFTMetadata) private _tokenMetadata;

    event NFTMinted(address indexed to, uint256 indexed tokenId, string displayName, uint256 number);

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {}

    function mint(address to, string memory displayName, uint256 number) public onlyOwner {
        require(to != address(0), "Cannot mint to the zero address");
        require(to != owner(), "Owner cannot mint to themselves");
        require(bytes(ipfsHash).length > 0, "IPFS hash cannot be empty");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(to, tokenId);

        // Store the metadata
        _tokenMetadata[tokenId] = NFTMetadata(displayName, number, ipfsHash);

        emit NFTMinted(to, tokenId, displayName, number);
    }

    // ... [其他函數保持不變] ...

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        NFTMetadata memory metadata = _tokenMetadata[tokenId];
        return generateTokenURI(tokenId, metadata.displayName, metadata.number, metadata.ipfsHash);
    }

    function generateTokenURI(uint256 tokenId, string memory name, uint256 number, string memory ipfsHash) internal pure returns (string memory) {
        string memory imageURL = string(abi.encodePacked("ipfs://", ipfsHash));
        
        bytes memory dataURI = abi.encodePacked(
            '{',
            '"name": "', name, '",',
            '"description": "A non-transferable NFT",',
            '"image": "', imageURL, '",',
            '"tokenId": "', tokenId.toString(), '",',
            '"number": ', number.toString(),
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    // Function to get the metadata of a token
    function getTokenMetadata(uint256 tokenId) public view returns (string memory displayName, uint256 number, string memory ipfsHash) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        NFTMetadata memory metadata = _tokenMetadata[tokenId];
        return (metadata.displayName, metadata.number, metadata.ipfsHash);
    }
}