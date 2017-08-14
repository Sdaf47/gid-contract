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
            personsApprove: _persons,
            personsDataApprove : _persons,
            active : false,
            countryCode: _countryCode,
            identifier: _identifier
        });
    }

    function appointVerifier(address _candidate, bytes32 _name) administration {
        require(!verifiers[_candidate].active);
        verifiers[_candidate].administrator = msg.sender;
        verifiers[_candidate].active = true;
    }

    function dismissVerifier(address _verifier) administration {
        verifiers[_verifier].active = false;
        verifiers[_verifier].blockedBy = msg.sender;
    }

    function blockVerifierCustomers(address _verifier) {
        // dismissVerifier
        // iter by personsApprove and personsDataApprove
    }

}
