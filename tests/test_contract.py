import pytest
import brownie
from brownie import Test, accounts, Contract, Token

usdt_address = "0xdAC17F958D2ee523a2206206994597C13D831ec7"

@pytest.fixture
def token():
    return accounts[0].deploy(Token, "Test Token", "TST", 6, 1e18)

@pytest.fixture
def contract(token):
    contract = Test.deploy(token, accounts[0], {'from': accounts[0]})
    token.transfer(contract.address, 1e9, {'from': accounts[0]})
    return contract

def test_borrow(contract, token):
    # Check initial balance
    assert token.balanceOf(contract) == 1e9
    # borrow process
    borrowAmount = 1e6
    # borrow request from accounts[0]
    contract.borrow(borrowAmount, {'from': accounts[0]})
    # Check balance after deduction.
    assert token.balanceOf(contract) == (1e9-1e6)
    return borrowAmount,token.balanceOf(contract)
    

def test_repay(contract, token):
    borrowAmount, balanceAfterBorrow = test_borrow(contract, token)
    interestRate = 1.1
    token.approve(contract.address,interestRate*borrowAmount,{'from': accounts[0]})
    contract.repay({'from': accounts[0]})
    assert token.balanceOf(contract) == balanceAfterBorrow + interestRate*borrowAmount

def test_fail_to_borrow(contract, token):
    # borrow amount exceeds contract balance
    borrowAmount = token.balanceOf(contract) + 1
    with brownie.reverts("Insufficient fund balance"):
        contract.borrow(borrowAmount, {'from': accounts[0]})

def test_fail_to_repay(contract, token):
    borrowAmount, balanceAfterBorrow = test_borrow(contract, token)
    with brownie.reverts("no repayment required"):
        contract.repay({'from': accounts[0]})

def test_fail_to_repay_invalid_amount(contract, token):
    with brownie.reverts("Invalid Payment Amount"):
        contract.repay({'from': accounts[0]})





