pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Master.sol";


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
