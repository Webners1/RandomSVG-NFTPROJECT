const fs = require('fs')
let {networkConfig} = require('../helper-hardhat-config')

module.exports = async ({
       getNamedAccounts,
       deployments,
       getChainId
}) => {

       const { deploy, log } = deployments
       const { deployer } = await getNamedAccounts()
       const chainId = await getChainId()

       log("----------------------------------------------------")
       const MyNFT = await deploy('MyNFT', {
              from: deployer,
              log: true
       })
       log(`You have deployed an NFT contract to ${MyNFT.address}`)
       let file = './image/triangle.svg'
       let svg = fs.readFileSync(file,{encoding:'utf8'})
       
       const svgNFTContract = await ethers.getContractFactory('MyNFT')
       const accounts = await hre.ethers.getSigners()
       const signer = accounts[0]
       const myNFT = new ethers.Contract(MyNFT.address, svgNFTContract.interface,signer)
       const NetworkName = networkConfig[chainId]['name']
       log(`Verify with: /n npx hardhat verify --network${NetworkName}${myNFT.address}`)
       let tx = await myNFT.create(svg)
       let receipt = await tx.wait(1)
       log(`You made an NFT!!!`)
       log(`you can view token URI HERE!${await myNFT.tokenURI(0)}`)



}