pragma solidity ^0.4.4;


library Structures {

    struct Video {
        uint start;
        bytes4 code;
        bytes32 hash;
    }

    struct Verifier {
        uint documentPrice;
        uint personPrice;
        address administrator;
        address blockedBy;
        bool active;
        uint countryCode;
        bytes32 identifier;
    }

    struct Person {
        address blockedBy;
        mapping (bytes32 => address) dataApprove; // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => bool) signedDocuments;
        address verifier;
        bool active;
    }

    struct Admin {
        bytes32 name;
        bool active;
    }

    struct Funder {
        uint amountTokens;
        uint amountWei;
    }

}

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {

  function totalSupply() constant returns (uint256 _totalSupply);
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function approve(address _spender, uint256 _value) returns (bool success);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract Master {

    address public master;

    function Master() {
        master = msg.sender;
    }

    modifier onlyMaster {
        require(master == msg.sender);
        _;
    }

    function changeOwner(address _master) onlyMaster public {
        require(_master != 0);
        master = _master;
    }
}




contract GidCoin is ERC20, Master {
    string public standard = 'Token 0.1';
    string public constant name = "GID Coin";
    string public constant symbol = "GIC";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 100000000000000000000000000;

    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) public balanceOf;

    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    function GidCoin() Master() {
        balanceOf[msg.sender] = totalSupply;
    }

    function totalSupply() constant returns (uint256 _totalSupply) {
        _totalSupply = totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOf[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) returns (bool success) {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowed[_from][msg.sender] >= _value);
        balanceOf[_to] +=_value;
        balanceOf[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        success = true;
    }

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) returns (bool success) {
        require(balanceOf[msg.sender] > _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        success = true;
    }

    function mintTokens(uint256 _tokens) onlyMaster {
        uint256 _count = _tokens * 1000000000000000000;
        totalSupply += _count;
        balanceOf[master] += _tokens;
    }

}


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
            require(valueWei > 25125628100000000000);
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

    function investFromFiat(address _investor, uint256 _valueWei) onlyMaster {
        uint256 stake = _valueWei * coefficient;

        // make sure that is possible
        require(balanceOf[_investor] + stake > balanceOf[_investor]);
        require(balanceOf[master] - reservedCoins - stake >= 0);
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

contract MigrationMaster is CrowdFunding {

    address oldContract;
    address newContract;

    uint iterator = 0;

    function MigrationMaster() CrowdFunding() {}

    function setMigrationTo(address _newContract) onlyMigrationMaster {
        newContract = _newContract;
    }

    function setMigrationFrom(address _oldContract) onlyMigrationMaster {
        oldContract = _oldContract;
    }

    function getFunder(address _address) external returns(uint256 _amountTokens, uint256 _amountWei) {
        _amountTokens = funders[_address].amountTokens;
        _amountWei = funders[_address].amountWei;
    }

    function getFunderAddress(uint256 _number) external returns (address _funder) {
        return fundersList[_number];
    }

    function startMigration() onlyMaster {
        state = State.Migration;
    }

    function stopMigration() onlyMaster {
        state = State.Disabled;
    }

    function migrate() onlyMaster returns(uint) {
        address _address = MigrationMaster(oldContract).getFunderAddress(iterator);
        Structures.Funder storage funder = funders[_address];
        (funder.amountTokens, funder.amountWei) = MigrationMaster(oldContract).getFunder(_address);
        balanceOf[_address] = MigrationMaster(oldContract).balanceOf(_address);
        iterator++;
        return iterator;
    }

    function migrateBalance() onlyMaster {
        require(newContract != 0x0);
        require(state == State.Migration);

        newContract.transfer(this.balance);
    }

}




contract Administrator is MigrationMaster {

    uint256 signDocumentPrice = 0;
    uint256 commissionPercent = 5;

    mapping (address => Structures.Admin) public administrators;

    function Administrator() MigrationMaster() {}

    modifier administration {
        require(administrators[msg.sender].active);
        _;
    }

    function appointAdministrator(address _candidate, bytes32 _name) onlyMaster returns (bool status) {
        administrators[_candidate] = Structures.Admin({
            name : _name,
            active : true
        });
        status = true;
    }

    function dismissAdministrator(address _administrator) onlyMaster {
        administrators[_administrator].active = false;
    }

    function setSignDocumentPrice(uint256 _price) onlyMaster {
        signDocumentPrice = _price;
    }

    function setCommissionPercent(uint256 _percent) onlyMaster {
        commissionPercent = _percent;
    }

}




contract Verifier is Administrator {

    mapping (address => Structures.Verifier) public verifiers;

    function Verifier() Administrator() {}

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function createVerifier(uint _countryCode, bytes32 _identifier) {
        require(!verifiers[msg.sender].active);
        verifiers[msg.sender] = Structures.Verifier({
            documentPrice: 5,
            personPrice: 10,
            administrator: 0x0,
            blockedBy: 0x0,
            active : false,
            countryCode: _countryCode,
            identifier: _identifier
        });
    }

    function appointVerifier(address _candidate) administration {
        require(!verifiers[_candidate].active);
        verifiers[_candidate].administrator = msg.sender;
        verifiers[_candidate].active = true;
    }

    function dismissVerifier(address _verifier) administration {
        verifiers[_verifier].active = false;
        verifiers[_verifier].blockedBy = msg.sender;
    }

    // verification price
    function setDocumentPrice(uint _price) verifier {
        verifiers[msg.sender].documentPrice = _price;
    }

    // verification price
    function setPersonPrice(uint _price) verifier {
        verifiers[msg.sender].personPrice = _price;
    }

    function getVerifierPrices() returns(uint _documentPrice, uint _personPrice) {
        Structures.Verifier storage _verifier = verifiers[msg.sender];
        return (_verifier.documentPrice, _verifier.personPrice);
    }

}




contract Person is Verifier {

    mapping (address => Structures.Person) public persons;
    mapping (address => Structures.Video) public videos;

    function Person() Verifier() {}

    modifier approved {
        require(persons[msg.sender].active);
        _;
    }

    function createPerson() returns (bool status) {
        require(!persons[msg.sender].active);
        persons[msg.sender] = Structures.Person({
            blockedBy: 0x0,
            verifier : 0,
            active : false
        });
        status = true;
    }

    function approvePerson(address _candidate) verifier returns (bool status) {
        Structures.Verifier storage _verifier = verifiers[msg.sender];
        require(balanceOf[_candidate] >= _verifier.personPrice);

        persons[_candidate].verifier = msg.sender;
        persons[_candidate].active = true;

        // calculate commission
        uint _commission = _verifier.personPrice * commissionPercent / 100;
        uint _value = _verifier.personPrice - _commission;

        // send price to verifier
        balanceOf[_candidate] -= _value;
        balanceOf[msg.sender] += _value;
        Transfer(_candidate, msg.sender, _value);

        // send commission to master
        balanceOf[_candidate] -= _commission;
        balanceOf[master] += _commission;
        Transfer(_candidate, msg.sender, _value);

        status = true;
    }

    function blockPerson(address _intruder) verifier returns (bool status) {
        Structures.Person storage person = persons[_intruder];
        person.active = false;
        person.blockedBy = msg.sender;
        status = true;
    }

    function startVideoProof() returns (bytes4 code) {
        bytes32 bh = block.blockhash(block.number - 1);
        bytes32 rand = sha3(msg.sender, bh);
        code = bytes4(uint256(rand) % 1073741824);
        videos[msg.sender] = Structures.Video({
            start: now,
            code: code,
            hash: ""
        });
    }

    function saveVideoProof(bytes32 _videoHash) returns (bool status) {
        require(videos[msg.sender].start <= now);
        videos[msg.sender].hash = _videoHash;
        status = true;
    }

    function checkVideoProof(bytes32 _videoHash, bytes4 code, address person) returns (bool) {
        if (videos[person].hash == _videoHash && videos[person].code == code) {
            return true;
        }
        return false;
    }

}




contract Document is Person {

    function Document() Person() {}

    function addDocument(string _field, string _name) approved returns (bool status) {
        bytes32 _documentPair = sha256(_name, _field);
        persons[msg.sender].dataApprove[_documentPair] = 0x0;
        status = true;
    }

    function checkDocument(string _field, string _name, address person) returns (bool) {
        bytes32 _documentPair = sha256(_name, _field);
        if (persons[person].dataApprove[_documentPair] != 0x0) {
            return true;
        }
        return false;
    }

    function getDocumentVerifier(string _field, string _name, address person) returns (address) {
        bytes32 _documentPair = sha256(_name, _field);
        return persons[person].dataApprove[_documentPair];
    }

    function approveDocument(address _person, string _field, string _name) verifier returns (bool status) {
        Structures.Verifier storage _verifier = verifiers[msg.sender];
        require(balanceOf[_person] >= _verifier.documentPrice);

        bytes32 _documentPair = sha256(_name, _field);
        persons[_person].dataApprove[_documentPair] = msg.sender;

        // calculate commission
        uint _commission = _verifier.documentPrice * commissionPercent / 100;
        uint _value = _verifier.documentPrice - _commission;

        // send price to verifier
        balanceOf[_person] -= _verifier.documentPrice;
        balanceOf[msg.sender] += _verifier.documentPrice;
        Transfer(_person, msg.sender, _value);

        // send commission to master
        balanceOf[_person] -= _commission;
        balanceOf[master] += _commission;
        Transfer(_person, master, _commission);

        status = true;
    }

    function signDocument(bytes32 _documentHash) approved returns(bool status) {
        require(balanceOf[msg.sender] - signDocumentPrice > 0);

        balanceOf[msg.sender] -= signDocumentPrice;
        balanceOf[master] += signDocumentPrice;

        Transfer(msg.sender, master, signDocumentPrice);

        persons[msg.sender].signedDocuments[_documentHash] = true;

        status = true;
    }

    function checkSign(bytes32 _documentHash) approved returns(bool status) {
        require(balanceOf[msg.sender] - signDocumentPrice > 0);

        status = persons[msg.sender].signedDocuments[_documentHash];
    }

}




contract Gid is Document {
    function Gid() Document() {}
}
