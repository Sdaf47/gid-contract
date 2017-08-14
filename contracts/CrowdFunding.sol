pragma solidity ^0.4.15;

import "./Structures.sol";
import "./GidCoin.sol";

contract CrowdFunding is GidCoin {
    address public crowdFundingOwner;
    uint public Financing;
    uint public minFinancing;
    uint public maxFinancing;
    uint public etherPrice;
    uint public amountGas = 3000000;
    // Financing   = 50 000 000

    // totalSupply = 100 000 000
    // investors   = 50 000 000
    // partners    = 19 000 000
    // team        = 30 000 000

    enum State {Disabled, PreICO, ICO, Enabled}

    uint public constant ICO_COST = 200;

    uint public coefficient = 0;

    State   public state = State.Disabled;
    uint    public startCrowdFunding;
    uint    public endCrowdFunding;

    modifier enabledState {
        require(state == State.Enabled);
        _;
    }

    mapping (address => Structures.Funder) public funders;
    mapping (uint => address) public fundersIterator;

    function CrowdFunding() payable {}

    function() payable {
        require(state == State.PreICO || state == State.ICO);
        require(now < endCrowdFunding);
        uint valueWei = msg.value;
        uint value = valueWei / (1 ether);

        if (Financing + value > maxFinancing) {
            value = maxFinancing - Financing;
            valueWei = value * (1 ether) / etherPrice;
            require(msg.sender.call.gas(amountGas).value(msg.value - valueWei)());
            Financing = maxFinancing;
        } else {
            Financing += value;
        }
        uint256 stake = value * coefficient;

        require(balances[msg.sender] + stake > balances[msg.sender]);
        require(stake > 0);

        Structures.Funder storage funder = funders[msg.sender];
        funder.amountTokens += stake;
        funder.amountWei += valueWei;

        balances[msg.sender] += stake;

        Transfer(this, msg.sender, stake);

        totalSupply += stake;
    }

    function startPreICO(
    uint _minFinancing,
    uint _maxFinancing,
    uint _crowdFundingDuration,
    uint _coefficient
    ) public onlyMaster {
        require(state == State.Disabled);
        startCrowdFunding = now;
        crowdFundingOwner = master;
        minFinancing = _minFinancing;
        endCrowdFunding = now + (_crowdFundingDuration * 1 days);
        coefficient = _coefficient;

        state = State.PreICO;

        delete Financing;
    }

    function startICO(
    uint _coefficient
    ) public onlyMaster {
        require(state == State.PreICO);
        require(now < endCrowdFunding);

        require(crowdFundingOwner.call.gas(amountGas).value(this.balance)());

        state = State.ICO;
    }

    function completeICO() public onlyMaster {
        // TODO
    }

    function changeGasAmount(uint _amountGas) onlyMaster {
        amountGas = _amountGas;
    }

    function refund() public {
        require(state == State.Disabled);
        uint value = funders[msg.sender].amountWei;
        if (value > 0) {
            delete funders[msg.sender];
            require(msg.sender.call.gas(amountGas).value(value)());
        }
    }

    function timeLeftTokensSale() public constant returns (uint t) {
        require(state == State.PreICO || state == State.ICO);
        if (now > endCrowdFunding) {
            t = 0;
        } else {
            t = endCrowdFunding - now;
        }
    }
}