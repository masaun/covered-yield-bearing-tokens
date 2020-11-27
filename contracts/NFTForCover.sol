pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/// [Note]: @openzeppelin/contracts v2.5.1
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { ERC721Full } from "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";  /// [Notes]: In case of @openzeppelin/contracts v2.5.1, "ERC721Full" is used
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";


/***
 * @notice - This contract that ...
 **/
contract NFTForCover is ERC721Full {
    using SafeMath for uint;

    uint8 public currentNFTForCoverId;

    constructor() public ERC721Full("Covered Yield Bearing Token", "CYB") {}


    /***
     * @notice - Mint a NFT for cover
     **/
    function mintNFTForCover(address to, string memory ipfsHash) public returns (uint _newNFTForCoverId) {
        uint newNFTForCoverId = getNextNFTForCoverId();
        currentNFTForCoverId++;
        _mint(to, newNFTForCoverId);
        _setTokenURI(newNFTForCoverId, ipfsHash);  /// [Note]: ipfsHash that cover related metadata is included
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
    function getNextNFTForCoverId() private view returns (uint nextNFTForCoverId) {
        return currentNFTForCoverId + 1;
    }

}
