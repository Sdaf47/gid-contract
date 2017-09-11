pragma solidity ^0.4.4;


library Structures {

    struct Video {
        uint start;
        bytes4 code;
        bytes32 hash;
    }

    struct Verifier {
        uint documentPrice;
        uint personPrice;
        address administrator;
        address blockedBy;
        bool active;
        uint countryCode;
        bytes32 identifier;
    }

    struct Person {
        address blockedBy;
        mapping (bytes32 => address) dataApprove; // person.dataApprove[dataHash] = verifierAddress
        mapping (bytes32 => bool) signedDocuments;
        address verifier;
        bool active;
    }

    struct Admin {
        bool active;
    }

    struct Funder {
        uint amountTokens;
        uint amountWei;
    }

}
