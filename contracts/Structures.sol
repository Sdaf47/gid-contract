pragma solidity ^0.4.0;


library Structures {

    struct Organisation {
        string name;
        string some_data; // TODO what does org have?
    }

    struct Passport {
        bytes32 first_name;
        bytes32 second_name;
        bytes32 last_name;
        bytes32 birthday;
        bytes32 number;
        bytes32 gave;
    }

    struct Verifier {
        // verifier.dataApprove[person] => dataHash
        mapping (address => bytes32) dataApprove;
        address[] persons;
        address administrator;
        Organisation organisation;
    }

    struct Person {
        // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => address) dataApprove;
        mapping (bytes32 => bool) signedDocuments;
        address verifier;
        Passport passport;
    }

    struct Admin {
        string name;
        bool active;
        bool block;
    }

    // TODO video and start_video

}
