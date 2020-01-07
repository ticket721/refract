const { FACTORY_NAME, WALLET_NAME } = require('../test_cases/constants');

const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const { revert, snapshot } = require('../test_cases/utils');
chai.use(chaiAsPromised);
const expect = chai.expect;

const { versions } = require('../test_cases/versions');
const { use_erc20 } = require('../test_cases/use_erc20');
const { use_erc20_and_deploy } = require('../test_cases/use_erc20_and_deploy');

contract('Refract', (accounts) => {

    before(async function () {
        const RefractFactoryArtifact = artifacts.require(FACTORY_NAME);
        const RefractWalletArtifact = artifacts.require(WALLET_NAME);
        const RefractFactoryInstance = await RefractFactoryArtifact.deployed();
        const ERC20MockArtifact = artifacts.require('ERC20Mock_v0');
        //const MetaMarketplaceArtifact = artifacts.require(CONTRACT_NAME);

        const ERC20Instance = await ERC20MockArtifact.deployed();
        //const MetaMarketplaceInstance = await MetaMarketplaceArtifact.new(CHAIN_ID, ERC20Instance.address, ERC2280Instance.address, ERC721Instance.address);

        //await ERC721Instance.createScope(SCOPE_NAME, '0x0000000000000000000000000000000000000000', [MetaMarketplaceInstance.address], []);
        //const scope = await ERC721Instance.getScope(SCOPE_NAME);
        //setScopeIndex(scope.scope_index.toNumber());

        this.contracts = {
            [FACTORY_NAME]: RefractFactoryInstance,
            [WALLET_NAME]: RefractWalletArtifact,
            ERC20: ERC20Instance,
        };

        this.snap_id = await snapshot();
        this.accounts = accounts;
        this.expect = expect;
    });

    beforeEach(async function () {
        const status = await revert(this.snap_id);
        expect(status).to.be.true;
        this.snap_id = await snapshot();
    });

    describe('usage', function () {

        it('versions', versions);
        it('use erc20', use_erc20);
        it('use erc20 and deploy', use_erc20_and_deploy)

    });

});
