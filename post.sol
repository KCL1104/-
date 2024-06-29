// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTBlog {
    IERC721 public nftContract;

    struct Post {
        address author;
        string content;
        uint256 timestamp;
    }

    Post[] public posts;

    constructor(address _nftContractAddress) {
        nftContract = IERC721(_nftContractAddress);
    }

    function createPost(string memory _content) public {
        require(nftContract.balanceOf(msg.sender) > 0, "Must own NFT to post");
        posts.push(Post(msg.sender, _content, block.timestamp));
    }

    function getAllPosts() public view returns (Post[] memory) {
        return posts;
    }
}