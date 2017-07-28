pragma solidity ^0.4.0;


library Structures {

    struct Verifier {
        bytes32 name;
        address administrator;
        address[] personsApprove;
        mapping (address => bytes32) dataApprove; // verifier.dataApprove[person] => dataHash
        bool active;
        bool block;
        // TODO organisation?
    }

    struct Person {
        mapping (bytes32 => address) dataApprove; // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => bool) signedDocuments;
        address verifier;
        // TODO passport?
        bytes32 first_name;
        bytes32 second_name;
        bytes32 last_name;
        bytes32 birthday;
        bytes32 number;
        bytes32 gave;
    }

    struct Admin {
        bytes32 name;
        bool active;
        bool block;
    }

    // TODO video and start_video

}
