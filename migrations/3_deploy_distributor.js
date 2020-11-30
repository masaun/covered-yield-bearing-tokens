const Distributor = artifacts.require("Distributor");
const CoveredYieldBearingToken = artifacts.require("CoveredYieldBearingToken");

//@dev - Import from exported file
var contractAddressList = require('./addressesList/contractAddress/contractAddress.js');
var tokenAddressList = require('./addressesList/tokenAddress/tokenAddress.js');
var walletAddressList = require('./addressesList/walletAddress/walletAddress.js');

const _dai = tokenAddressList["Kovan"]["Aave"]["DAIaave"];
const _pool1 = contractAddressList["Kovan"]["NexusMutual"]["Pool1"][0];
const _quotation = contractAddressList["Kovan"]["NexusMutual"]["Quotation"][0];
const _coveredYieldBearingToken = CoveredYieldBearingToken.address;

module.exports = async function (deployer) {
    await deployer.deploy(Distributor, _dai, _pool1, _quotation, _coveredYieldBearingToken);
};
