pragma solidity ^0.5.0;
//pragma solidity 0.6.10;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * LendingPool Contract for Chainlink workshop 
 * Assumptions & Constraints:
 * - TUSD is always worth $1
 * - Ignore Leap Years
 * - Fixed interest rate on borrowing
 * - Can't withdraw if pool lacks liquidity
 * - No reserve
 */
contract ICoveredYieldBearingToken is IERC20 {

    // get TUSD balance of this contract
    function balance() public view returns (uint256);

    // get price of interest bearing token
    function exchangeRate() public view returns (uint256);

    // mint interest bearing TUSD
    // @param amount TUSD amount
    function mint(uint256 amount) public;

    // redeem pool tokens for TUSD
    // @param amount zToken amonut
    function redeem(uint256 amount) public;

    // deposit LINK to use as collateral to borrow
    function deposit(uint256 amount) public;

    // withdraw LINK used as collateral
    // could cause user to be undercollateralized
    function withdraw(uint256 amount) public;

    // borrow TUSD using LINK as collateral
    function borrow(uint256 amount) public;

    // repay TUSD debt
    function repay(uint256 amount) public;

    // update on changes to user account
    function _updateAccount(address account) internal;

    // update oracle prices and total interest earned
    function update() public;

    // liquidate account ETH if below threshold
    function liquidate(address account, uint256 amount) public;
}
