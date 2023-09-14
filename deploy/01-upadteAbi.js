const { frontEndContractsFile, frontEndAbiFile } = require("../helper-hardhat-config")
const fs = require("fs")
const { network } = require("hardhat")
require("dotenv").config()
module.exports = async () => {
    if(process.env.UPDATE_FRONT_END){
        console.log("Abi......")
        await updateContractAddresses()
        await updateAbi()
        console.log("Abi updated")
    }
    
    
}
async function updateAbi() {
    const phrtoken = await ethers.getContract("PHRtoken")
    console.log(phrtoken)
    fs.writeFileSync(frontEndAbiFile, phrtoken.interface.format(ethers.utils.FormatTypes.json))
}
async function updateContractAddresses() {
    const phr = await ethers.getContract("PHRtoken")
    console.log(phr)
    const contractAddresses = JSON.parse(fs.readFileSync(frontEndContractsFile, "utf8"))
    if (network.config.chainId.toString() in contractAddresses) {
        if (!contractAddresses[network.config.chainId.toString()].includes(phr.address)) {
            contractAddresses[network.config.chainId.toString()].push(phr.address)
        }
    } else {
        contractAddresses[network.config.chainId.toString()] = [phr.address]
    }
    fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses))
    console.log("done ca")
}

module.exports.tags = ["all", "updateAbi"]