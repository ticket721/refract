pragma solidity 0.5.13;

import "../../interfaces/v0/IRefractWallet_v0.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RefractDomain_v0.sol";
import "./BytesUtil_v0.sol";

contract RefractWallet_v0 is IRefractWallet_v0, RefractDomain_v0 {

    bytes4 constant public REFRACTWALLET_V0_SIGNATURE = // 0x25961920
    bytes4(keccak256('version()')) ^
    bytes4(keccak256('isController(address)')) ^
    bytes4(keccak256('MTX(address[],uint256[],bytes)'));

    //
    // bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
    //
    bytes4 public constant ERC165_SIGNATURE = 0x01ffc9a7;

    //
    // @notice Utility from the ERC165 standard, used to signal outside contracts that a specific interface
    //         is respected by the contract
    //
    // @param interface_signature Signature of the interface to verify
    //
    function supportsInterface(bytes4 interface_signature) external pure returns (bool) {
        return ((interface_signature == ERC165_SIGNATURE) || (interface_signature == REFRACTWALLET_V0_SIGNATURE));
    }

    bool private v0_wallet_lock = false;

    modifier v0_wallet_locker() {
        require(v0_wallet_lock == false, "RefractWallet_v0::v0_locker | initialization already happened");
        v0_wallet_lock = true;
        _;
    }

    mapping (address => bool) public controllers;
    uint256 nonce = 0;

    function version() external view returns (uint256 version_code) {
        return 0;
    }

    function isController(address controller) external view returns (bool) {
        return controllers[controller];
    }

    function initialize_v0(address[] memory _controllers) public v0_wallet_locker {
        for (uint256 idx = 0; idx < _controllers.length; ++idx) {
            controllers[_controllers[idx]] = true;
        }
        RefractDomain_v0.initialize_domain_v0("Refract Wallet", "0", 1);
    }

    modifier nonceCheck(uint256 _nonce) {
        require(nonce == _nonce, "RefractWallet::nonceCheck | invalid nonce");
        ++nonce;
        _;
    }

    function _executeTx(address to, uint256 value, bytes memory data) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)
            result := call(gas, to, value, add(data, 0x20), mload(data), x, 0)
        }
        return result;
    }

    function _executeTxWithGas(
        address to,
        uint256 value,
        bytes memory data,
        uint256 custom_gas
    ) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)
            result := call(custom_gas, to, value, add(data, 0x20), mload(data), x, 0)
        }
        return result;
    }

    function _recoverReward(address currency, uint256 value) internal {
        if (currency == address(0)) {
            msg.sender.transfer(value);
        } else {
            IERC20(currency).transfer(msg.sender, value);
        }
    }

    function mtx(address[] calldata addr, uint256[] calldata nums, bytes calldata bdata) external nonceCheck(nums[0]) {

        require(addr.length == 2, "RefractWallet::mtx | invalid addr argument length (should be 2)");
        require(nums.length == 2, "RefractWallet::mtx | invalid nums argument length (should be 2)");
        require(bdata.length >= 65, "RefractWallet::mtx | invalid bdata length (should be at least 65 bytes)");

        bytes memory data = "";
        {
            bytes memory sig = BytesUtil_v0.slice(bdata, 0, 65);
            if (bdata.length > 65) {
                data = BytesUtil_v0.slice(bdata, 65, bdata.length - 65);
            }

            TransactionParameters memory parameters = TransactionParameters({
                from: address(this),
                to: addr[0],
                relayer: addr[1],
                data: data,
                nonce: nums[0],
                value: nums[1]
                });

            MetaTransaction memory mtx_payload = MetaTransaction({
                parameters: parameters
                });

            address signer = verify(mtx_payload, sig);
            require(controllers[signer] == true, "RefractWallet::mtx | signer is not controller");
        }

        _executeTx(addr[0], nums[1], data);
        emit MTX_Refraction(addr[0], addr[1], nums[1], nums[0], data);

    }

    function mtxr(
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external nonceCheck(nums[0]) {

        require(addr.length == 3, "RefractWallet::mtxr | invalid addr argument length (should be 3)");
        require(nums.length == 3, "RefractWallet::mtxr | invalid nums argument length (should be 3)");
        require(bdata.length >= 65, "RefractWallet::mtxr | invalid bdata length (should be at least 65 bytes)");

        bytes memory data = "";
        {
            bytes memory sig = BytesUtil_v0.slice(bdata, 0, 65);
            if (bdata.length > 65) {
                data = BytesUtil_v0.slice(bdata, 65, bdata.length - 65);
            }

            TransactionParameters memory parameters = TransactionParameters({
                from: address(this),
                to: addr[0],
                relayer: addr[1],
                data: data,
                nonce: nums[0],
                value: nums[1]
                });

            Reward memory reward = Reward({
                currency: addr[2],
                value: nums[2]
                });

            MetaTransactionWithReward memory mtxr_payload = MetaTransactionWithReward({
                parameters: parameters,
                reward: reward
                });

            address signer = verify(mtxr_payload, sig);
            require(controllers[signer] == true, "RefractWallet::mtxr | signer is not controller");
        }

        _recoverReward(addr[2], nums[2]);
        require(_executeTx(addr[0], nums[1], data), "RefractWallet::mtxr | execution error");
        emit MTXR_Refraction(addr[0], addr[1], nums[1], nums[0], data, addr[2], nums[2]);

    }

    function mtxg(
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external nonceCheck(nums[0]) {

        require(addr.length == 2, "RefractWallet::mtxg | invalid addr argument length (should be 2)");
        require(nums.length == 4, "RefractWallet::mtxg | invalid nums argument length (should be 4)");
        require(bdata.length >= 65, "RefractWallet::mtxg | invalid bdata length (should be at least 65 bytes)");

        bytes memory data = "";
        {
            bytes memory sig = BytesUtil_v0.slice(bdata, 0, 65);
            if (bdata.length > 65) {
                data = BytesUtil_v0.slice(bdata, 65, bdata.length - 65);
            }

            TransactionParameters memory parameters = TransactionParameters({
                from: address(this),
                to: addr[0],
                relayer: addr[1],
                data: data,
                nonce: nums[0],
                value: nums[1]
                });

            GasParameters memory gas = GasParameters({
                gasLimit: nums[2],
                gasPrice: nums[3]
                });

            MetaTransactionWithGas memory mtxg_payload = MetaTransactionWithGas({
                parameters: parameters,
                gas: gas
                });

            address signer = verify(mtxg_payload, sig);
            require(controllers[signer] == true, "RefractWallet::mtxg | signer is not controller");
        }

        require(tx.gasprice >= nums[3], "RefractWallet::mtxg | gasPrice too low");
        require(_executeTxWithGas(addr[0], nums[1], data, nums[2]), "RefractWallet::mtxg | execution error");
        emit MTXG_Refraction(addr[0], addr[1], nums[1], nums[0], data, nums[2], nums[3]);

    }

    function mtxgr(
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external nonceCheck(nums[0]) {

        require(addr.length == 3, "RefractWallet::mtxgr | invalid addr argument length (should be 3)");
        require(nums.length == 5, "RefractWallet::mtxgr | invalid nums argument length (should be 5)");
        require(bdata.length >= 65, "RefractWallet::mtxgr | invalid bdata length (should be at least 65 bytes)");

        bytes memory data = "";
        {
            bytes memory sig = BytesUtil_v0.slice(bdata, 0, 65);
            if (bdata.length > 65) {
                data = BytesUtil_v0.slice(bdata, 65, bdata.length - 65);
            }

            TransactionParameters memory parameters = TransactionParameters({
                from: address(this),
                to: addr[0],
                relayer: addr[1],
                data: data,
                nonce: nums[0],
                value: nums[1]
                });

            GasParameters memory gas = GasParameters({
                gasLimit: nums[2],
                gasPrice: nums[3]
                });

            Reward memory reward = Reward({
                currency: addr[2],
                value: nums[4]
                });

            MetaTransactionWithGasAndReward memory mtxgr_payload = MetaTransactionWithGasAndReward({
                parameters: parameters,
                gas: gas,
                reward: reward
                });

            address signer = verify(mtxgr_payload, sig);
            require(controllers[signer] == true, "RefractWallet::mtxgr | signer is not controller");
        }

        require(tx.gasprice >= nums[3], "RefractWallet::mtxgr | gasPrice too low");
        _recoverReward(addr[2], nums[4]);
        require(_executeTxWithGas(addr[0], nums[1], data, nums[2]), "RefractWallet::mtxgr | execution error");
        emit MTXGR_Refraction(addr[0], addr[1], nums[1], nums[0], data, nums[2], nums[3], addr[2], nums[4]);

    }

    function() external payable {}

}
