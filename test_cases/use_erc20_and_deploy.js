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

            const rsigner = new RefractSigner(1, prediction);
            const wrappedERC20 = rsigner.wrapContract(ERC20.contract);
            let [addr, nums, bdata] = await wrappedERC20.metaCall('transfer', [accounts[0], 50], controller, 0, 0, ZADDRESS);

            await ERC20.mint(prediction, 100);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(0);

            // Calls ERC20 contract to order a transfer of 50 units
            await RefractFactory_v0.mtxAndDeploy(
                controller.address,
                salt,
                addr, nums, bdata,
                {gasPrice: 1000000}
            );

            const refract = await RefractWallet_v0.at(prediction);

            await expect(refract.isController(controller.address)).to.eventually.equal(true);
            await expect(refract.isController(accounts[0])).to.eventually.equal(false);
            await expect((await refract.version()).toNumber()).to.equal(0);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(50);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(50);
            accountzbalance += 50;
        }

        {
            const salt = 2702;
            const controller = Wallet.createRandom();

            const prediction = await RefractFactory_v0.predict(controller.address, salt);
            await web3.eth.sendTransaction({from: accounts[0], to: prediction, value: web3.utils.toWei('10', 'ether')});

            const rsigner = new RefractSigner(1, prediction);
            const wrappedERC20 = rsigner.wrapContract(ERC20.contract);
            let [addr, nums, bdata] = await wrappedERC20.metaCallWithReward('transfer', [accounts[0], 50], controller, 0, 0, ZADDRESS, ERC20.address, 50);

            await ERC20.mint(prediction, 100);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance);

            // Calls ERC20 contract to order a transfer of 50 units
            await RefractFactory_v0.mtxrAndDeploy(
                controller.address,
                salt,
                addr, nums, bdata,
                {gasPrice: 1000000}
            );

            const refract = await RefractWallet_v0.at(prediction);

            await expect(refract.isController(controller.address)).to.eventually.equal(true);
            await expect(refract.isController(accounts[0])).to.eventually.equal(false);
            await expect((await refract.version()).toNumber()).to.equal(0);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(0);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance + 100);
            accountzbalance += 100;
        }

        {
            const salt = 2702;
            const controller = Wallet.createRandom();

            const prediction = await RefractFactory_v0.predict(controller.address, salt);
            await web3.eth.sendTransaction({from: accounts[0], to: prediction, value: web3.utils.toWei('10', 'ether')});

            const rsigner = new RefractSigner(1, prediction);
            const wrappedERC20 = rsigner.wrapContract(ERC20.contract);
            let [addr, nums, bdata] = await wrappedERC20.metaCallWithReward('transfer', [accounts[0], 0], controller, 0, 0, ZADDRESS, ZADDRESS, 10);

            await ERC20.mint(prediction, 100);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance);

            // Calls ERC20 contract to order a transfer of 50 units
            await RefractFactory_v0.mtxrAndDeploy(
                controller.address,
                salt,
                addr, nums, bdata,
                {gasPrice: 1000000}
            );

            const refract = await RefractWallet_v0.at(prediction);

            await expect(refract.isController(controller.address)).to.eventually.equal(true);
            await expect(refract.isController(accounts[0])).to.eventually.equal(false);
            await expect((await refract.version()).toNumber()).to.equal(0);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance);
        }

        {
            const salt = 2702;
            const controller = Wallet.createRandom();

            const prediction = await RefractFactory_v0.predict(controller.address, salt);
            await web3.eth.sendTransaction({from: accounts[0], to: prediction, value: web3.utils.toWei('10', 'ether')});

            const rsigner = new RefractSigner(1, prediction);
            const wrappedERC20 = rsigner.wrapContract(ERC20.contract);
            let [addr, nums, bdata] = await wrappedERC20.metaCallWithGas('transfer', [accounts[0], 50], controller, 0, 0, ZADDRESS, 1000, 1000000);

            await ERC20.mint(prediction, 100);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance);

            // Calls ERC20 contract to order a transfer of 50 units
            await RefractFactory_v0.mtxgAndDeploy(
                controller.address,
                salt,
                addr, nums, bdata,
                {gasPrice: 1000000}
            );

            const refract = await RefractWallet_v0.at(prediction);

            await expect(refract.isController(controller.address)).to.eventually.equal(true);
            await expect(refract.isController(accounts[0])).to.eventually.equal(false);
            await expect((await refract.version()).toNumber()).to.equal(0);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(50);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance + 50);
            accountzbalance += 50;
        }

        {
            const salt = 2702;
            const controller = Wallet.createRandom();

            const prediction = await RefractFactory_v0.predict(controller.address, salt);
            await web3.eth.sendTransaction({from: accounts[0], to: prediction, value: web3.utils.toWei('10', 'ether')});

            const rsigner = new RefractSigner(1, prediction);
            const wrappedERC20 = rsigner.wrapContract(ERC20.contract);
            let [addr, nums, bdata] = await wrappedERC20.metaCallWithGasAndReward('transfer', [accounts[0], 50], controller, 0, 0, ZADDRESS, 1000, 1000000, ERC20.address, 50);

            await ERC20.mint(prediction, 100);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(100);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance);

            // Calls ERC20 contract to order a transfer of 50 units
            await RefractFactory_v0.mtxgrAndDeploy(
                controller.address,
                salt,
                addr, nums, bdata,
                {gasPrice: 1000000}
            );

            const refract = await RefractWallet_v0.at(prediction);

            await expect(refract.isController(controller.address)).to.eventually.equal(true);
            await expect(refract.isController(accounts[0])).to.eventually.equal(false);
            await expect((await refract.version()).toNumber()).to.equal(0);

            expect((await ERC20.balanceOf(prediction)).toNumber()).to.equal(0);
            expect((await ERC20.balanceOf(accounts[0])).toNumber()).to.equal(accountzbalance + 100);
            accountzbalance += 100;
        }
    }
};
