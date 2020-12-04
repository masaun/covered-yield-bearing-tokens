require('dotenv').config();

const Tx = require('ethereumjs-tx').Transaction;
const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider(`https://kovan.infura.io/v3/${ process.env.INFURA_KEY }`);
const web3 = new Web3(provider);

/* Wallet */
const walletAddress1 = process.env.WALLET_ADDRESS_1;
const privateKey1 = process.env.PRIVATE_KEY_1;

const walletAddress2 = process.env.WALLET_ADDRESS_2;

/* Import contract addresses */
let contractAddressList = require('../addressesList/contractAddress/contractAddress.js');
let tokenAddressList = require('../addressesList/tokenAddress/tokenAddress.js');

/* Set up contract */
let Distributor = {};
Distributor = require("../../build/contracts/Distributor.json");
distributorABI = Distributor.abi;
distributorAddr = Distributor["networks"]["42"]["address"];    /// Deployed address on Kovan
distributor = new web3.eth.Contract(distributorABI, distributorAddr);

let CoveredYieldBearingToken = {};
CoveredYieldBearingToken = require("../../build/contracts/CoveredYieldBearingToken.json");
coveredYieldBearingTokenABI = CoveredYieldBearingToken.abi;
coveredYieldBearingTokenAddr = CoveredYieldBearingToken["networks"]["42"]["address"];    /// Deployed address on Kovan
coveredYieldBearingToken = new web3.eth.Contract(coveredYieldBearingTokenABI, coveredYieldBearingTokenAddr);

let IERC20 = {};
IERC20 = require("../../build/contracts/IERC20.json");
daiABI = IERC20.abi;
daiAddr = tokenAddressList["Kovan"]["Aave"]["DAIaave"];    /// Deployed address on Kovan
dai = new web3.eth.Contract(daiABI, daiAddr);


/***
 * @notice - Execute all methods
 **/
async function main() {
    await purchaseCover();
}
main();

/*** 
 * @dev - Purchase cover on Nexus Mutual
 **/
async function purchaseCover() {
    const daiAmount = web3.utils.toWei('10', 'ether');  /// 10 DAI
    const coverDetail = "QmWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t";  /// [Note]: This is ipfsHash that a cover detail is recorded
    const smartCAdd = "0x61460874a7196d6a22d1ee4922473664b3e95270";        /// [Note]: This is the target contract address of cover (e.g. COMP of compound on kovan)
    const coverCurr = web3.utils.toHex(tokenAddressList["Kovan"]["General"]["DAI"]);      /// [Note]: This is token address that pay for a cover (e.g. DAI)
    const coverDetails = [];
    const coverPeriod = [];
    const _v = "";
    const _r = "";
    const _s = "";

    /// Approve
    let inputData1 = await dai.methods.approve(distributorAddr, daiAmount).encodeABI();
    let transaction1 = await sendTransaction(walletAddress1, privateKey1, daiAddr, inputData1);

    /// Execution
    let inputData2 = await distributor.methods.purchaseCover(daiAmount, 
                                                                          coverDetail, 
                                                                          smartCAdd,
                                                                          coverCurr,
                                                                          coverDetails,
                                                                          coverPeriod,
                                                                          _v,
                                                                          _r,
                                                                          _s).encodeABI();
    let transaction2 = await sendTransaction(walletAddress1, privateKey1, distributor, inputData2);
}


/***
 * @notice - Sign and Broadcast the transaction
 **/
async function sendTransaction(walletAddress, privateKey, contractAddress, inputData) {
    try {
        const txCount = await web3.eth.getTransactionCount(walletAddress);
        const nonce = await web3.utils.toHex(txCount);
        console.log('=== txCount, nonce ===', txCount, nonce);

        /// Build the transaction
        const txObject = {
            nonce:    web3.utils.toHex(txCount),
            from:     walletAddress,
            to:       contractAddress,  /// Contract address which will be executed
            value:    web3.utils.toHex(web3.utils.toWei('0', 'ether')),  /// [Note]: 0 ETH as a msg.value
            gasLimit: web3.utils.toHex(2100000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('5', 'gwei')),   /// [Note]: Gas Price is 5 Gwei 
            //gasPrice: web3.utils.toHex(web3.utils.toWei('100', 'gwei')),   /// [Note]: Gas Price is 100 Gwei 
            data: inputData  
        }
        console.log('=== txObject ===', txObject)

        /// Sign the transaction
        privateKey = Buffer.from(privateKey, 'hex');
        let tx = new Tx(txObject, { 'chain': 'kovan' });  /// Chain ID = Kovan
        tx.sign(privateKey);

        const serializedTx = tx.serialize();
        const raw = '0x' + serializedTx.toString('hex');

        /// Broadcast the transaction
        const transaction = await web3.eth.sendSignedTransaction(raw);
        console.log('=== transaction ===', transaction)

        /// Return the result above
        return transaction;
    } catch(e) {
        console.log('=== e ===', e);
        return String(e);
    }
}
