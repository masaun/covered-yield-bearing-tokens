pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/// [Note]: @openzeppelin/contracts v2.5.1
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";


/***
 * @notice - This contract that ...
 **/
contract CoveredYieldBearingToken {
    using SafeMath for uint;

    constructor() public {}


    /***
     * @notice - Creation of a new fully fungible token that is both yield bearing and covered
     * @notice - ipfsHash is a uploaded IPFS file that include a cover details
     **/
    function createCoveredYieldBearingToken(address to, string memory ipfsHash) public returns (uint _newCoveredYieldBearingTokenId) {
        /// [Step1]: Make a cover

        /// [Step3]: Bearing yield with aDAI and cDAI
        lendToCompound();
        lendToAave();

        /// [Step4]: Add a cover
    }


    /***
     * @notice - Lend DAI into compound (and recieve cDAI)
     **/
    function lendToCompound() public returns (bool) {}
    

    /***
     * @notice - Lend DAI into AAVE (and recieve aDAI)
     **/
    function lendToAave() public returns (bool) {}



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
