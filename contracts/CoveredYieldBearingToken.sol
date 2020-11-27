pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/// [Note]: @openzeppelin/contracts v2.5.1
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { ERC721Full } from "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";  /// [Notes]: In case of @openzeppelin/contracts v2.5.1, "ERC721Full" is used
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";


/***
 * @notice - This contract that ...
 **/
contract CoveredYieldBearingToken is ERC721Full {
    using SafeMath for uint;

    uint8 public currentCoveredYieldBearingTokenId;

    constructor() public ERC721Full("Covered Yield Bearing Token", "CYB") {}

    function mint(address to, string memory ipfsHash) public returns (uint _newAuthTokenId) {
        uint newCoveredYieldBearingTokenId = getNextCoveredYieldBearingTokenId();
        currentCoveredYieldBearingTokenId++;
        _mint(to, newCoveredYieldBearingTokenId);
        _setTokenURI(newCoveredYieldBearingTokenId, ipfsHash);  /// [Note]: ipfsHash that cover related metadata is included
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
    function getNextCoveredYieldBearingTokenId() private view returns (uint nextCoveredYieldBearingTokenId) {
        return currentCoveredYieldBearingTokenId + 1;
    }

}
