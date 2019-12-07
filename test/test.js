const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const { revert, snapshot } = require('../test_cases/utils');
chai.use(chaiAsPromised);
const expect = chai.expect;

const { placeholder } = require('../test_cases/placeholder');

contract('Refract', (accounts) => {

    before(async function () {
        //const ERC20MockArtifact = artifacts.require('ERC20Mock_v0');
        //const ERC2280MockArtifact = artifacts.require('ERC2280Mock_v0');
        //const ERC721MockArtifact = artifacts.require('ERC721Mock_v0');
        //const MetaMarketplaceArtifact = artifacts.require(CONTRACT_NAME);

        //const ERC20Instance = await ERC20MockArtifact.deployed();
        //const ERC2280Instance = await ERC2280MockArtifact.deployed();
        //const ERC721Instance = await ERC721MockArtifact.deployed();
        //const MetaMarketplaceInstance = await MetaMarketplaceArtifact.new(CHAIN_ID, ERC20Instance.address, ERC2280Instance.address, ERC721Instance.address);

        //await ERC721Instance.createScope(SCOPE_NAME, '0x0000000000000000000000000000000000000000', [MetaMarketplaceInstance.address], []);
        //const scope = await ERC721Instance.getScope(SCOPE_NAME);
        //setScopeIndex(scope.scope_index.toNumber());

        //this.contracts = {
        //    [CONTRACT_NAME]: MetaMarketplaceInstance,
        //    ERC20: ERC20Instance,
        //    ERC2280: ERC2280Instance,
        //    ERC721: ERC721Instance
        //};

        this.snap_id = await snapshot();
        this.accounts = accounts;
        this.expect = expect;
    });

    beforeEach(async function () {
        const status = await revert(this.snap_id);
        expect(status).to.be.true;
        this.snap_id = await snapshot();
    });

    describe('placeholder', function () {

        it('placeholder', placeholder);

    });

});
