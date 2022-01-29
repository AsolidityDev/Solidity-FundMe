from brownie import accounts, config, network, MockV3Aggregator
from web3 import Web3


DECIMALS = 8
STARTING_PRICE = 200000000000

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache_local"]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork-dev"]


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mock():
    print(f"The active network is {network.show_active()}")
    print("Deploying mock...")
    if len(MockV3Aggregator) <= 0:
        mock_aggregator = MockV3Aggregator.deploy(
            DECIMALS, Web3.toWei(STARTING_PRICE, "ether"), {"from": accounts[0]}
        )
    print("Mock deployed")
