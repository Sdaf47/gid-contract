pragma solidity ^0.4.15;

import "./Structures.sol";
import "./GidCoin.sol";

contract CrowdFunding is GidCoin {
    address public crowdFundingOwner;
    uint public Financing;
    uint public minFinancing;
    uint public maxFinancing;
    uint public amountGas = 3000000;

    enum State {Disabled, PreICO, CompletePreICO, ICO, Enabled}

    uint public constant PRE_ICO_COST = 250;
    uint public constant ICO_COST = 200;

    uint public coefficient = 0;

    State   public state = State.Disabled;
    uint    public startCrowdFunding;
    uint    public endCrowdFunding;

    modifier enabledState {
        require(state == State.Enabled);
        _;
    }

    mapping (address => Funder) public funders;
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
        stake = value * coefficient;

        require(balances[msg.sender] + stake > balances[msg.sender]);
        require(stake > 0);

        Funder storage funder = funders[msg.sender];
        funder.amountTokens += tokens;
        funder.amountWei += valueWei;

        balances[msg.sender] += stake;

        Transfer(this, msg.sender, tokens);

        totalSupply += stake;
    }

    function startPreICO(
        address _crowdFundingOwner,
        uint _minFinancing,
        uint _maxFinancing,
        uint _crowdFundingDuration
    ) public onlyMaster {
        require(state == State.Disabled);
        crowdFundingStart = now;
        crowdFundingOwner = _crowdFundingOwner;
        minFinancing = _minFinancing;
        endCrowdFunding = now + (_crowdFundingDuration * 1 days);

        state = State.PreICO;
        coefficient = PRE_ICO_COST;

        delete funders;
        delete Financing;
    }

    function completePreICO() public onlyMaster {
        require(state == State.PreICO);
        require(now < endCrowdFunding);

        require(crowdFundingOwner.call.gas(amountGas).value(this.balance)());

        coefficient = ICO_COST;
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