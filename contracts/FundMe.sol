// SDPX-license-identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    // mapping address to amount funded to keep track of each funding per address
    mapping(address => uint256) public addressToAmountFunded;
    // list of all funders
    address[] public funders;
    // owner of the contract
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function fund() public payable {
        // min $50
        uint256 minUSD = 50 * 10**18;
        // check min funds sent
        require(
            getConversionRate(msg.value) >= minUSD,
            "You need to spend more ETH"
        );
        // map funds to sender and push to list of funders
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        // transfer all funds to owner address. note that the onlyOwner modifier will be called first
        msg.sender.transfer(address(this).balance);
        // looping through our funders to reset their balance to 0, as all has been transfered
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //
        funders = new address[](0);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // call the interface and create pricefeed object
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        // we only retrieve answer from the pricefeed function then return it
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //uint256 answer = 238890500000;
        return uint256(answer * 10000000000);
    }

    function getEntranceFee() public view returns (uint256) {
        //minimumusd
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
}
