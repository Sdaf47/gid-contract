let Gid = artifacts.require("Gid");

const Web3 = require('web3');
let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

contract('Gid', (accounts) => {

    it('crowd-sale test', async () => {
        const gid = await Gid.deployed();

        console.log('contract address', gid.address);
        const totalSupply = await gid.totalSupply.call();
        assert.equal(totalSupply.valueOf(), 100000000, "total supply = 100000000");

        const account1tokens = await gid.balanceOf.call(accounts[0]);
        assert.equal(account1tokens.valueOf(), 100000000, "account 1 balance = 100000000");

        assert(accounts.length >= 3, true, "need more accounts");

        await gid.startPreICO(1000000, 100, 50, 300, accounts[2]);
        const end = await gid.endPreICO();

        console.log('end of pre-ICO', end.valueOf());

        for (let i = 0; i < 3; i++) {
            logBalance('account ' + i + ' balance:', await web3.eth.getBalance(accounts[i]));
        }

        console.log('send transaction');
        await web3.eth.sendTransaction({from: accounts[0], to: accounts[1], value: toWei(1)});

        for (let i = 0; i < 3; i++) {
            logBalance('account ' + i + ' balance:', await web3.eth.getBalance(accounts[i]));
        }

        logBalance('contract balance:', await web3.eth.getBalance(gid.address));
        console.log('send transaction');

        await web3.eth.sendTransaction({from: accounts[1], to: gid.address, value: toWei(1)});

        logBalance('contract balance:', await web3.eth.getBalance(gid.address));

        const account1tokens2 = await gid.balanceOf.call(accounts[0]);
        // assert.equal(account1tokens2.valueOf(), 99999700, "account 1 balance = 99999700");
        console.log("account 0 balance", account1tokens2.valueOf(), " gid");

        const account2tokens = await gid.balanceOf.call(accounts[1]);
        // assert.equal(account2tokens.valueOf(), 300, "account 2 balance = 300");
        console.log("account 1 balance", account2tokens.valueOf(), " gid");

    });
});

function toEther(wei) {
    return wei / 1000000000000000000;
}

function toWei(ether) {
    return ether * 1000000000000000000;
}

function logBalance(mess, balance) {
    console.log(mess, toEther(balance) + " ether");
}
