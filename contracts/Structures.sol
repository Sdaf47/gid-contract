pragma solidity ^0.4.0;


library Structures {

    struct Passport {
        bytes32 first_name;
        bytes32 second_name;
        bytes32 last_name;
        bytes32 birthday;
    }

    struct PersonalData {
        bytes32 hash;
    }

    struct Document {
        bytes32 hash;
    }

    // TODO may i use struct-object as reference, or struct-object to be clone?
    struct Verifier {
        // [person][dataHash]
        mapping (address => bytes32) dataApprove;
        address[] persons;
    }

    struct Person {
        // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => address) dataApprove;
        mapping (bytes32 => mapping(bytes32 => bool)) signedDocuments;
        address verifier;
        Passport passport;
    }

    struct Admin {
        string name;
        bool active;
        bool block;
    }
}
