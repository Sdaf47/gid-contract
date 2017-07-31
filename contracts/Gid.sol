pragma solidity ^0.4.13;


import "./Structures.sol";
import "./Master.sol";
import "./GidCoin.sol";


contract Gid is Master, GidCoin {

    mapping (address => Structures.Person) public persons;

    mapping (address => Structures.Admin) public administrators;

    mapping (address => Structures.Verifier) public verifiers;

    mapping (address => Structures.Video) public videos;

    function Gid() payable GidCoin() {}

    modifier administration {
        // iq
        require(administrators[msg.sender].active);
        _;
    }

    modifier verifier {
        require(verifiers[msg.sender].active);
        _;
    }

    function appointAdministrator(address _candidate, bytes32 _name) onlyMaster returns (bool status) {
        administrators[_candidate] = Structures.Admin({
        name : _name,
        active : true,
        block : false
        });
    }

    function appointVerifier(address _candidate, bytes32 _name) administration returns (bool status) {
        address[] persons;
        Structures.Verifier memory verifier = Structures.Verifier({
            name : _name,
            personsApprove : persons,
            administrator : msg.sender,
            active : true,
            block : false
        });
        verifiers[_candidate] = verifier;
    }

    function createMyPerson() returns (bool status) {
        persons[msg.sender] = Structures.Person({
            verifier: 0,
            active: false, // after verify
            block: false
        });
        status = true;
    }

    function startVideoProof() returns(bytes32 code) {
        require(!videos[msg.sender].start); // iq
        videos[msg.sender] = Structures.Video({
            start: now,
            hash: "" // nothing
        });
    }

    function saveVideoProof(bytes32 _videoHash) returns(bool status) {
        require(videos[msg.sender].start > now);
        videos[msg.sender].hash = _videoHash;
        status = true;
    }

    function approvePerson(address _candidate) verify returns (bool status) {
        persons[_candidate].verifier = msg.sender;
        verifiers[msg.sender].personsDataApprove;
        status = true;
    }

}
