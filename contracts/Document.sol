pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Person.sol";


contract Document is Person {

    function addDocument(string _field, string _name) approved returns (bool status) {
        bytes32 _documentPair = sha256(_name, _field);
        persons[msg.sender].dataApprove[_documentPair] = 0x0;
        status = true;
    }

    function checkDocument(string _field, string _name, address person) returns (bool) {
        bytes32 _documentPair = sha256(_name, _field);
        if (persons[person].dataApprove[_documentPair] != 0x0) {
            return true;
        }
        return false;
    }

    function getDocumentVerifier(string _field, string _name, address person) returns (address) {
        bytes32 _documentPair = sha256(_name, _field);
        return persons[person].dataApprove[_documentPair];
    }

    function approveDocument(address _person, string _field, string _name) verifier returns (bool status) {
        Structures.Verifier storage _verifier = verifiers[msg.sender];
        require(balances[_candidate] >= _verifier.documentPrice);

        bytes32 _documentPair = sha256(_name, _field);
        persons[_person].dataApprove[_documentPair] = msg.sender;
        _verifier.dataApprove[_person].push[_documentPair];

        balances[_person] -= _verifier.documentPrice;
        balances[msg.sender] += _verifier.documentPrice;

        status = true;
    }

    function signDocument(bytes32 _documentHash) approved returns(bool status) {
        status = persons[msg.sender].signedDocuments[_documentHash];
    }

}
