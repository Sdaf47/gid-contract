pragma solidity ^0.4.4;

import "./Structures.sol";
import "./GidCoin.sol";

contract CrowdFunding is GidCoin {
    uint public Funding;
    uint public minFunding;

    address migrationMaster;
    address public crowdFundingOwner;

    modifier onlyMigrationMaster {
        require(msg.sender == migrationMaster);
        _;
    }

    uint256 public reservedCoins = 36000000000000000000000000;

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

        // limitation
        if (state == State.PrivateFunding) {
            require(valueWei > 30000000000000000000);
        }

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

    function investFromFiat(address _investor, uint256 _value) onlyMaster {
        uint256 stake = _value;

        // make sure that is possible
        require(balanceOf[_investor] + stake > balanceOf[_investor]);
        require(balanceOf[master] - reservedCoins - stake >= 0);
        require(stake > 0);

        // add / update funder`s stake
        Structures.Funder storage funder = funders[_investor];
        funder.amountTokens += stake;
        funder.amountWei += 0;

        // add / update user balance
        balanceOf[_investor] += stake;
        balanceOf[master] -= stake;

        Funding += _value / coefficient;

        // push funder in iterator
        fundersList.push(_investor);

        Transfer(master, _investor, stake);
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

    function safeWithdrawal() onlyMaster {
        require(state == State.PrivateFunding ||
                state == State.PreICO ||
                state == State.ICO
        );

        crowdFundingOwner.transfer(this.balance);
    }

    function refund() public {
        // checking the state
        require(state == State.Disabled);
        require(Funding < minFunding);

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