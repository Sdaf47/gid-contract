pragma solidity ^0.4.4;

import "./Structures.sol";


contract GidCoin {

    mapping (address => uint256) balanceOf;
    mapping (address => Structures.Person) personalDataStorage;
    mapping (address => Structures.Admin) administrators;
    mapping (address => Structures.Admin) verifiers;

    event BeforeAppoint(address _candidate);

    modifier administration {
        if (administrators[msg.sender].active) throw;
        _;
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

    function appointVerifier(address _candidate, string name) administration {
        Structures.Admin memory verifier = Structures.Admin(name, true);
        BeforeAppoint(_candidate);
        verifiers[_candidate] = verifier;
    }

    function appointAdministrator(address _candidate, string name) administration {
        Structures.Admin memory admin = Structures.Admin(name, true);
        BeforeAppoint(_candidate);
        administrators[_candidate] = admin;
    }

    function GidAdministrator() {
        // todo who am i?
    }

}
