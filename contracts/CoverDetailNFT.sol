pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/// [Note]: @openzeppelin/contracts v2.5.1
import { ERC721Full } from "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";  /// [Notes]: In case of @openzeppelin/contracts v2.5.1, "ERC721Full" is used
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";


/***
 * @notice - This contract that ...
 **/
contract CoverDetailNFT is ERC721Full {
    using SafeMath for uint;

    uint8 public currentCoverDetailNFTId;

    constructor() public ERC721Full("Cover Detail Recorded NFT", "CDR") {}


    /***
     * @notice - Mint a NFT for cover
     **/
    function mintCoverDetailNFT(address to, string memory ipfsHash) public returns (uint8 _newCoverDetailNFTId) {
        uint8 newCoverDetailNFTId = getNextCoverDetailNFTId();
        currentCoverDetailNFTId++;
        _mint(to, uint256(newCoverDetailNFTId));
        _setTokenURI(uint256(newCoverDetailNFTId), ipfsHash);  /// [Note]: ipfsHash that cover related metadata is included

        return newCoverDetailNFTId;
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
    function getNextCoverDetailNFTId() private view returns (uint8 nextCoverDetailNFTId) {
        return currentCoverDetailNFTId + 1;
    }

}
