const CoveredYieldBearingToken = artifacts.require("CoveredYieldBearingToken");

//@dev - Import from exported file
var contractAddressList = require('./addressesList/contractAddress/contractAddress.js');
var tokenAddressList = require('./addressesList/tokenAddress/tokenAddress.js');
var walletAddressList = require('./addressesList/walletAddress/walletAddress.js');

const _dai = tokenAddressList["Kovan"]["Aave"]["DAIaave"];
const _aDai = tokenAddressList["Kovan"]["Aave"]["aDAI"];
const _lendingPool = contractAddressList["Kovan"]["Aave"]["LendingPool"];
const _lendingPoolCore = contractAddressList["Kovan"]["Aave"]["LendingPoolCore"];
const _lendingPoolAddressesProvider = contractAddressList["Kovan"]["Aave"]["LendingPoolAddressesProvider"];

module.exports = async function (deployer) {
    await deployer.deploy(CoveredYieldBearingToken, _dai, _aDai, _lendingPool, _lendingPoolCore, _lendingPoolAddressesProvider);
};
