var GidCoin = artifacts.require("./GidCoin.sol");

module.exports = function(deployer) {
  // deployer.deploy(ConvertLib);
  // deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(GidCoin);
};
