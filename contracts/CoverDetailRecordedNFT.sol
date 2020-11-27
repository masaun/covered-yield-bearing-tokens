pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/// [Note]: @openzeppelin/contracts v2.5.1
import { ERC721Full } from "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";  /// [Notes]: In case of @openzeppelin/contracts v2.5.1, "ERC721Full" is used
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";


/***
 * @notice - This contract that ...
 **/
contract CoverDetailRecordedNFT is ERC721Full {
    using SafeMath for uint;

    uint8 public currentCoverDetailRecordedNFTId;

    constructor() public ERC721Full("Cover Detail Recorded NFT", "CDR") {}


    /***
     * @notice - Mint a NFT for cover
     **/
    function mintCoverDetailRecordedNFT(address to, string memory ipfsHash) public returns (uint _newCoverDetailRecordedNFTId) {
        uint newCoverDetailRecordedNFTId = getNextCoverDetailRecordedNFTId();
        currentCoverDetailRecordedNFTId++;
        _mint(to, newCoverDetailRecordedNFTId);
        _setTokenURI(newCoverDetailRecordedNFTId, ipfsHash);  /// [Note]: ipfsHash that cover related metadata is included
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
    function getNextCoverDetailRecordedNFTId() private view returns (uint nextCoverDetailRecordedNFTId) {
        return currentCoverDetailRecordedNFTId + 1;
    }

}
