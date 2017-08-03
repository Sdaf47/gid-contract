pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Verifier.sol";


contract Person is Verifier {

    mapping (address => Structures.Person) public persons;

    mapping (address => Structures.Video) public videos;

    modifier approved {
        require(persons[msg.sender].active);
        require(persons[msg.sender].block == false);
        _;
    }

    // verifier
    function approvePerson(address _candidate) verifier returns (bool status) {
        persons[_candidate].verifier = msg.sender;
        verifiers[msg.sender].personsApprove[_candidate] = true;
        persons[_candidate].active = true;
        status = true;
    }

    // verifier
    function blockPerson(address _intruder) verifier returns (bool status) {
        persons[_intruder].active = false;
        persons[_intruder].block = true;
        address _verifier = persons[_intruder].verifier;
        verifiers[_verifier].personsApprove[_intruder] = false;
        status = true;
    }

    function createPerson() returns (bool status) {
        persons[msg.sender] = Structures.Person({
            verifier : 0,
            active : false, // after verify
            block : false
        });
        status = true;
    }

    function startVideoProof() returns (bytes32 code) {
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
