pragma solidity ^0.4.4;

import "./Structures.sol";
import "./GidCoin.sol";

contract CrowdFunding is GidCoin {
    uint public Funding;
    uint public minFunding;

    uint256 constant TEAM_STAKE = 30000000000000000000000000;
    uint256 constant PARTNERS_STAKE = 15000000000000000000000000;
    uint256 constant CONTRACT_COST = 5000000000000000000000000;

    address migrationMaster;
    address crowdFundingOwner;

    modifier onlyMigrationMaster {
        require(msg.sender == migrationMaster);
        _;
    }

    uint256 public reservedCoins = TEAM_STAKE + PARTNERS_STAKE + CONTRACT_COST;

    enum State {Disabled, PrivateFunding, PreICO, CompletePreICO, ICO, Enabled, Migration}

    uint public coefficient = 0;

    State   public state = State.Disabled;
    uint    public startCrowdFunding;
    uint    public endICO;
    uint    public endPreICO;

    modifier enabledState {
        require(state == State.Enabled);
        _;
    }

    address[] public fundersList;
    mapping (address => Structures.Funder) public funders;

    function CrowdFunding() GidCoin() {}

    function () payable {
        if (state == State.Migration) {
            return;
        }

        // checking the state
        require(state == State.PreICO || state == State.ICO || state == State.PrivateFunding);
        if (state == State.PreICO) {
            require(now < endPreICO);
        }
        if (state == State.ICO) {
            require(now < endICO);
        }

        // calculate stake
        uint valueWei = msg.value;
        uint256 stake = valueWei * coefficient;

        // check all funding
        if (balanceOf[master] - reservedCoins - stake <= 0 ||
            balanceOf[master] - reservedCoins - stake > balanceOf[master]) {
            // calculate max possible stake
            stake = balanceOf[master] - reservedCoins;
            valueWei = stake / coefficient;
            msg.sender.transfer(msg.value - valueWei);
        }

        // make sure that is possible
        require(balanceOf[msg.sender] + stake > balanceOf[msg.sender]);
        require(balanceOf[master] - reservedCoins - stake >= 0);
        require(stake > 0);

        Funding += valueWei;

        // add / update funder`s stake
        Structures.Funder storage funder = funders[msg.sender];
        funder.amountTokens += stake;
        funder.amountWei += valueWei;

        // add / update user balance
        balanceOf[msg.sender] += stake;
        balanceOf[master] -= stake;

        // push funder in iterator
        fundersList.push(msg.sender);

        Transfer(master, msg.sender, stake);
    }

    function investFromFiat(address _investor, uint256 _valueWei) onlyMaster {
        uint256 stake = _valueWei * coefficient;

        // make sure that is possible
        require(balanceOf[_investor] + stake > balanceOf[_investor]);
        require(balanceOf[master] - CONTRACT_COST - TEAM_STAKE - stake >= 0);
        require(stake > 0);

        // add / update funder`s stake
        Structures.Funder storage funder = funders[_investor];
        funder.amountTokens += stake;
        funder.amountWei += _valueWei;

        // add / update user balance
        balanceOf[_investor] += stake;
        balanceOf[master] -= stake;

        // push funder in iterator
        fundersList.push(_investor);

        Transfer(this, _investor, stake);
    }

    function startPrivateFunding(
        uint _coefficient,
        address _crowdFundingOwner,
        address _migrationMaster
    ) public onlyMaster {
        // checking the state
        require(state == State.Disabled);

        // initialize the environment
        coefficient = _coefficient;
        crowdFundingOwner = _crowdFundingOwner;
        migrationMaster = _migrationMaster;

        state = State.PrivateFunding;

        delete Funding;
    }

    function completePrivateFunding() onlyMaster {
        require(state == State.PrivateFunding);

        crowdFundingOwner.transfer(this.balance);

        state = State.Disabled;
    }

    function startPreICO(
        uint _minFinancing,
        uint _preICODuration,
        uint _coefficient,
        address _crowdFundingOwner,
        address _migrationMaster
    ) public onlyMaster {
        // checking the state
        require(state == State.Disabled);

        // initialize the environment
        startCrowdFunding = now;
        minFunding = _minFinancing;
        endPreICO = now + _preICODuration;
        coefficient = _coefficient;
        crowdFundingOwner = _crowdFundingOwner;
        migrationMaster = _migrationMaster;

        state = State.PreICO;

        delete Funding;
    }

    function completePreICO() public onlyMaster {

        // checking the state
        require(state == State.PreICO);
        require(endPreICO <= now);

        // send funding for ICO
        crowdFundingOwner.transfer(this.balance);

        state = State.CompletePreICO;
    }

    function startICO(
        uint _coefficient,
        uint _ICODuration,
        address _crowdFundingOwner,
        address _migrationMaster
    ) public onlyMaster {
        // checking the state
        require(state == State.CompletePreICO);

        endICO = now + _ICODuration;
        crowdFundingOwner = _crowdFundingOwner;
        migrationMaster = _migrationMaster;

        // update state
        state = State.ICO;
        coefficient = _coefficient;
    }

    function completeICO() public onlyMaster {
        // checking the state
        require(state == State.ICO);
        require(now <= endICO);

        if (minFunding > Funding) {
            // failed
            state = State.Disabled;
        } else {
            // successful crowdfunding
            crowdFundingOwner.transfer(this.balance);
            state = State.Enabled;
        }
    }

    function refund() public {
        // checking the state
        require(state == State.Disabled);

        // return stake to funder
        uint value = funders[msg.sender].amountWei;
        if (value > 0) {
            delete funders[msg.sender];
            msg.sender.transfer(value);
        }
    }

    function endICO() public returns (uint t) {

        // checking the state
        require(state == State.ICO);

        // time to end
        if (now > endICO) {
            t = 0;
        } else {
            t = endICO - now;
        }
    }

    function endPreICO() public returns (uint t) {

        // checking the state
        require(state == State.PreICO);

        // time to end
        if (now > endPreICO) {
            t = 0;
        } else {
            t = endPreICO - now;
        }
    }
}