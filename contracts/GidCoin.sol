pragma solidity ^0.4.4;

import "./ERC20.sol";


contract GidCoin is ERC20 {
    string public standard = 'Token 0.1';
    string public constant name = "Gid Coin";
    string public constant symbol = "GID";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) public balanceOf;

    address private master;

    function GidCoin(uint256 initialSupply, address _master) {
        balanceOf[msg.sender] = totalSupply = initialSupply;
        master = _master;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(_value > allowed[_from][msg.sender]);
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
