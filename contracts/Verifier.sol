pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Administrator.sol";


contract Verifier is Administrator {

    mapping (address => Structures.Verifier) public verifiers;

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function appointVerifier(address _candidate, bytes32 _name) administration returns (bool status) {
        address[] memory _persons;
        Structures.Verifier memory verifier = Structures.Verifier({
        name : _name,
        personsDataApprove : _persons,
        administrator : msg.sender,
        active : true,
        block : false
        });
        verifiers[_candidate] = verifier;
    }

}
