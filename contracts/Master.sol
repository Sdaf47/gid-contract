pragma solidity ^0.4.4;


contract Master {

    address public master;

    function Master() payable {
        master = msg.sender;
    }

    modifier onlyOwner {
        require(master == msg.sender);
        _;
    }

    function changeOwner(address _master) onlyOwner public {
        require(_master != 0);
        master = _master;
    }
}
