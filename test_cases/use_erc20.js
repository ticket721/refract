const { FACTORY_NAME, WALLET_NAME, ZADDRESS } = require('./constants');
const { RefractSigner } = require('./utils');
const {Wallet, BN} = require('ethers');

module.exports = {
    use_erc20: async function use_erc20() {

        const RefractFactory_v0 = this.contracts[FACTORY_NAME];
        const RefractWallet_v0 = this.contracts[WALLET_NAME];
        const {ERC20} = this.contracts;

        const expect = this.expect;
        const accounts = this.accounts;

        const salt = 2702;
        const controller = Wallet.createRandom();


        const prediction = await RefractFactory_v0.predict(controller.address, salt);
        await RefractFactory_v0.deploy(controller.address, salt);

        await web3.eth.sendTransaction({from: accounts[0], to: prediction, value: web3.utils.toWei('10', 'ether')});

        const refract = await RefractWallet_v0.at(prediction);

        await expect(refract.isController(controller.address)).to.eventually.equal(true);
        await expect(refract.isController(accounts[0])).to.eventually.equal(false);
        await expect((await refract.version()).toNumber()).to.equal(0);

        await ERC20.mint(prediction, 100);
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

        expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
        expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(0);

        // Calls ERC20 contract to order a transfer of 50 units
        await refract.mtx(
            nonce, addr, nums, bdata,
            {gasPrice: 1000000}
        );

        expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(50);
        expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(50);

        // [addr, nums, bdata] = await wrappedERC20.metaCallWithReward('transfer', [accounts[0], 10], controller, 0, 1, ZADDRESS, ZADDRESS, web3.utils.toWei('1', 'ether'));

        // expect((await web3.eth.getBalance(prediction))).to.equal(web3.utils.toWei('10', 'ether'));

        // // Calls ERC20 contract to order a transfer of 50 units
        // await refract.mtxr(
        //     addr, nums, bdata,
        //     {gasPrice: 1000000}
        // );

        // expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(40);
        // expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(60);
        // expect((await web3.eth.getBalance(prediction))).to.equal(web3.utils.toWei('9', 'ether'));

        // [addr, nums, bdata] = await wrappedERC20.metaCallWithGas('transfer', [accounts[0], 10], controller, 0, 2, ZADDRESS, 1000000, 1000000);

        // // Calls ERC20 contract to order a transfer of 50 units
        // await refract.mtxg(
        //     addr, nums, bdata,
        //     {gasPrice: 1000000}
        // );

        // expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(30);
        // expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(70);

        // [addr, nums, bdata] = await wrappedERC20.metaCallWithGasAndReward('transfer', [accounts[0], 10], controller, 0, 3, ZADDRESS, 1000000, 1000000, ERC20.a// ddress, 10);

        // // Calls ERC20 contract to order a transfer of 50 units
        // await refract.mtxgr(
        //     addr, nums, bdata,
        //     {gasPrice: 1000000}
        // );

        // expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(10);
        // expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(90);

    }
};
