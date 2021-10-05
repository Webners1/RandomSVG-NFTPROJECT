//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "base64-sol/base64.sol";

contract RandomSVG is ERC721URIStorage,VRFConsumerBase{
bytes32 public keyHash;
uint public fee=0;
uint public tokenCounter;
uint public maxPathCommand;
uint public maxPath;
uint public size;
string[] public pathCommands;
string[] public pathColors;
mapping(bytes32=>address) public requestIdtoSender;
mapping(bytes32=>uint) public requestIdtoTokenId;
mapping(uint=>uint) public tokenIdtoRandomNumer;
event requestRandomSVG(
       bytes32 indexed requestId,
       uint indexed tokenId
);
event createdRandomSVG(
       uint indexed tokenId,
       string tokenUri
);
event mintingRandomSvg(
       uint indexed tokenId,
       uint indexed randomNumber,
       bytes32 indexed requestId
       );
constructor(address _VRFCoordinator,address _linkToken,bytes32 _keyHash,uint _fee)VRFConsumerBase(_VRFCoordinator,_linkToken) 
ERC721("MuzRandomNFT", "MuzammilNFT") public{
       fee = _fee;
       keyHash = _keyHash;
       tokenCounter = 0;
       maxPath=10;
       maxPathCommand=5;
       size=500;
pathCommands=["M","L"];
pathColors=["red","green","blue","purple","black"];
}


function createRandomSVG() public returns (bytes32 requestId) {
//get a random number
//use random number to create random svg
//blockchains are deterministic
//oracle,Chainlink VRF(chain verifiable random number)
        requestId = requestRandomness(keyHash, fee);
        requestIdtoSender[requestId] = msg.sender;
        uint tokenId = tokenCounter;
        requestIdtoTokenId[requestId] = tokenId;
        tokenCounter++;
        emit requestRandomSVG(requestId,tokenId);
        return requestId;
    }
    function fulfillRandomness(bytes32 requestId, uint randomNumber)internal override {
           //the computation power to create randomNumber can be 200000gas
           //which is very much so we will use 2m gas not good for mainnet usage
   address nftOWNER = requestIdtoSender[requestId];
   uint tokenId = requestIdtoTokenId[requestId];
   _safeMint(nftOWNER,tokenId);
   tokenIdtoRandomNumer[tokenId] = randomNumber;
   emit mintingRandomSvg(tokenId,randomNumber,requestId);
    }
function finishMint(uint _tokenId )public{
require(bytes(tokenURI(_tokenId)).length <=0,'tokenURI already set');
require(tokenCounter>_tokenId,'tokenID hasnot been minted');
require(tokenIdtoRandomNumer[_tokenId]>0,'chainLink VRF havent generated RandomNUMBER');

uint randomNumber= tokenIdtoRandomNumer[_tokenId];

string memory svg = generateSVG(randomNumber);
string memory imageUri = svgToImage(svg);
string memory tokenUri = formatTokenUri(imageUri);
_setTokenURI(_tokenId, tokenUri);
emit createdRandomSVG(_tokenId,tokenUri);
}
function generateSVG(uint _randomNumber) public view returns(string memory svg){
uint numberofPaths = (_randomNumber % maxPath) + 1;
svg = string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' height='",
uint2str(size),"'width='",uint2str(size),"'>"));
for(uint i=0;i<numberofPaths;i++){
       uint newRNG = uint(keccak256(abi.encode(_randomNumber,i)));
       string memory pathSvg = generatePath(newRNG);
       svg = string(abi.encodePacked(pathSvg));
}
svg = string(abi.encodePacked(svg,"</svg>"));
}
function generatePath(uint _randomNumber)public view returns(string memory _pathString){
uint numberofPathsCommand =(_randomNumber % maxPathCommand) + 1;
_pathString = string(abi.encodePacked("<path d='"));
for(uint i=0;i<numberofPathsCommand;i++){
       uint newRNG = uint(keccak256(abi.encode(_randomNumber,size+i)));
string memory pathCommand  = generatePathCommand(newRNG);
_pathString = string(abi.encodePacked(_pathString,pathCommand));
}
string memory color = pathColors[_randomNumber% pathColors.length];
_pathString = string(abi.encodePacked(_pathString,"' file='transparent' stroke='",color,"'>"));

}

function generatePathCommand(uint _randomNumber)public view returns(string memory _pathCommand){
_pathCommand =pathCommands[_randomNumber % pathCommands.length];
uint parameterOne = uint(keccak256(abi.encode(_randomNumber,size*2)))% size;
uint parameterTwo = uint(keccak256(abi.encode(_randomNumber,size*3)))% size;
_pathCommand = string(abi.encodePacked(_pathCommand," ",uint2str(parameterOne)," ",parameterTwo));
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

function uint2str(
  uint256 _i
)
  internal
  pure
  returns (string memory str)
{
  if (_i == 0)
  {
    return "0";
  }
  uint256 j = _i;
  uint256 length;
  while (j != 0)
  {
    length++;
    j /= 10;
  }
  bytes memory bstr = new bytes(length);
  uint256 k = length;
  j = _i;
  while (j != 0)
  {
    bstr[--k] = bytes1(uint8(48 + j % 10));
    j /= 10;
  }
  str = string(bstr);
}
}