pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';


/***
 * @notice - This contract that ...
 **/
contract Distributor {

    constructor() public {}

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
    function redeemClaimWithFund() internal returns (bool) {}
    


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
