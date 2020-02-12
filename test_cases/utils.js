const ethers = require('ethers');
const {EIP712Signer} = require('@ticket721/e712');

const expect_map = async (dai, daiplus, t721, accounts, dai_balances, daiplus_balances, t721_balances, expect) => {

    for (let idx = 0; idx < accounts.length; ++idx) {

        const account = accounts[idx];

        const dai_balance = (await dai.balanceOf(account)).toNumber();
        const daiplus_balance = (await daiplus.balanceOf(account)).toNumber();
        const t721_balance = (await t721.balanceOf(account)).toNumber();

        expect(dai_balance).to.equal(dai_balances[idx]);
        expect(daiplus_balance).to.equal(daiplus_balances[idx]);
        expect(t721_balance).to.equal(t721_balances[idx]);

    }

};

const getEthersERC20Contract = async (erc20_artifact, erc20_instance, wallet) => {
    const provider = new ethers.providers.Web3Provider(web3.currentProvider);
    const connected_wallet = new ethers.Wallet(wallet.privateKey, provider);

    const devdai_factory = new ethers.ContractFactory(erc20_artifact.abi, erc20_artifact.deployedBytecode, wallet, wallet);
    const devdai_ethers = await devdai_factory.attach(erc20_instance.address);
    return devdai_ethers.connect(connected_wallet)
};

const snapshot = () => {
    return new Promise((ok, ko) => {
        web3.currentProvider.send({
            method: 'evm_snapshot',
            params: [],
            jsonrpc: '2.0',
            id: new Date().getTime()
        }, (error, res) => {
            if (error) {
                return ko(error);
            } else {
                ok(res.result);
            }
        })
    })
};

const revert = (snap_id) => {
    return new Promise((ok, ko) => {
        web3.currentProvider.send({
            method: 'evm_revert',
            params: [snap_id],
            jsonrpc: '2.0',
            id: new Date().getTime()
        }, (error, res) => {
            if (error) {
                return ko(error);
            } else {
                ok(res.result);
            }
        })
    })
};

const ZERO = '0x0000000000000000000000000000000000000000';
const ZEROSIG = `0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000`

const TransactionParameters = [
    {
        name: 'from',
        type: 'address'
    },
    {
        name: 'to',
        type: 'address'
    },
    {
        name: 'relayer',
        type: 'address'
    },
    {
        name: 'value',
        type: 'uint256'
    },
    {
        name: 'data',
        type: 'bytes'
    }
];

const Reward = [
    {
        name: 'currency',
        type: 'address'
    },
    {
        name: 'value',
        type: 'uint256'
    }
];

const GasParameters = [
    {
        name: 'gasLimit',
        type: 'uint256'
    },
    {
        name: 'gasPrice',
        type: 'uint256'
    }
];

const MetaTransaction = [
    {
        name: 'parameters',
        type: 'TransactionParameters[]'
    },
    {
        name: 'nonce',
        type: 'uint256'
    }
];

const MetaTransactionWithReward = [
    {
        name: 'parameters',
        type: 'TransactionParameters'
    },
    {
        name: 'reward',
        type: 'Reward'
    }
];

const MetaTransactionWithGas = [
    {
        name: 'parameters',
        type: 'TransactionParameters'
    },
    {
        name: 'gas',
        type: 'GasParameters'
    }
];

const MetaTransactionWithGasAndReward = [
    {
        name: 'parameters',
        type: 'TransactionParameters'
    },
    {
        name: 'gas',
        type: 'GasParameters'
    },
    {
        name: 'reward',
        type: 'Reward'
    }
];

class RefractContract {

    constructor(signer, contract) {
        this.signer = signer;
        this.contract = contract;
    }

    async metaCall(nonce, wallet, txdata) {

        const payload = {
            nonce,
            parameters: []
        };

        for (const tx of txdata) {
            const {method, from, args, value, relayer} = tx;

            const data = this.contract.methods[method](...args).encodeABI();

            payload.parameters.push({
                from,
                to: this.contract._address,
                data,
                value,
                relayer
            });

        }

        const sig = await this.signer.signMetaTransaction(payload, wallet.privateKey);

        const nums = [];
        const addrs = [];
        let bdata = `${sig.hex}`;

        for (const tx of payload.parameters) {
            nums.push(tx.value);
            nums.push((tx.data.length - 2) / 2);

            addrs.push(tx.to);
            addrs.push(tx.relayer);

            bdata = `${bdata}${tx.data.slice(2)}`;
        }

        return [
            nonce,
            addrs,
            nums,
            bdata
        ]

    }

}

class RefractSigner extends EIP712Signer {

    constructor(chain_id, address) {
        super({
                name: 'Refract Wallet',
                version: '0',
                chainId: chain_id,
                verifyingContract: address
            },
            ['TransactionParameters', TransactionParameters],
            ['Reward', Reward],
            ['GasParameters', GasParameters],
            ['MetaTransaction', MetaTransaction],
            ['MetaTransactionWithReward', MetaTransactionWithReward],
            ['MetaTransactionWithGas', MetaTransactionWithGas],
            ['MetaTransactionWithGasAndReward', MetaTransactionWithGasAndReward],
        );
        this.wallet_address = address;
    }

    wrapContract(contract) {
        return new RefractContract(this, contract);
    }

    signMetaTransaction(args, privateKey) {
        const payload = this.generatePayload(args, 'MetaTransaction');

        return this.sign(privateKey, payload, true);
    }

    signMetaTransactionWithReward(args, reward, privateKey) {
        args.from = this.wallet_address;
        const payload = this.generatePayload({parameters: args, reward}, 'MetaTransactionWithReward');
        return this.sign(privateKey, payload, true);
    }

    signMetaTransactionWithGas(args, gas, privateKey) {
        args.from = this.wallet_address;
        const payload = this.generatePayload({parameters: args, gas}, 'MetaTransactionWithGas');
        return this.sign(privateKey, payload, true);
    }

    signMetaTransactionWithGasAndReward(args, gas, reward, privateKey) {
        args.from = this.wallet_address;
        const payload = this.generatePayload({parameters: args, gas, reward}, 'MetaTransactionWithGasAndReward');
        return this.sign(privateKey, payload, true);
    }
}


module.exports = {
    ZERO,
    ZEROSIG,
    revert,
    snapshot,
    expect_map,
    getEthersERC20Contract,
    RefractSigner
}
