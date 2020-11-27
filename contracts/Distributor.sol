pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { CoverDetailRecordedNFT } from "./CoverDetailRecordedNFT.sol";


/***
 * @notice - This contract that ...
 **/
contract Distributor is CoverDetailRecordedNFT {

    IERC20 public dai;

    constructor(address _dai) public CoverDetailRecordedNFT() {
        dai = IERC20(_dai);
    }


    /***
     * @notice - Distributor contracts take input from an end user
     *         - a distributor contracts purchase cover on Nexus => return an NFT to the user representing the cover details.
     * @notice - "coverDetail" is IPFSHash 
     **/
    function purchaseCover(uint period, uint daiAmount, string memory coverDetail) public returns (bool) {
        /// [Step1]: Recieve input value from an end user

        /// [Step2]: a distributor contracts purchase cover on Nexus
        dai.transferFrom(msg.sender, address(this), daiAmount);

        /// [Step3]: Recieve an NFT as a return to the user representing the cover details.
        uint8 newCoverDetailRecordedNFTId = mintCoverDetailRecordedNFT(msg.sender, coverDetail);
        //CoverDetailRecordedNFT coverDetailRecordedNFT = new CoverDetailRecordedNFT();

    }


    /***
     * @notice - Claims can be submitted via the distributor contract by returning the NFT.
     *           (this creates a claim assessment item for Nexus Claims Assessors who then vote on claims)
     **/
    function claim() public returns (bool) {
        redeemClaimWithFund();
    }


    /***
     * @notice - Assuming the claim is paid the funds are transferred to the Distributor and can be redeemed by the end user.
     **/
    function redeemClaimWithFund() internal returns (bool) {
        uint fundedAmount;
    }
    


    ///------------------------------------------------------------
    /// Internal functions
    ///------------------------------------------------------------



    ///------------------------------------------------------------
    /// Getter functions
    ///------------------------------------------------------------
 


    ///------------------------------------------------------------
    /// Private functions
    ///------------------------------------------------------------


}
