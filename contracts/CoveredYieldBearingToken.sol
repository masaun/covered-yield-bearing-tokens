pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/// [Note]: @openzeppelin/contracts v2.5.1
import { ERC20Detailed } from "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import { ERC20Mintable } from "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

/// AAVE
import { ILendingPool } from "./aave/interfaces/ILendingPool.sol";
import { ILendingPoolCore } from "./aave/interfaces/ILendingPoolCore.sol";
import { ILendingPoolAddressesProvider } from "./aave/interfaces/ILendingPoolAddressesProvider.sol";
import { IAToken } from"./aave/interfaces/IAToken.sol";


/***
 * @notice - This contract that ...
 **/
contract CoveredYieldBearingToken is ERC20Detailed, ERC20Mintable {
    using SafeMath for uint;

    IERC20 dai;  // DAI stablecoin
    ILendingPool public lendingPool;
    ILendingPoolCore public lendingPoolCore;
    ILendingPoolAddressesProvider public lendingPoolAddressesProvider;
    IAToken public aDai;

    constructor(address _dai, address _aDai, address _lendingPool, address _lendingPoolCore, address _lendingPoolAddressesProvider) 
        public 
        ERC20Detailed("Covered Yield Bearing Token", "CYB", 18) 
    {
        dai = IERC20(_dai);      /// DAI
        aDai = IAToken(_aDai);   /// aDAI
        lendingPool = ILendingPool(_lendingPool);
        lendingPoolCore = ILendingPoolCore(_lendingPoolCore);
        lendingPoolAddressesProvider = ILendingPoolAddressesProvider(_lendingPoolAddressesProvider);
    }


    ///--------------------------------------------------------
    /// Main method
    ///--------------------------------------------------------

    /***
     * @notice - Creation of a new fully fungible token that is both yield bearing and covered
     * @notice - ipfsHash is a uploaded IPFS file that include a cover details
     **/
    function createCoveredYieldBearingToken(address userAddress, address _reserve, uint256 _amount, uint16 _referralCode) public returns (bool) {
        /// Transfer from the Distributor contract to this contract
        dai.transferFrom(msg.sender, address(this), _amount);

        /// Bearing yield with cDAI
        lendToCompound();

        /// Bearing yield with aDAI
        lendToAave(_reserve, _amount, _referralCode);

        /// Mint CYB (Covered Yield Bearing Token)
        uint aDAIBalance = aDaiBalance();
        mint(aDAIBalance);   

        /// Transfer CYB (Covered Yield Bearing Token) into a user
        uint CYBBalance = cybBalance();
        //transfer(userAddress, CYBBalance);
        aDai.transfer(userAddress, CYBBalance); /// [Note]: Test
    }


    ///--------------------------------------------------------
    /// Lending pool related method
    ///--------------------------------------------------------

    /***
     * @notice - Lend DAI into compound (and recieve cDAI)
     **/
    function lendToCompound() public returns (bool) {}
    

    /***
     * @notice - Lend DAI into AAVE's lending pool (and recieve aDAI)
     **/
    function lendToAave(address _reserve, uint256 _amount, uint16 _referralCode) public returns (bool) {
        /// Approve LendingPool contract to transfer DAI into the LendingPool
        dai.approve(lendingPoolAddressesProvider.getLendingPoolCore(), _amount);

        /// Deposit DAI (after that, this contract receive aDAI from lendingPool)
        lendingPool.deposit(_reserve, _amount, _referralCode);
    }


    ///--------------------------------------------------------
    /// Interest bearing token with AAVE
    ///--------------------------------------------------------

    // get DAI balance of this contract
    function daiBalance() public view returns (uint256) {
        return dai.balanceOf(address(this));
    }

    // get aDAI balance of this contract
    function aDaiBalance() public view returns (uint256) {
        return aDai.balanceOf(address(this));
    }

    // get CYB (Covered Yield Bearing Token) balance of this contract
    function cybBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    // get CYB (Covered Yield Bearing Token) balance of a specified wallet address
    function cybBalanceOf(address walletAddress) public view returns (uint256) {
        return balanceOf(walletAddress);
    }

    // mint the covered yield bearing token (CYB)
    // @param amount aDAI amount
    function mint(uint256 aDAIAmount) public {
        _mint(address(this), aDAIAmount);
    }

    // redeem pool tokens for DAI
    // @param CYB (Covered Yield Bearing Token) amonut
    function redeem(address userAddress, uint256 CYBAmount) public {
        /// CYB is transferred from the Distributor contract to this contract
        transferFrom(msg.sender, address(this), CYBAmount);
        require(cybBalanceOf(msg.sender) >= CYBAmount, "Not enough CYB (Covered Yield Bearing Token) balance");
    
        /// Burn pool tokens (CYB == Covered Yield Bearing Token)
        _burn(userAddress, CYBAmount);

        /// Redeem method call and receive DAI
        aDai.redeem(CYBAmount);
        
        /// Transfer DAI to sender
        dai.transfer(userAddress, daiBalance());
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
