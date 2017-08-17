const preICOParams = {
    _minFinancing: 1000000,
    _crowdFundingDuration: 2629743,
    _preICODuration: 604800,
    _coefficient: 0.1,
    _crowdFundingOwner: "0x3b9ac89de1fa377c89bcb83bdcb4bb35e248e347"
};

let Gid = artifacts.require("Gid");

contract('Gid', (accounts) => {

    it('should put 100000000 GID in the first account', async () => {
        const gid = await Gid.deployed();
        const balance = await gid.balanceOf.call(accounts[0]);
        const totalSupply = await gid.totalSupply.call();

        console.log(accounts);

        assert.equal(totalSupply.valueOf(), 100000000, "total supply = 100000000");
        assert.equal(balance.valueOf(), 100000000, "my balance = 100000000")
    });
});

// contract('Gid', async () => {
//     let gid = await Gid.deployed();
//
//     it("start preICO", function() {
//         await gid.startPreICO(preICOParams);
//         let t = await gid.endTokensSale();
//         console.log("time to end", t);
//         assert.equil(t > 0, true);
//     });
//
//     // it("should allow owner to add members", async function() {
//     //     let t = await gid.endTokensSale();
//     //     console.log("End of tokens sale", t);
//     // });
// });
