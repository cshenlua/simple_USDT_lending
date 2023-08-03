pragma solidity ^0.8.20;

import "./IERC20.sol";

contract Test {
    IERC20 private _token;
    // in basis points (equivalent to 10%)
    uint256 public borrowerInterestRateBasis = 1000;
    
    // Mapping for each unique address's lended amount
    mapping(address => uint256) private _amountBorrowed; 

    constructor(IERC20 token, address usdt) {
        _token = token;
    }

    // events
    event LogTransfer(address borrower, uint256 amount);
    event LogApproval(address borrower, uint256 amount);

    function borrow(uint amount) external {
        // Requested lending amount must be greater than zero.
        require(amount >= 10, "Amount must be greater than or equal to 10.");
        // Current balance. 
        uint256 currentBalance = _token.balanceOf(address(this));
        // Ensure that current balance is greater than requested loan amount. 
        require(amount <= currentBalance, "Insufficient fund balance");
        // Transfer specified lending amount to user.
        _token.transfer(msg.sender, amount);
        // emit LogTransfer event
        emit LogTransfer(msg.sender, amount);
        // Update lending amount borrowed info
        _amountBorrowed[msg.sender] += amount;
    }

    function repay() external {
        require(_amountBorrowed[msg.sender] >= 10, "Invalid Payment Amount");
        uint256 borrowedAmountAfterInterest = _amountBorrowed[msg.sender] + ((_amountBorrowed[msg.sender]*borrowerInterestRateBasis)/10000);
        require(_token.approve(msg.sender, borrowedAmountAfterInterest), "Repayment Not Approved");
        uint256 allowance = _token.allowance(msg.sender, address(this));
        require(allowance == borrowedAmountAfterInterest, "no repayment required");
        // Ensure the user has enough balance to repay with interest. 
        require(_token.transferFrom(msg.sender, address(this), borrowedAmountAfterInterest),"Repayment unsuccessful");
        // emit LogTransfer event
        emit LogTransfer(msg.sender, borrowedAmountAfterInterest);
        _amountBorrowed[msg.sender] = 0;
    }
}