const RefractFactory_v0 = artifacts.require("RefractFactory_v0");
const ERC20Mock_v0 = artifacts.require("ERC20Mock_v0");

module.exports = async function(deployer, networkName) {
    if (['test', 'soliditycoverage'].indexOf(networkName) === -1) {
        await deployer.deploy(RefractFactory_v0);
    } else {

        await deployer.deploy(ERC20Mock_v0);
        await deployer.deploy(RefractFactory_v0);
    }
};
