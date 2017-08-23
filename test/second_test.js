let Gid = artifacts.require("Gid");

const Web3 = require('web3');
let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
// let contract_addres;

contract('Gid', (accounts) => {
    "use strict";
    it('crowd-sale test', async () => {
        const gid = await Gid.deployed();
        console.log(gid.address);
    });
});

contract('Gid2', (accounts) => {
    "use strict";
    it('crowd-sale test', async () => {
        const gid2 = await Gid.deployed();
        console.log(gid2.address);
    });
});


