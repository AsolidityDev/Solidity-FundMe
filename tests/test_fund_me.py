from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account
from scripts.deploy import deploy_fund_me
from brownie import network, accounts, FundMe, exceptions
import pytest


def test_can_fund_and_withdraw():
    account = get_account()
    deploy_fund_me()
    fund_me = FundMe[-1]
    entrance_fee = fund_me.getEntranceFee() + 100
    tx = fund_me.fund({"from": account, "value": entrance_fee})
    tx.wait(1)
    # assert that we are able to fund the contract
    assert fund_me.addressToAmountFunded(account.address) == entrance_fee

    tx2 = fund_me.withdraw({"from": account})
    tx2.wait(1)
    # assert that we are able to withdraw from the contract, which means amount funded is 0
    assert fund_me.addressToAmountFunded(account.address) == 0


def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("only for local testing")

    account = get_account()
    deploy_fund_me()
    fund_me = FundMe[-1]
    bad_actor = accounts[1]
    # as bad actor is not allowed to withdraw, tx will fail and revert. catching this will pass the test
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withdraw({"from": bad_actor})
