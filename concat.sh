cat contracts/* > Gid.sol | sed -i 's/pragma solidity ^0.4.4;//g' Gid.sol && sed -i 's/import.*;//g' Gid.sol
