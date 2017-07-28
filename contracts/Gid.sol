pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Master.sol";
import "./GidCoin.sol";


contract Gid is Master, GidCoin {

    mapping (address => Structures.Person) public persons;

    mapping (address => Structures.Admin) public administrators;

    mapping (address => Structures.Verifier) public verifiers;

    function Gid() {

    }

    modifier administration {
        require(administrators[msg.sender].active);
        _;
    }

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function appointAdministrator(address _candidate, bytes32 _name) onlyMaster returns (bool status) {
        administrators[_candidate] = Structures.Admin({
        name : _name,
        active : true,
        block : false
        });
    }

    function appointVerifier(address _candidate, bytes32 _name) administration returns (bool status) {
        address[] persons;
        Structures.Verifier memory verifier = Structures.Verifier({
        name : _name,
        personsApprove : persons,
        administrator : msg.sender,
        active : true,
        block : false
        });
        verifiers[_candidate] = verifier;
    }

    function createMyPerson(
    bytes32 _first_name,
    bytes32 _second_name,
    bytes32 _last_name,
    bytes32 _birthday,
    bytes32 _number,
    bytes32 _gave
    ) verifier payable returns (bool status) {
        persons[msg.sender] = Structures.Person({
        verifier : 0,
        // TODO passport
        first_name : _first_name,
        second_name : _second_name,
        last_name : _last_name,
        birthday : _birthday,
        number : _number,
        gave : _gave
        });
    }

}
