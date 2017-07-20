pragma solidity ^0.4.4;


contract GidCoin {

    struct Liberated {// Struct like in golang
    address who;
    address verifier;
    bool proved;
    }

    enum Role {User, Verifier, Admin}

    Liberated slave;

    mapping (address => uint8) public verifiers; // TODO it is just simply array
    mapping (address => uint256) public balanceOf;

    mapping (address => bytes32) public personalData; // TODO which type of data? it is not mapping because relation is one-to-many

    event SomethingElseHappened(address who, uint256 amount); // simply event
    event LibertyEvent(address sender, address slave, bool proved);

    function liberate(address _to) {
        balanceOf[_to] = 0;
        balanceOf[msg.sender] += balanceOf[_to];
        slave = Liberated(msg.sender, _to, true);
        LibertyEvent(msg.sender, _to, true);
    }

    function GidCoin(uint256 initialSupply) {
        balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;

        SomethingElseHappened(msg.sender, _value);
        // raise event

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    function addPersonalData(string field, string value) returns (bytes32) {
        string memory recordHash = concatString(field, value);
        personalData[msg.sender] = sha256(recordHash);
        // TODO THIS IS NOT-F..G-MAPPING-DATA
    }

    function concatString(string _s1, string _s2) returns (string) {
        bytes memory _b1 = bytes(_s1);
        bytes memory _b2 = bytes(_s2);
        string memory s12 = new string(_b1.length + _b2.length);
        bytes memory b12 = bytes(s12);
        uint k = 0;
        for (uint i = 0; i < _b1.length; i++) b12[k++] = _b1[i];
        for (i = 0; i < _b2.length; i++) b12[k++] = _b2[i];
        return string(b12);
    }

}
