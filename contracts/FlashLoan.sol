// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

interface IDEXimitation {
    function buyDAI(uint256 _amountUSDC) external;
    function sellDAI(uint256 _amountDAI) external;
    function buyUSDC(uint256 _amountDAI) external;
    function sellUSDC(uint256 _amountUSDC) external;
}

contract FlashLoan is FlashLoanSimpleReceiverBase {
    address payable public owner;
    IDEXimitation private immutable DEX;

    address private constant aaveDAIAddress = 0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33;
    address private constant aaveUSDCAddress = 0x9FD21bE27A2B059a288229361E2fA632D8D2d074;

    IERC20 private constant DAI = IERC20(aaveDAIAddress);
    IERC20 private constant USDC = IERC20(aaveUSDCAddress);

    constructor(address _addressProvider, address _dexAddress) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
        owner = payable(msg.sender);
        DEX = IDEXimitation(_dexAddress);
    }

    function simulateArbitrage(uint256 _amount) internal {
        USDC.approve(address(DEX), _amount);
        DEX.buyDAI(_amount);

        uint256 receivedDAI = DAI.balanceOf(address(this));

        DAI.approve(address(DEX), receivedDAI);
        DEX.sellDAI(receivedDAI);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        simulateArbitrage(amount);

        uint256 amountOwed = amount + premium;
        IERC20(asset).approve(address(POOL), amountOwed);
        
        return true;
    }

    function requestFlashLoan(address _asset, uint256 _amount) public {
        POOL.flashLoanSimple(address(this), _asset, _amount, "", 0);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external {
        require(msg.sender == owner, "Only the contract onwer can call this function");
        IERC20 token = IERC20(_tokenAddress);

        token.transfer(owner, token.balanceOf(address(this)));
    }

    receive() external payable {}
}