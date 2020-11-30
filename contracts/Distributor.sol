pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Pool1 } from "./nexus-mutual/modules/capital/Pool1.sol";
import { Quotation } from "./nexus-mutual/modules/cover/Quotation.sol";

import { CoveredYieldBearingToken } from "./CoveredYieldBearingToken.sol";
import { CoverDetailRecordedNFT } from "./CoverDetailRecordedNFT.sol";


/***
 * @notice - Distributor contracts take input from an end user, then purchase cover on Nexus and return an NFT to the user representing the cover details.
 **/
contract Distributor is CoverDetailRecordedNFT {

    IERC20 public dai;
    Pool1 public pool1;
    Quotation public quotation;
    CoveredYieldBearingToken public coveredYieldBearingToken;

    address DAI_ADDRESS;

    constructor(address _dai, address payable _pool1, address _quotation, address _coveredYieldBearingToken) 
        public 
        CoverDetailRecordedNFT() 
    {
        dai = IERC20(_dai);
        pool1 = Pool1(_pool1);
        quotation = Quotation(_quotation);
        coveredYieldBearingToken = CoveredYieldBearingToken(_coveredYieldBearingToken);

        DAI_ADDRESS = _dai;
    }


    /***
     * @notice - Distributor contracts take input from an end user
     *         - a distributor contracts purchase cover on Nexus => return an NFT to the user representing the cover details.
     * @notice - "coverDetail" is IPFSHash 
     **/
    function purchaseCover(
        uint daiAmount,             /// [Note]: This is payment fees for buying a cover with DAI
        string memory coverDetail,  /// [Note]: This is ipfsHash that a cover detail is recorded
        address smartCAdd,
        bytes4 coverCurr,
        uint[] memory coverDetails,
        uint16 coverPeriod,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        /// [Step1]: Recieve payment fees (DAI) from input value of an end user
        dai.transferFrom(msg.sender, address(this), daiAmount);

        /// [Step2]: a distributor contracts purchase cover on Nexus
        pool1.makeCoverUsingCA(smartCAdd, coverCurr, coverDetails, coverPeriod, _v, _r, _s);

        /// [Step3]: Recieve an NFT as a return to the user representing the cover details.
        uint8 newCoverDetailRecordedNFTId = mintCoverDetailRecordedNFT(msg.sender, coverDetail);
        //CoverDetailRecordedNFT coverDetailRecordedNFT = new CoverDetailRecordedNFT();

        /// [Step4]: Generate CYB (covered yield bearing token) and transfer them into a user
        coveredYieldBearingToken.createCoveredYieldBearingToken(DAI_ADDRESS, daiAmount, 0);
        uint CYBBalance = coveredYieldBearingToken.cybBalanceOf(address(this));
        coveredYieldBearingToken.transfer(msg.sender, CYBBalance);
    }


    /***
     * @notice - Claims can be submitted via the distributor contract by returning the NFT.
     *           (this creates a claim assessment item for Nexus Claims Assessors who then vote on claims)
     **/
    function submitClaim(uint8 coverDetailRecordedNFTId, address userAddress, uint CYBAmount) public returns (bool) {
        require (msg.sender > ownerOf(coverDetailRecordedNFTId), "Caller is not owner of this cover");

        /// [Step1]: Redeem a NFT (that are proof of cover) with fund 
        redeemClaimWithFund(userAddress, CYBAmount);

        /// [Step2]: Burn a NFT that are proof of cover (This is equal to that NFT is returned)
        _burn(uint256(coverDetailRecordedNFTId));
    }


    /***
     * @notice - Assuming the claim is paid the funds are transferred to the Distributor and can be redeemed by the end user.
     **/
    function redeemClaimWithFund(address userAddress, uint CYBAmount) internal returns (bool) {
        coveredYieldBearingToken.redeem(userAddress, CYBAmount);
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
