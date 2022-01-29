from brownie import FundMe, accounts, config, network


def read_contract():
    # [-1] to retrieve the latest contract deployed on the network
    if network.show_active() == "development":
        fund_me = FundMe[-1]
        print(fund_me.getprice())


def main():
    read_contract()
