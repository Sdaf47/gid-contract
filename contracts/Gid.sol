pragma solidity ^0.4.4;


import "./Structures.sol";
import "./GidCoin.sol";
import "./Person.sol";


contract Gid is GidCoin, Person {

    function Gid(uint256 initialSupply) GidCoin(initialSupply) {}

    // payable

    function approvePerson(address _candidate) verifier returns (bool status) {
        persons[_candidate].verifier = msg.sender;
        verifiers[msg.sender].personsApprove[_candidate] = true;
        persons[_candidate].active = true;
        status = true;
    }

    function blockPerson(address _intruder) verifier returns (bool status) {
        persons[_intruder].active = false;
        persons[_intruder].block = true;
        address _verifier = persons[_intruder].verifier;
        verifiers[_verifier].personsApprove[_intruder] = false;
        status = true;
    }

}
