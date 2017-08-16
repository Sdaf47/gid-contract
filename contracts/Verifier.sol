pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Administrator.sol";


contract Verifier is Administrator {

    mapping (address => Structures.Verifier) public verifiers;

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function createVerifier(uint _countryCode, bytes32 _identifier) {
        address[] memory _persons;
        verifiers[msg.sender] = Structures.Verifier({
            administrator: 0x0,
            blockedBy: 0x0,
            personsBlock: _persons,
            personsApprove: _persons,
            personsDataApprove : _persons,
            active : false,
            countryCode: _countryCode,
            identifier: _identifier
        });
    }

    function appointVerifier(address _candidate) administration {
        require(!verifiers[_candidate].active);
        verifiers[_candidate].administrator = msg.sender;
        verifiers[_candidate].active = true;
    }

    function dismissVerifier(address _verifier) administration {
        verifiers[_verifier].active = false;
        verifiers[_verifier].blockedBy = msg.sender;
    }

    function VerifierCustomersIterator(function(address) external _iterator, address _verifier) administration {
//    todo
//        Structures.Verier storage verifier = verifiers[_verifier];
//        uint current = verifier.personsApprove.length;
//        while (current >= 0) {
//            current--;
//            _iterator(verifier.personsApprove[current]);
//        }
    }

}
