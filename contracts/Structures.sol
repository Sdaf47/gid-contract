pragma solidity ^0.4.4;


library Structures {

    struct Video {
        uint start;
        bytes4 code;
        bytes32 hash;
    }

    struct Verifier {
        address administrator;
        address blockedBy;
        address[] personsApprove;
        address[] personsDataApprove;
        mapping (address => bytes32) dataApprove; // verifier.dataApprove[person] => dataHash
        bool active;
        uint countryCode;
        bytes32 identifier;
    }

    struct Person {
        mapping (bytes32 => address) dataApprove; // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => bool) signedDocuments;
        address verifier;
        bool active;
    }

    struct Admin {
        bytes32 name;
        bool active;
    }

    struct Funder {
        uint amountTokens;
        uint amountWei;
    }

}
