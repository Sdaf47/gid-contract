pragma solidity ^0.4.4;


contract GidAdministrator {

    address admin;

    address[] verifiers;

    address[] administrators;
    enum Role {User, Verifier, Administrator}

    event BeforeAppoint(address _candidate, Role);

    modifier administration {
        if (msg.sender != administrator) throw;
    }

    function appointVerifier(address _candidate) administration {
        BeforeAppoint(_candidate, Role.Verifier);
        verifiers.push(_candidate);
    }

    function appointAdministrator(address _candidate) {
        BeforeAppoint(_candidate, Role.Administrator);
        verifiers.push(_candidate);
    }

    function GidAdministrator() {
        // todo who am i?
    }
}
