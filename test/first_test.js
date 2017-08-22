let Gid = artifacts.require("Gid");

const Web3 = require('web3');
let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

contract('Gid', (accounts) => {

    it('crowd-sale test', async () => {

        let balances = [];
        let contractBalance;
        const gid = await Gid.deployed();

        // total supply
        const totalSupply = await gid.totalSupply.call();
        assert.equal(totalSupply.valueOf(), 100000000000000000000000000, "total supply = 100000000");

        // starting balance
        balances[0] = await gid.balanceOf.call(accounts[0]);
        assert.equal(balances[0].valueOf(), 100000000000000000000000000, "account 1 balance = 100000000");


        // PRIVATE FUNDING
        // start private funding
        await gid.startPrivateFunding(300, accounts[4], accounts[5]);

        // 1 >> gid
        await web3.eth.sendTransaction({from: accounts[1], to: gid.address, value: toWei(1), gas: 3000000});
        balances[1] = await gid.balanceOf.call(accounts[1]);
        assert.equal(balances[1].valueOf(), 300000000000000000000, "account 1 balance = 300");

        // 2 >> gid
        await web3.eth.sendTransaction({from: accounts[2], to: gid.address, value: toWei(1), gas: 3000000});
        balances[2] = await gid.balanceOf.call(accounts[2]);
        assert.equal(balances[2].valueOf(), 300000000000000000000, "account 1 balance = 300");

        // 0 balance
        balances[0] = await gid.balanceOf.call(accounts[0]);
        assert.equal(balances[0].valueOf(), 99999400000000000000000000, "account 1 balance = 99999400");

        // end private funding
        await gid.completePrivateFunding();

        // todo check negative


        // PRE ICO
        // start pre-ICO
        await gid.startPreICO(1000000000000000000000000, 5, 300, accounts[4], accounts[5]);

        // 1 >> gid
        await web3.eth.sendTransaction({from: accounts[1], to: gid.address, value: toWei(1), gas: 3000000});
        balances[1] = await gid.balanceOf.call(accounts[1]);

        assert.equal(balances[1].valueOf(), 600000000000000000000, "account 1 balance = 600");

        // 2 >> gid
        await web3.eth.sendTransaction({from: accounts[2], to: gid.address, value: toWei(1), gas: 3000000});
        balances[2] = await gid.balanceOf.call(accounts[2]);
        assert.equal(balances[2].valueOf(), 600000000000000000000, "account 1 balance = 600");

        // 0 balance
        balances[0] = await gid.balanceOf.call(accounts[0]);
        assert.equal(balances[0].valueOf(), 99998800000000000000000000, "account 1 balance = 99998800");

        // todo check negative

        // end pre ICO
        let endPre = await gid.endPreICO.call();
        await sleep(1000 * endPre.valueOf() + 1000);
        await gid.completePreICO();
        console.log("completePreICO");
        // todo check negative

        // ICO
        // start ICO
        await gid.startICO(300, 10, accounts[4], accounts[5]);
        await web3.eth.sendTransaction({from: accounts[2], to: gid.address, value: toWei(0.1)});
        console.log("started ICO");

        // 3 >> gid
        await web3.eth.sendTransaction({from: accounts[3], to: gid.address, value: toWei(1.5), gas: 3000000});
        balances[3] = await gid.balanceOf.call(accounts[3]);
        assert.equal(balances[3].valueOf(), 450000000000000000000, "account 3 balance = 450");

        // todo maximum

        // contract balance
        contractBalance = await web3.eth.getBalance(gid.address);
        assert.equal(contractBalance.valueOf(), 1600000000000000000, "contract balance = 1.6");

        // end ICO
        let endIco = await gid.endICO.call();
        await sleep(1000 * endIco.valueOf());
        console.log("error?");
        await gid.completeICO();
        console.log("completeICO");

        // todo negative
        // await web3.eth.sendTransaction({from: accounts[3], to: gid.address, value: toWei(1.5), gas: 3000000});
        // balances[3] = await gid.balanceOf.call(accounts[3]);
        // console.log(balances[3]);

        balances[4] = await web3.eth.getBalance(accounts[4]);
        console.log(balances[4]);

        balances[5] = await web3.eth.getBalance(accounts[5]);
        console.log(balances[5]);
    });
});

function toWei(ether) {
    return ether * 1000000000000000000;
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
