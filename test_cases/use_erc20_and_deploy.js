const { FACTORY_NAME, WALLET_NAME, ZADDRESS } = require('./constants');
const { RefractSigner } = require('./utils');
const {Wallet, BN} = require('ethers');

module.exports = {
    use_erc20_and_deploy: async function use_erc20_and_deploy() {

        const RefractFactory_v0 = this.contracts[FACTORY_NAME];
        const RefractWallet_v0 = this.contracts[WALLET_NAME];
        const {ERC20} = this.contracts;

        const expect = this.expect;
        const accounts = this.accounts;

        let accountzbalance = 0;

        {
            const salt = 2702;
            const controller = Wallet.createRandom();

            const prediction = await RefractFactory_v0.predict(controller.address, salt);
            await web3.eth.sendTransaction({from: accounts[0], to: prediction, value: web3.utils.toWei('10', 'ether')});
            const net_id = await web3.eth.net.getId();

            const rsigner = new RefractSigner(net_id, prediction);
            const wrappedERC20 = rsigner.wrapContract(ERC20.contract);
            let [nonce, addr, nums, bdata] = await wrappedERC20.metaCall(0, controller, [{
                from: prediction,
                method: 'transfer',
                args: [accounts[0], 25],
                value: 0,
                relayer: ZADDRESS,
            }, {
                from: prediction,
                method: 'transfer',
                args: [accounts[0], 25],
                value: 0,
                relayer: ZADDRESS,
            }]);

            await ERC20.mint(prediction, 100);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(0);

            await RefractFactory_v0.mtxAndDeploy(
                controller.address,
                salt,
                addr, nums, bdata,
                {gasPrice: 1000000}
            );

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(50);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(50);

            const refract = await RefractWallet_v0.at(prediction);

            await expect(refract.isController(controller.address)).to.eventually.equal(true);
            await expect(refract.isController(accounts[0])).to.eventually.equal(false);
            await expect((await refract.version()).toNumber()).to.equal(0);

        }

    }
};
