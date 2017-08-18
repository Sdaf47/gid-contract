pragma solidity ^0.4.4;


import "./ERC20.sol";
import "./Master.sol";


contract GidCoin is ERC20, Master {
    string public standard = 'Token 0.1';
    string public constant name = "Gid Coin";
    string public constant symbol = "GID";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 100000000;

    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) public balanceOf;

    function GidCoin() Master() {
        balanceOf[msg.sender] = totalSupply;
    }

    function totalSupply() constant returns (uint256 _totalSupply) {
        _totalSupply = totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOf[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowed[_from][msg.sender] >= _value);
        balanceOf[_to] +=_value;
        balanceOf[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        success = true;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        require(balanceOf[msg.sender] > _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        success = true;
    }

}
