require('dotenv').config();

const Tx = require('ethereumjs-tx').Transaction;
const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider(`https://kovan.infura.io/v3/${ process.env.INFURA_KEY }`);
const web3 = new Web3(provider);

/* Wallet */
const walletAddress1 = process.env.WALLET_ADDRESS_1;
const privateKey1 = process.env.PRIVATE_KEY_1;

/* Import contract addresses */
let contractAddressList = require('../addressesList/contractAddress/contractAddress.js');
let tokenAddressList = require('../addressesList/tokenAddress/tokenAddress.js');

/* Set up contract */
let CoveredYieldBearingToken = {};
CoveredYieldBearingToken = require("../../build/contracts/CoveredYieldBearingToken.json");
coveredYieldBearingTokenABI = CoveredYieldBearingToken.abi;
coveredYieldBearingTokenAddr = CoveredYieldBearingToken["networks"]["42"]["address"];    /// Deployed address on Kovan
coveredYieldBearingToken = new web3.eth.Contract(coveredYieldBearingTokenABI, coveredYieldBearingTokenAddr);


/***
 * @notice - Execute all methods
 **/
async function main() {
    await createCoveredYieldBearingToken();
}
main();


/*** 
 * @dev - Send createCoveredYieldBearingToken()
 **/
async function createCoveredYieldBearingToken() {
    const userAddress = walletAddress1;
    const _reserve = tokenAddressList["Kovan"]["Aave"]["DAIaave"];
    const _amount = web3.utils.toWei('10', 'ether');  /// 10 DAI
    const _referralCode = 0;
    let inputData1 = await coveredYieldBearingToken.methods.createCoveredYieldBearingToken(userAddress, _reserve, _amount, _referralCode).encodeABI();
    let transaction1 = await sendTransaction(walletAddress1, privateKey1, coveredYieldBearingTokenAddr, inputData1);
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
            value:    web3.utils.toHex(web3.utils.toWei('0.01', 'ether')),  /// [Note]: 0.01 ETH as a msg.value
            gasLimit: web3.utils.toHex(2100000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('100', 'gwei')),   /// [Note]: Gas Price is 100 Gwei 
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
