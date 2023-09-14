const { network, ethers } = require("hardhat")
const {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper-hardhat-config")
const {verify} = require("../utils/verify")
module.exports = async ({ getNamedAccounts, deployments }) => {
    console.log("Deploying.......")
    const {deploy, log} = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    console.log(chainId)
    console.log(deployer)
    const phrToken = await deploy("PHRtoken",{
        from: deployer,
        args: [],
        log: true,
        // waitConfirmations: network.config.blockConfirmations || 1,
    })
    console.log("Deployed........")
    console.log("Verifying.......")
    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){
        await verify(phrToken.address, [])
    }
    console.log("Verified..........")

}
module.exports.tags = ["all", "phr"]