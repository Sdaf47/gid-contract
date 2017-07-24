pragma solidity ^0.4.0;


library Structures {

    struct PersonalData {
        string hash; // or special?
    }

    struct Document {
        string hash; // or special?
    }

    struct Approval {
        address verifier;
        address person;
        uint16 dataIndex;
    }

    struct Person {
        PersonalData[] personalData;
        Document[] signedDocuments;
    }

    struct Admin {
        string name;
        bool active;
    }
}
