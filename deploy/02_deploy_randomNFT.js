
let { networkConfig, getNetworkIdFromName } = require('../helper-hardhat-config')
module.exports = async ({
       getNamedAccounts,
       deployments,
       getChainId
}) => {


       const { deploy, log } = deployments
       const { deployer } = await getNamedAccounts()
       const chainId = await getChainId()
       log("----------------------------------------------------")
      let linkTokenAddress,vrfCoordinatorAddress
       if(chainId=31337){
              let LinkToken = await get('LinkToken');
              let vrfCoordinator = await get('VRFCoordinatorMock');
              vrfCoordinatorAddress = vrfCoordinator.address
       }
       else{
              linkTokenAddress = networkConfig[chainId]['linkToken']
              vrfCoordinatorAddress = networkConfig[chainId]['vrfCoordinator']
       }
       const keyHash = networkConfig[chainId]['keyHash']
       const fee = networkConfig[chainId]['fee']
       let args = [vrfCoordinatorAddress, linkTokenAddress, keyHash, fee]
       log("----------------------------------------------------")
       const RandomSvg = await deploy('RandomSVG',{
              from:deployer,
              args:args,
              log:true
       })
       
}