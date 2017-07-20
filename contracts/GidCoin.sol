pragma solidity ^0.4.4;


contract GidCoin {
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public personalData; // TODO which type of data? it is not mapping because relation is one-to-many

    function GidCoin(uint256 initialSupply) {
        balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    function addPersonalData(string field, string value) {
        personalData[_owner] = sha256(field + value); // TODO how to calculate a hash from data? and THIS IS NOT-F..G-MAPPING-DATA
    }

}
