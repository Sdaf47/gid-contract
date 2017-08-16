pragma solidity ^0.4.4;


import "./Structures.sol";
import "./MigrationMaster.sol";


contract Administrator is MigrationMaster {

    uint256 signDocumentPrice = 0;

    mapping (address => Structures.Admin) public administrators;

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

}
