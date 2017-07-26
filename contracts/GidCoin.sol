pragma solidity ^0.4.4;

import "./Structures.sol";
import "./ERC20.sol";


contract GidCoin is ERC20 {
    string public standard = 'Token 0.1';
    string public constant name = "GuardID Token";
    string public constant symbol = "GID";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) public balanceOf;

    address private master;
    mapping (address => Structures.Person) private personalDataStorage;
    mapping (address => Structures.Admin) private administrators;
    mapping (address => Structures.Admin) private verifiers;

    function GidCoin(uint256 initialSupply) {
        balanceOf[msg.sender] = initialSupply; // TODO think
        master = msg.sender;
    }

    modifier administration {
        // TODO to do =)
        if (!administrators[msg.sender].active) throw;
        _;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;
        if (balanceOf[_from] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        if (_value > allowed[_from][msg.sender]) throw;
        balanceOf[_to] +=_value;
        balanceOf[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        success = true;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    event BeforeAppoint(address _candidate);

    function appointVerifier(address _candidate, string name) administration {
        Structures.Admin memory verifier = Structures.Admin(name, true);
        BeforeAppoint(_candidate);
        verifiers[_candidate] = verifier;
    }

    function appointAdministrator(address _candidate, string name) administration {
        Structures.Admin memory admin = Structures.Admin(name, true);
        BeforeAppoint(_candidate);
        administrators[_candidate] = admin;
    }

    function GidAdministrator() {
        // TODO who am i?
    }

}
