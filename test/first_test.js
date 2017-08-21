let Gid = artifacts.require("Gid");

const Web3 = require('web3');
let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

contract('Gid', (accounts) => {

    it('crowd-sale test', async () => {
        let balance = [];
        const gid = await Gid.deployed();

        console.log('contract address', gid.address);
        const totalSupply = await gid.totalSupply.call();
        assert.equal(totalSupply.valueOf(), 100000000, "total supply = 100000000");

        balance[0] = await gid.balanceOf.call(accounts[0]);
        assert.equal(balance[0].valueOf(), 100000000, "account 1 balance = 100000000");

        assert(accounts.length >= 3, true, "need more accounts");

        await gid.startPreICO(1000000, 100, 50, 300, accounts[2]);
        const end = await gid.endPreICO();

        console.log('end of pre-ICO', end.valueOf());

        for (let i = 0; i < 3; i++) {
            logBalance('account ' + i + ' balance:', await web3.eth.getBalance(accounts[i]));
        }

        console.log('send transaction 0 >> 1');
        await web3.eth.sendTransaction({from: accounts[0], to: accounts[1], value: toWei(2)});

        for (let i = 0; i < 3; i++) {
            logBalance('account ' + i + ' balance:', await web3.eth.getBalance(accounts[i]));
        }

        logBalance('contract balance:', await web3.eth.getBalance(gid.address));
        console.log('send transaction 1 >> gid');

        await web3.eth.sendTransaction({from: accounts[1], to: gid.address, value: toWei(1)});

        logBalance('contract balance:', await web3.eth.getBalance(gid.address));

        balance[0] = await gid.balanceOf.call(accounts[0]);
        assert.equal(balance[0].valueOf(), 99999700, "account 1 balance = 99999700");
        console.log("account 0 balance", balance[0].valueOf(), " gid");

        balance[1] = await gid.balanceOf.call(accounts[1]);
        assert.equal(balance[1].valueOf(), 300, "account 2 balance = 300");
        console.log("account 1 balance", balance[1].valueOf(), " gid");

        console.log('send transaction 0 >> 2');
        await web3.eth.sendTransaction({from: accounts[0], to: accounts[1], value: toWei(2)});

        logBalance('contract balance:', await web3.eth.getBalance(accounts[1]));

        console.log('send transaction 2 >> gid');
        await web3.eth.sendTransaction({from: accounts[2], to: gid.address, value: toWei(1.5)});

        logBalance('contract balance:', await web3.eth.getBalance(gid.address));

        balance[2] = await gid.balanceOf.call(accounts[1]);
        assert.equal(balance[2].valueOf(), 450, "account 2 balance = 300");
        console.log("account 2 balance", balance[2].valueOf(), " gid");

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
