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

    function startVideoProof() returns (bytes4 code) {
        bytes32 bh = block.blockhash(block.number - 1);
        bytes32 rand = sha3(msg.sender, bh);
        code = bytes4(uint256(rand) % 1073741824);
        videos[msg.sender] = Structures.Video({
            start: now,
            code: code,
            hash: ""
        });
    }

    function saveVideoProof(bytes32 _videoHash) returns (bool status) {
        require(videos[msg.sender].start <= now);
        videos[msg.sender].hash = _videoHash;
        status = true;
    }

    function checkVideoProof(bytes32 _videoHash, bytes4 code, address person) returns (bool) {
        if (videos[person].hash == _videoHash && videos[person].code == code) {
            return true;
        }
        return false;
    }

    function signDocument(bytes32 hash) approved returns(bool status) {
        // add document list with one identifier (wtf identifier we can use?)
        persons[msg.sender].signedDocuments[hash] == true;
        status = true;
    }

}
