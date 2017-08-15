pragma solidity ^0.4.15;

import "./Structures.sol";
import "./GidCoin.sol";

contract CrowdFunding is GidCoin {
    address public master;
    uint public Financing;
    uint public minFinancing;
    uint public amountGas = 3000000;

    uint256 constant TEAM_STAKE = 30000000;
    uint256 constant PARTNERS_STAKE = 15000000;
    uint256 constant CONTRACT_COST = 5000000;

    uint256 public reservedCoins = TEAM_STAKE + PARTNERS_STAKE + CONTRACT_COST;

    enum State {Disabled, PreICO, CompletePreICO, ICO, Enabled}

    uint public coefficient = 0;

    State   public state = State.Disabled;
    uint    public startCrowdFunding;
    uint    public endCrowdFunding;
    uint    public endPreICO;

    modifier enabledState {
        require(state == State.Enabled);
        _;
    }

    address[] public funderList;
    mapping (address => Structures.Funder) public funders;
    mapping (uint => address) public fundersIterator;

    function CrowdFunding() payable {}

    function() payable {
        require(state == State.PreICO || state == State.ICO);
        require(now < endCrowdFunding);
        uint valueWei = msg.value;
        uint256 stake = valueWei / (1 ether) * coefficient;

        if (balances[master] - reservedCoins - stake <= 0) {
            stake = balances[master] - reservedCoins;
            valueWei = stake * (1 ether) / coefficient;
            Financing += valueWei;
            require(msg.sender.call.gas(amountGas).value(msg.value - valueWei)());
        } else {
            Financing += valueWei;
        }

        require(balances[msg.sender] + stake > balances[msg.sender]);
        require(balances[master] - reservedCoins - stake >= 0);
        require(stake > 0);

        Structures.Funder storage funder = funders[msg.sender];
        funder.amountTokens += stake;
        funder.amountWei += valueWei;

        balances[msg.sender] += stake;
        balances[master] -= stake;

        funderList.push(msg.sender);
        Transfer(this, msg.sender, stake);
    }

    function investFromFiat(address _investor, uint256 _valueWei) onlyMaster {
        uint256 stake = _valueWei / (1 ether) * coefficient;

        // is it possible
        require(balances[_valueWei] + stake > balances[_valueWei]);
        require(balances[master] - CONTRACT_COST - TEAM_STAKE - stake >= 0);
        require(stake > 0);

        // add / update funder`s stake
        Structures.Funder storage funder = funders[_investor];
        funder.amountTokens += stake;
        funder.amountWei += _valueWei;

        // add / update user balance
        balances[_investor] += stake;
        balances[master] -= stake;

        // push funder in iterator
        funderList.push(_investor);

        Transfer(this, _investor, stake);
    }

    function startPreICO(
        uint _minFinancing,
        uint _crowdFundingDuration,
        uint _preICODuration,
        uint _coefficient
    ) public onlyMaster {
        require(state == State.Disabled);
        startCrowdFunding = now;
        minFinancing = _minFinancing;
        endPreICO = now * _preICODuration;
        endCrowdFunding = now + (_crowdFundingDuration * 1 days);
        coefficient = _coefficient;

        state = State.PreICO;

        delete Financing;
    }

    function completePreICO() public onlyMaster {
        require(state == State.PreICO);
        require(now >= endPreICO);
        require(master.call.gas(amountGas).value(this.balance)());

        state = State.CompletePreICO;
    }

    function startICO(
        uint _coefficient
    ) public onlyMaster {
        require(state == State.CompletePreICO);
        require(now < endCrowdFunding);

        state = State.ICO;
    }

    function completeICO() public onlyMaster {
        require(state == State.ICO);

        if (minFinancing <= Financing) {
            // failed
            state = State.Disabled;
        } else {
            // successful crowdfunding
            require(master.call.gas(amountGas).value(this.balance)());
            state = State.Enabled;
        }
    }

    function changeGasAmount(uint _amountGas) onlyMaster {
        amountGas = _amountGas;
    }

    function refund() public {
        require(state == State.Disabled);
        uint value = funders[msg.sender].amountWei * 95 / 100;
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