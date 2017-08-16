pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Person.sol";


contract Document is Person {

    function addDocument(string fields) approved returns (bool status) {
        bytes32 documentHash = sha256(fields);
        persons[msg.sender].dataApprove[documentHash] = 0x0;
        status = true;
    }

    function checkDocument(string fields, address person) returns (bool) {
        bytes32 documentHash = sha256(fields);
        if (persons[person].dataApprove[documentHash] != 0x0) {
            return true;
        }
        return false;
    }

    function getDocumentVerifier(string fields, address person) returns (address) {
        bytes32 documentHash = sha256(fields);
        return persons[person].dataApprove[documentHash];
    }

    function approveDocument(address _person, bytes32 documentHash) verifier returns (bool status) {
        persons[_person].dataApprove[documentHash] = msg.sender;
        // todo how?

        status = true;
    }

    function signDocument(bytes32 hash) approved returns(bool status) {
        // add document list with one identifier (wtf identifier we can use?)
        persons[msg.sender].signedDocuments[hash] == true;
        status = true;
    }

}
