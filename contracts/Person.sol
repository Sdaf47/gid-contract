pragma solidity ^0.4.4;


import "./Structures.sol";
import "./Verifier.sol";


contract Person is Verifier {

    mapping (address => Structures.Person) public persons;
    mapping (address => Structures.Video) public videos;

    modifier approved {
        require(persons[msg.sender].active);
        _;
    }

    function createPerson() returns (bool status) {
        persons[msg.sender] = Structures.Person({
            blockedBy: 0x0,
            verifier : 0,
            active : false
        });
        status = true;
    }

    function approvePerson(address _candidate) verifier returns (bool status) {
        persons[_candidate].verifier = msg.sender;
        verifiers[msg.sender].personsApprove.push(_candidate);
        persons[_candidate].active = true;
        status = true;
    }

    function blockPerson(address _intruder) verifier returns (bool status) {
        Structures.Person storage person = persons[_intruder];
        person.active = false;
        person.blockedBy = msg.sender;
        verifiers[msg.sender].personsBlock.push(_intruder);
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

}
