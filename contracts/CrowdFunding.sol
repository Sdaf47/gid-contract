pragma solidity ^0.4.15;

import "./Structures.sol";
import "./GidCoin.sol";

contract CrowdFunding is GidCoin {
    address public master;
    uint public Financing;
    uint public minFinancing;
    uint public amountGas = 3000000;

    uint256 constant teamStake      = 30000000;
    uint256 constant partnersStake  = 15000000;
    uint256 constant contractCost   = 5000000;

    uint256 public reservedCoins = teamStake + partnersStake + contractCost;

    enum State {Disabled, PreICO, ICO, Enabled}

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

        Transfer(this, msg.sender, stake);
    }

    function startPreICO(
        uint _minFinancing,
        uint _crowdFundingDuration,
        uint _coefficient
    ) public onlyMaster {
        require(state == State.Disabled);
        startCrowdFunding = now;
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

        require(master.call.gas(amountGas).value(this.balance)());

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