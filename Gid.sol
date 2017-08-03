






contract Administrator is Master {

    mapping (address => Structures.Admin) public administrators;

    modifier administration {
        // iq
        require(administrators[msg.sender].active);
        _;
    }

    function appointAdministrator(address _candidate, bytes32 _name) onlyMaster returns (bool status) {
        administrators[_candidate] = Structures.Admin({
            name : _name,
            active : true,
            block : false
        });
    }

}


/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {

  function totalSupply() constant returns (uint256 totalSupply);
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function approve(address _spender, uint256 _value) returns (bool success);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}






contract GidCoin is ERC20 {
    string public standard = 'Token 0.1';
    string public constant name = "Gid Coin";
    string public constant symbol = "GID";
    uint8 public constant decimals = 18;
    uint256 _totalSupply;

    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) public balances;

    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }

    function GidCoin(uint256 initialSupply, address _master) {
        balances[msg.sender] = _totalSupply = initialSupply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(_to != 0x0);
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        require(_value > allowed[_from][msg.sender]);
        balances[_to] +=_value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        success = true;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        require(balances[msg.sender] > _value);
        require(balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        success = true;
    }

}








contract Gid is GidCoin, Person {

    function Gid(uint256 initialSupply, address _master) payable GidCoin(initialSupply, _master) {}


    function approvePerson(address _candidate) verifier returns (bool status) {
        persons[_candidate].verifier = msg.sender;
        verifiers[msg.sender].personsApprove[_candidate] = true;
        persons[_candidate].active = true;
        status = true;
    }

    function blockPerson(address _intruder) verifier returns (bool status) {
        persons[_intruder].active = false;
        persons[_intruder].block = true;
        address _verifier = persons[_intruder].verifier;
        verifiers[_verifier].personsApprove[_intruder] = false;
        status = true;
    }

}



contract Master {

    address public master;

    function Master() payable {
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



contract Migrations {
    address public owner;

    uint public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function Migrations() {
        owner = msg.sender;
    }

    function setCompleted(uint completed) restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}







contract Person is Verifier {

    mapping (address => Structures.Person) public persons;

    mapping (address => Structures.Video) public videos;

    modifier approved {
        require(persons[msg.sender].active);
        require(persons[msg.sender].block == false);
        _;
    }

    function approvePerson(address _candidate) verifier returns (bool status) {
        persons[_candidate].verifier = msg.sender;
        verifiers[msg.sender].personsApprove[_candidate] = true;
        persons[_candidate].active = true;
        status = true;
    }

    function blockPerson(address _intruder) verifier returns (bool status) {
        persons[_intruder].active = false;
        persons[_intruder].block = true;
        address _verifier = persons[_intruder].verifier;
        verifiers[_verifier].personsApprove[_intruder] = false;
        status = true;
    }

    function createMyPerson() returns (bool status) {
        persons[msg.sender] = Structures.Person({
            verifier : 0,
            active : false, // after verify
            block : false
        });
        status = true;
    }

    function startVideoProof() returns (bytes32 code) {
        // iq
        videos[msg.sender] = Structures.Video({
            start : now,
            hash : "" // nothing
        });
    }

    function saveVideoProof(bytes32 _videoHash) returns (bool status) {
        require(videos[msg.sender].start < now);
        videos[msg.sender].hash = _videoHash;
        status = true;
    }

    function signDocument(bytes32 hash) approved returns(bool status) {
        // add document list with one identifier (wtf identifier we can use?)
        persons[msg.sender].signedDocuments[hash] == true;
        status = true;
    }

}



library Structures {

    // TODO mb passport?
    struct Video {
        uint start;
        bytes32 hash;
    }

    struct Verifier {
        bytes32 name;
        address administrator;
        mapping (address => bool) personsApprove;
        address[] personsDataApprove;
        mapping (address => bytes32) dataApprove; // verifier.dataApprove[person] => dataHash
        bool active;
        bool block;
        // TODO organisation?
    }

    struct Person {
        mapping (bytes32 => address) dataApprove; // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => bool) signedDocuments;
        address verifier;
        bool active;
        bool block;
    }

    struct Admin {
        bytes32 name;
        bool active;
        bool block;
    }

}







contract Verifier is Administrator {

    mapping (address => Structures.Verifier) public verifiers;

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function appointVerifier(address _candidate, bytes32 _name) administration returns (bool status) {
        address[] memory _persons;
        Structures.Verifier memory verifier = Structures.Verifier({
        name : _name,
        personsDataApprove : _persons,
        administrator : msg.sender,
        active : true,
        block : false
        });
        verifiers[_candidate] = verifier;
    }

}
