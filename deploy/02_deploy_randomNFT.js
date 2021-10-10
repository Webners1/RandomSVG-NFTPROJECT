let { networkConfig, getNetworkIdFromName } = require('../helper-hardhat-config')
const fs = require('fs')

module.exports = async ({
       getNamedAccounts,
       deployments,
       getChainId
}) => {

       const { deploy, get, log } = deployments
       const { deployer } = await getNamedAccounts()
       const chainId = await getChainId()
       let linkTokenAddress
       let vrfCoordinatorAddress

       if (chainId == 31337) {
              let linkToken = await get('LinkToken')
              let VRFCoordinatorMock = await get('VRFCoordinatorMock')
              linkTokenAddress = linkToken.address
              vrfCoordinatorAddress = VRFCoordinatorMock.address
              additionalMessage = " --linkaddress " + linkTokenAddress
       } else {
              linkTokenAddress = networkConfig[chainId]['linkToken']
              vrfCoordinatorAddress = networkConfig[chainId]['vrfCoordinator']
       }
       const keyHash = networkConfig[chainId]['keyHash']
       const fee = networkConfig[chainId]['fee']
       args = [vrfCoordinatorAddress, linkTokenAddress, keyHash, fee]
       log("----------------------------------------------------")
       const RandomSVG = await deploy('RandomSVG', {
              from: deployer,
              args: args,
              log: true
       })
       const accounts = await hre.ethers.getSigners()
       const signer = accounts[0]
       const randomSVGcontract = await ethers.getContractFactory("RandomSVG")
       const randomSVG = new ethers.Contract(RandomSVG.address, randomSVGcontract.interface, signer) //
       const NetworkName = networkConfig[chainId]['name']
       log(`Verify with: /n npx hardhat verify --network${NetworkName} ${RandomSVG.address} ${args.toString().replace(/,/g," ")}`)
       //find with link
       let networkId = await getNetworkIdFromName(network.name)
       log(networkId)
       const linkTokenContract = await ethers.getContractFactory("LinkToken")
       const fundAmount = networkConfig[networkId]['fundAmount']

       const linkToken = new ethers.Contract(linkTokenAddress, linkTokenContract.interface, signer)
       let fund_Tx = await linkToken.transfer(RandomSVG.address, fundAmount)
       await fund_Tx.wait(1)
       log("Let's create an NFT now!")

       let create_tx = await randomSVG.createRandomSVG({ gasLimit: 2000000})
        let receipt = await create_tx.wait(1)
       let tokenId = receipt.events[3].topics[2]
       log(`RandomSVG:${tokenId.toString()} `)
       log("Let's wait for the Chainlink VRF node to respond...")

       if(chainId!= 31337){

       }else{
              const VRFCoordinatorMock = await deployments.get('VRFCoordinatorMock')
              vrfCoordinator = await ethers.getContractAt('VRFCoordinatorMock', VRFCoordinatorMock.address,signer)
              let vrf_tx = await vrfCoordinator.callBackWithRandomness(receipt.events[3].topics[1],53445,randomSVG.address)
              await vrf_tx.wait(1)
              log('now finiashing Mint')
              let finish_tx = await randomSVG.finishMint(tokenId,{gasLimit:2000000})
              await finish_tx.wait(1)
              log('you can view tokenURI here:', await randomSVG.tokenURI(tokenId) )

       }

}
module.exports.tags = ['random','rsvg']