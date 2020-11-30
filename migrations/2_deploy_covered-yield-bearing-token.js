const CoveredYieldBearingToken = artifacts.require("CoveredYieldBearingToken");

//@dev - Import from exported file
var contractAddressList = require('./addressesList/contractAddress/contractAddress.js');
var tokenAddressList = require('./addressesList/tokenAddress/tokenAddress.js');
var walletAddressList = require('./addressesList/walletAddress/walletAddress.js');

module.exports = async function (deployer) {
    await deployer.deploy(CoveredYieldBearingToken);
};
