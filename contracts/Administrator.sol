pragma solidity ^0.4.4;


import "./Structures.sol";
import "./MigrationMaster.sol";


contract Administrator is MigrationMaster {

    uint256 signDocumentPrice = 0;
    uint256 commissionPercent = 5;

    mapping (address => Structures.Admin) public administrators;

    function Administrator() MigrationMaster() {}

    modifier administration {
        require(administrators[msg.sender].active);
        _;
    }

    function appointAdministrator(address _candidate) onlyMaster returns (bool status) {
        administrators[_candidate] = Structures.Admin({
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
