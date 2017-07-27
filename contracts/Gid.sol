pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Master.sol";
import "./GidCoin.sol";


contract Gid is Master, GidCoin {

    mapping (address => Structures.Person) private personalDataStorage;

    mapping (address => Structures.Admin) private administrators;
    mapping (address => Structures.Admin) private verifiers;

    modifier administration {
        require(administrators[msg.sender].active);
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

    function GidAdministrator() {
        // TODO who am i?
    }
}
