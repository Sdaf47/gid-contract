pragma solidity ^0.4.4;


contract GidCoin {

    struct Liberated { // Struct like in golang
        address who;
        address verifier;
        bool proved;
    }

    enum Role { User, Verifier, Admin }

    mapping (address => uint8) public verifiers; // TODO it is just simply array
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public personalData; // TODO which type of data? it is not mapping because relation is one-to-many

    event SomethingElseHappened(address who, uint256 amount); // simply event
    event LibertyEvent(Liberated slave); // simply event

    modifier onlyOwner {
        require(msg.sender == owner);
        _; // yeeaaaah decorators! some strange decorators
    }

    function liberate(address _to) {
        balanceOf[_to] = 0;
        balanceOf[msg.sender] += balanceOf[_to];
        Liberated slave = Liberated(msg.sender, _to, true);
        LibertyEvent(slave);
    }

    function GidCoin(uint256 initialSupply) {
        balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;

        SomethingElseHappened(msg.sender, _value); // raise event

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    function addPersonalData(string field, string value) constant returns (bytes32) {
        address owner = msg.sender;
        personalData[owner] = sha256(field + value); // TODO how to calculate a hash from data? and THIS IS NOT-F..G-MAPPING-DATA
    }

}
