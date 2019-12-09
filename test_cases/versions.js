const { FACTORY_NAME, WALLET_NAME, ZADDRESS } = require('./constants');
const { RefractSigner } = require('./utils');
const {Wallet, BN} = require('ethers');

module.exports = {
    versions: async function version() {

        const RefractFactory_v0 = this.contracts[FACTORY_NAME];
        const RefractWallet_v0 = this.contracts[WALLET_NAME];
        const {ERC20} = this.contracts;

        const expect = this.expect;
        const accounts = this.accounts;

        const salt = 2702;
        const controller = Wallet.createRandom();


        const prediction = await RefractFactory_v0.predict(controller.address, salt);
        await RefractFactory_v0.deploy(controller.address, salt);

        const refract = await RefractWallet_v0.at(prediction);

        expect((await refract.version()).toNumber()).to.equal(0);
        expect((await RefractFactory_v0.version()).toNumber()).to.equal(0);

    }
};
