pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Administrator.sol";


contract Verifier is Administrator {

    mapping (address => Structures.Verifier) public verifiers;

    function Verifier() Administrator() {}

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function createVerifier(uint _countryCode, bytes32 _identifier) {
        require(!verifiers[msg.sender].active);
        verifiers[msg.sender] = Structures.Verifier({
            documentPrice: 5,
            personPrice: 10,
            administrator: 0x0,
            blockedBy: 0x0,
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

    // verification price
    function setDocumentPrice(uint _price) verifier {
        verifiers[msg.sender].documentPrice = _price;
    }

    // verification price
    function setPersonPrice(uint _price) verifier {
        verifiers[msg.sender].personPrice = _price;
    }

    function getVerifierPrices() returns(uint _documentPrice, uint _personPrice) {
        Structures.Verifier storage _verifier = verifiers[msg.sender];
        return (_verifier.documentPrice, _verifier.personPrice);
    }

}
