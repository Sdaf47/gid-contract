pragma solidity ^0.4.13;


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
