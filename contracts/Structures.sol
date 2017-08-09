pragma solidity ^0.4.4;


library Structures {

    struct Video {
        uint start;
        bytes4 code;
        bytes32 hash;
    }

    struct Verifier {
        bytes32 name;
        address administrator;
        address[] personsApprove;
        address[] personsDataApprove;
        mapping (address => bytes32) dataApprove; // verifier.dataApprove[person] => dataHash
        bool active;
        bool block;
        // TODO organisation?
    }

    struct Person {
        mapping (bytes32 => address) dataApprove; // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => bool) signedDocuments;
        address verifier;
        bool active;
        bool block;
    }

    struct Admin {
        bytes32 name;
        bool active;
        bool block;
    }

}
