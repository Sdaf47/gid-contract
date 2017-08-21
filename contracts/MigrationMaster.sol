pragma solidity ^0.4.4;

import "./Structures.sol";
import "./CrowdFunding.sol";

contract MigrationMaster is CrowdFunding {

    address oldContract;
    address newContract;

    uint iterator = 0;

    function MigrationMaster() CrowdFunding() {}

    function setMigrationTo(address _newContract) onlyMigrationMaster {
        newContract = _newContract;
    }

    function setMigrationFrom(address _oldContract) onlyMigrationMaster {
        oldContract = _oldContract;
    }

    function getFunder(address _address) external returns(uint256 _amountTokens, uint256 _amountWei) {
        _amountTokens = funders[_address].amountTokens;
        _amountWei = funders[_address].amountWei;
    }

    function getFunderAddress(uint256 _number) external returns (address _funder) {
        return fundersList[_funder];
    }

    function migrate(address _contract) onlyMaster returns(uint) {
        _address = MigrationMaster(oldContract).getFunderAddress(iterator);
        Structures.Funder storage funder = funders[_address];
        (funder.amountTokens, funder.amountWei) = MigrationMaster(oldContract).getFunder(_address);
        balanceOf[_address] = funder.amountTokens;
        iterator += 1;
        return iterator;
    }

    function migrateBalance() onlyMaster {
        newContract.transfer(this.balance);
    }

}
