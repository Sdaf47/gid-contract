pragma solidity ^0.4.4;


import "./Structures.sol";


contract Person {

    mapping (address => Structures.Person) public persons;

    mapping (address => Structures.Video) public videos;

    modifier approved {
        require(persons[msg.sender].active);
        require(persons[msg.sender].block == false);
        _;
    }

    function createMyPerson() returns (bool status) {
        persons[msg.sender] = Structures.Person({
            verifier : 0,
            active : false, // after verify
            block : false
        });
        status = true;
    }

    function startVideoProof() returns (bytes32 code) {
        // iq
        videos[msg.sender] = Structures.Video({
            start : now,
            hash : "" // nothing
        });
    }

    function saveVideoProof(bytes32 _videoHash) returns (bool status) {
        require(videos[msg.sender].start < now);
        videos[msg.sender].hash = _videoHash;
        status = true;
    }

    function signDocument(bytes32 hash) approved returns(bool status) {
        // add document list with one identifier (wtf identifier we can use?)
        persons[msg.sender].signedDocuments[hash] == true;
        status = true;
    }

}
