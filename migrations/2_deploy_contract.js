const MoneySafe = artifacts.require("MoneySafe");

module.exports = (deployer) => {
    deployer.deploy(MoneySafe);
}