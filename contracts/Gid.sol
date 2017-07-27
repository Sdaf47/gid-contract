pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Master.sol";
import "./GidCoin.sol";


contract Gid is Master, GidCoin {

    mapping (address => Structures.Person) private persons;

    mapping (address => Structures.Admin) private administrators;
    mapping (address => Structures.Verifier) private verifiers;

    modifier administration {
        require(administrators[msg.sender].active);
        _;
    }

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function appointAdministrator(address _candidate, string name) onlyMaster {
        Structures.Admin memory admin = Structures.Admin(name, true);
        administrators[_candidate] = admin;
    }

    function appointVerifier(address _candidate, string name) administration {
        Structures.Admin memory verifier = Structures.Admin(name, true);
        verifiers[_candidate] = verifier;
    }

    //

    function createMyPerson(
        bytes32 _first_name,
        bytes32 _second_name,
        bytes32 _last_name,
        bytes32 _birthday,
        bytes32 _number,
        bytes32 _gave
    ) verifier payable returns (bool status) {
        Passport memory passport = Structure.Passport({
            first_name: _first_name,
            second_name: _second_name,
            last_name: _last_name,
            birthday: _birthday,
            number: _number,
            gave: _gave
        });
        persons[msg.sender] = Structures.Person({
            verifier: 0,
            passport: Password
        });
    }

}
