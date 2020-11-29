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

/// Chainlink for solidity v0.5
import { AggregatorV3Interface } from "./chainlink/AggregatorV3Interface.sol";

import { ICoveredYieldBearingToken } from "./interfaces/ICoveredYieldBearingToken.sol";


/***
 * @notice - This contract that ...
 **/
contract CoveredYieldBearingToken is ICoveredYieldBearingToken, ERC20Detailed, ERC20Mintable {
    using SafeMath for uint;

    /* contracts */    
    IERC20 dai;  // DAI stablecoin
    IERC20 link; // chainlink coin
    AggregatorV3Interface internal linkPriceFeed; // chainlink aggregator

    ILendingPool public lendingPool;
    ILendingPoolCore public lendingPoolCore;
    ILendingPoolAddressesProvider public lendingPoolAddressesProvider;
    IAToken public aDai;
    
    /* variables */
    uint256 rate;           // interest rate
    uint256 ratio;          // collateralization ratio
    uint256 index;          // tracks interest owed by borrowers
    uint256 linkPrice;      // last price of ETH
    uint256 totalBorrow;    // total DAI borrowed
    uint256 totalCollateral;// total LINK collateral
    uint256 lastUpdated;    // time last updated
    
    /* constants */
    // minimal interval to update interest earned
    uint256 constant INTERVAL = 1 minutes;
    // total intervals ignoring leap years
    uint256 constant TOTAL_INTERVALS = 525600;  
    
    /* structures */
    // tuple to represent borrow checkpoint
    // this is used to calculate how much interest an account owes
    struct Checkpoint {
        uint256 balance;
        uint256 index;
    }

    struct User {
        // DAI amount borrowed
        uint256 borrow;
        // ETH collateral amount
        uint256 collateral;
        // stores last updated balance & index
        Checkpoint checkpoint;
    }
    
    /* mappings */    
    // store users of this smart contract
    mapping(address => User) users;

    constructor(address _dai, address _link, address _linkPriceFeed, address _lendingPool, address _lendingPoolCore, address _lendingPoolAddressesProvider, address _aDai) 
        public 
        ERC20Detailed("Covered Yield Bearing Token", "CYB", 18) 
    {
        dai = IERC20(_dai);    /// DAI
        link = IERC20(_link);  /// LINK
        linkPriceFeed = AggregatorV3Interface(_linkPriceFeed);  /// Chainlink PriceFeed (LINK/USD)
        totalBorrow = 0;
        totalCollateral = 0;
        rate = 100000000000000000;      // 0.1
        ratio = 15000000000000000000;   // 1.5

        /// AAVE
        lendingPool = ILendingPool(_lendingPool);
        lendingPoolCore = ILendingPoolCore(_lendingPoolCore);
        lendingPoolAddressesProvider = ILendingPoolAddressesProvider(_lendingPoolAddressesProvider);
        aDai = IAToken(_aDai);
    }




    ///--------------------------------------------------------
    /// Previous methos
    ///--------------------------------------------------------

    /***
     * @notice - Creation of a new fully fungible token that is both yield bearing and covered
     * @notice - ipfsHash is a uploaded IPFS file that include a cover details
     **/
    function createCoveredYieldBearingToken(address _reserve, uint256 _amount, uint16 _referralCode) public returns (bool) {
        /// Bearing yield with cDAI
        lendToCompound();

        /// Bearing yield with aDAI        
        lendToAave(_reserve, _amount, _referralCode);
    }


    /***
     * @notice - Lend DAI into compound (and recieve cDAI)
     **/
    function lendToCompound() public returns (bool) {}
    

    /***
     * @notice - Lend DAI into AAVE (and recieve aDAI)
     **/
    function lendToAave(address _reserve, uint256 _amount, uint16 _referralCode) public returns (bool) {
        /// Transfer from wallet address
        dai.transferFrom(msg.sender, address(this), _amount);

        /// Approve LendingPool contract to move your DAI
        dai.approve(lendingPoolAddressesProvider.getLendingPoolCore(), _amount);

        /// Deposit DAI
        lendingPool.deposit(_reserve, _amount, _referralCode);
    }





    ///--------------------------------------------------------
    /// Interest bearing token with AAVE
    ///--------------------------------------------------------

    // get DAI balance of this contract
    function balance() public view returns (uint256) {
        return dai.balanceOf(address(this));
    }

    // get price of interest bearing token
    function exchangeRate() public view returns (uint256) {
        // exchange rate = (DAI balance + total borrowed) / supply
        totalBorrow.add(balance()).div(totalSupply());
    }

    // mint interest bearing DAI
    // @param amount DAI amount
    function mint(uint256 amount) public {
        require(dai.transferFrom(msg.sender, address(this), amount), "insufficient DAI");
        uint256 value = amount.div(exchangeRate());
        // amount of tokens based on total interest earned by pool
        _mint(msg.sender, value);
    }

    // redeem pool tokens for DAI
    // @param amount zToken amonut
    function redeem(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "not enough balance");
        require(balance().sub(amount) >= totalBorrow, "pool lacks liquidity");
        // calculate underlying value of pool tokens
        uint256 value = amount.mul(exchangeRate());
        // burn pool tokens
        _burn(msg.sender, amount);
        // transfer DAI to sender
        dai.transfer(msg.sender, value);
    }

    // deposit LINK to use as collateral to borrow
    function deposit(uint256 amount) public {
        require(link.transferFrom(msg.sender, address(this), amount), "insufficient LINK");
        User storage user = users[msg.sender];
        user.collateral.add(amount);
        totalCollateral.add(amount);
    }

    // withdraw LINK used as collateral
    // could cause user to be undercollateralized
    function withdraw(uint256 amount) public {
        User storage user = users[msg.sender];
        require(user.collateral >= amount, "insufficient collateral");
        totalCollateral.sub(amount);
        user.collateral.sub(amount);
    }

    // borrow DAI using LINK as collateral
    function borrow(uint256 amount) public {
        User storage user = users[msg.sender];
        require(amount >= balance(), "not enough liquidity to borrow");
        require(calculateRatio(user.borrow.add(amount), user.collateral) > ratio, "too much borrow");
        _updateAccount(msg.sender);
    }

    // repay DAI debt
    function repay(uint256 amount) public {
        User storage user = users[msg.sender];
        require(user.borrow <= amount, "cannot repay more than borrowed");
        require(dai.transferFrom(msg.sender, address(this), amount), "insufficient DAI to repay");
        user.borrow = user.borrow.sub(amount);
        _updateAccount(msg.sender);
    }

    function _debt(address account) internal view returns (uint256) {
        User storage user = users[account];
    }

    // public view to see amount owed
    function debt(address account) public view returns (uint256) {
        User storage user = users[msg.sender];
        return _debt(account);
    }

    function _updateAccount(address account) internal {
        // TODO
    }

    // update oracle prices and total interest earned
    function update() public {
        // only update if at least one interval has passed
        if (lastUpdated.add(INTERVAL) <= block.timestamp) {
            // calculate time passed
            uint256 passed = block.timestamp.sub(lastUpdated);
            // calculate intervals passed since last update
            uint256 time = passed.div(INTERVAL);

            // calculate period interest = 1 + r * t
            uint256 period = rate.mul(
                time.div(TOTAL_INTERVALS)
                .mul(rate)
                .add(1)
            );
            // update to current timestamp
            lastUpdated = block.timestamp;

            // update index
            index = index.mul(period);

            // update total borrow
            totalBorrow = totalBorrow.mul(period);

            updatePrice();
        }
    }

    // liquidate account ETH if below threshold
    function liquidate(address account, uint256 amount) public {
        update();
        User memory user = users[account];
        require(user.borrow !=0, "account has not borrowed");
        require(calculateRatio(user.borrow, user.collateral) < ratio, "account not undercollateralized");
        require(amount <= user.collateral, "amount too high to liquidate");
    }

    // fetch eth price from chainlink
    function fetchlinkPrice() public view returns (int256) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = linkPriceFeed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        return price;
    }

    function updatePrice() public {
        // cast to uint256 * add 10 decimals of precision
        linkPrice = uint256(fetchlinkPrice()).mul(10**10);
    }

    // calculate collateralization ratio
    function calculateRatio(uint256 borrow, uint256 collateral) public returns (uint256) {
        return borrow.div(collateral.mul(linkPrice));
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
