// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract DEXimitation {
    address payable public owner;

    address private constant aaveDAIAddress = 0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33;
    address private constant aaveUSDCAddress = 0x9FD21bE27A2B059a288229361E2fA632D8D2d074;

    IERC20 private constant DAI = IERC20(aaveDAIAddress);
    IERC20 private constant USDC = IERC20(aaveUSDCAddress);

    constructor() {
        owner = payable(msg.sender);
    }

    function buyDAI(uint256 _amountUSDC) external {
        require(_amountUSDC > 0, "Input must be greater than 0");
        uint256 allowance = USDC.allowance(msg.sender, address(this));
        require(allowance >= _amountUSDC, "Check the token alloawnce");

        uint256 daiToReceive = ((_amountUSDC / 90) * 100) * (10 ** 12);
        USDC.transferFrom(msg.sender, address(this), _amountUSDC);
        DAI.transfer(msg.sender, daiToReceive);
    }

    function sellDAI(uint256 _amountDAI) external {
        require(_amountDAI > 0, "Input must be greater than 0");
        uint256 allowance = DAI.allowance(msg.sender, address(this));
        require(allowance >= _amountDAI, "Check the token alloawnce");

        uint256 usdcToReceive = _amountDAI / (10 ** 12);
        DAI.transferFrom(msg.sender, address(this), _amountDAI);
        USDC.transfer(msg.sender, usdcToReceive);
    }

    function buyUSDC(uint256 _amountDAI) external {
        require(_amountDAI > 0, "Input must be greater than 0");
        uint256 allowance = DAI.allowance(msg.sender, address(this));
        require(allowance >= _amountDAI, "Check the token alloawnce");

        uint256 usdcToReceive = ((_amountDAI / 90) * 100) / (10 ** 12);
        DAI.transferFrom(msg.sender, address(this), _amountDAI);
        USDC.transfer(msg.sender, usdcToReceive);
    }

    function sellUSDC(uint256 _amountUSDC) external {
        require(_amountUSDC > 0, "Input must be greater than 0");
        uint256 allowance = USDC.allowance(msg.sender, address(this));
        require(allowance >= _amountUSDC, "Check the token alloawnce");

        uint256 daiToReceive = _amountUSDC * (10 ** 12);
        USDC.transferFrom(msg.sender, address(this), _amountUSDC);
        DAI.transfer(msg.sender, daiToReceive);
    }
}