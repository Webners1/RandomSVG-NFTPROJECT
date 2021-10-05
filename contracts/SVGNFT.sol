//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";

contract MyNFT is ERC721URIStorage {
    event mintingNFT(uint256 indexed tokenId, string tokenUri);
    uint256 public tokenCounter = 0;
    

    constructor() ERC721("MyNFT", "MNFT") {}

    function create(string memory _svg) public {
        _safeMint(msg.sender, tokenCounter);
        string memory imageUri = svgToImage(_svg);
        
        _setTokenURI(tokenCounter, formatTokenUri(imageUri));
        emit mintingNFT(tokenCounter, formatTokenUri(imageUri));
        tokenCounter++;
    }

    function svgToImage(string memory _svg)
        public
        pure
        returns (string memory)
    {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory svgbase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(_svg)))
        );
        string memory imageUri = string(
            abi.encodePacked(baseUrl, svgbase64Encoded)
        );
        return imageUri;
    }

    function formatTokenUri(string memory _imageUri)
        public
        pure
        returns (string memory)
    {
        string memory baseUrl = "data:application/json;base64,";
        return
            string(
                abi.encodePacked(
                    baseUrl,
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"myNFT", ',
                                '"description":"Muzammil NFT ion SVG", ',
                                '"attributes":"", ',
                                '"image":"',
                                _imageUri,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
