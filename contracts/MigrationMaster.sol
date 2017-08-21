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
        return fundersList[_number];
    }

    function migrate(address _contract) onlyMaster returns(uint) {
        _contract = MigrationMaster(oldContract).getFunderAddress(iterator);
        Structures.Funder storage funder = funders[_contract];
        (funder.amountTokens, funder.amountWei) = MigrationMaster(oldContract).getFunder(_contract);
        balanceOf[_contract] = funder.amountTokens;
        iterator += 1;
        return iterator;
    }

    function migrateBalance() onlyMaster {
        newContract.transfer(this.balance);
    }

}
