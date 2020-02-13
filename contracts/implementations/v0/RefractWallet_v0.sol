pragma solidity 0.5.15;

import "../../interfaces/v0/IRefractWallet_v0.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RefractDomain_v0.sol";
import "./BytesUtil_v0.sol";

contract RefractWallet_v0 is IRefractWallet_v0, RefractDomain_v0 {

    bytes4 constant public REFRACTWALLET_V0_SIGNATURE = // 0x25961920
    bytes4(keccak256('version()')) ^
    bytes4(keccak256('isController(address)')) ^
    bytes4(keccak256('mtx(address[],uint256[],bytes)')) ^
    bytes4(keccak256('mtxr(address[],uint256[],bytes)')) ^
    bytes4(keccak256('mtxg(address[],uint256[],bytes)')) ^
    bytes4(keccak256('mtxgr(address[],uint256[],bytes)'));

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
    uint256 public nonce = 0;

    modifier v0_wallet_locker() {
        require(v0_wallet_lock == false, "RefractWallet_v0::v0_locker | initialization already happened");
        v0_wallet_lock = true;
        _;
    }

    mapping (address => bool) public controllers;

    function version() external view returns (uint256 version_code) {
        return 0;
    }

    function isController(address controller) external view returns (bool) {
        return controllers[controller];
    }

    function initialize_v0(address[] memory _controllers, uint256 chain_id) public v0_wallet_locker {
        for (uint256 idx = 0; idx < _controllers.length; ++idx) {
            controllers[_controllers[idx]] = true;
        }
        RefractDomain_v0.initialize_domain_v0("Refract Wallet", "0", chain_id);
    }

    modifier nonceCheck(uint256 _nonce) {
        require(_nonce == nonce, "RefractWallet::nonceCheck | invalid nonce");
        nonce += 1;
        _;
    }

    function _executeTx(address to, uint256 value, bytes memory data) internal {
        assembly {
            let message := mload(0x40)

            let result := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)

            let size := returndatasize

            returndatacopy(message, 0, size)

            if eq(result, 0) { revert(message, size) }
        }
    }

    function _executeTxWithGas(
        address to,
        uint256 value,
        bytes memory data,
        uint256 custom_gas
    ) internal {
        assembly {
            let message := mload(0x40)

            let result := call(custom_gas, to, value, add(data, 0x20), mload(data), 0, 0)

            let size := returndatasize

            returndatacopy(message, 0, size)

            if eq(result, 0) { revert(message, size) }
        }
    }

    function _recoverReward(address currency, uint256 value) internal {
        if (currency == address(0)) {
            msg.sender.transfer(value);
        } else {
            IERC20(currency).transfer(msg.sender, value);
        }
    }

    function mtx(
        uint256 nonce,
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external nonceCheck(nonce) {

        require(addr.length % 2 == 0,
            "RefractWallet::mtx | invalid addr argument length (should be 2n)");
        require(nums.length % 2 == 0,
            "RefractWallet::mtx | invalid nums argument length (should be 2n)");
        require(bdata.length >= 65,
            "RefractWallet::mtx | invalid bdata length (should be at least 65 bytes long)");
        require(nums.length / 2 == addr.length / 2,
            "RefractWallet::mtx | invalid number of packed txs (nums / 2 != addr / 2)");

        uint256 txs_count = addr.length / 2;

        {
            MetaTransaction memory mtx_payload = MetaTransaction({
                nonce: nonce,
                parameters: new TransactionParameters[](txs_count)
                });

            bytes memory sig = BytesUtil_v0.slice(bdata, 0, 65);
            uint256 bdata_idx = 65;

            for (uint256 idx = 0; idx < txs_count; ++idx) {

                bytes memory data = "";
                require(bdata.length >= bdata_idx + nums[(idx * 2) + 1], "RefractWallet::mtx | tx data size too small");
                data = BytesUtil_v0.slice(bdata, bdata_idx, nums[(idx * 2) + 1]);
                bdata_idx += nums[(idx * 2) + 1];

                mtx_payload.parameters[idx] = TransactionParameters({
                    from: address(this),
                    to: addr[(idx * 2)],
                    relayer: addr[(idx * 2) + 1],
                    data: data,
                    value: nums[(idx * 2)]
                    });

            }

            address signer = verify(mtx_payload, sig);
            require(controllers[signer] == true, "RefractWallet::mtx | signer is not controller");
        }

        {
            uint256 bdata_idx = 65;
            for (uint256 idx = 0; idx < txs_count; ++idx) {

                bytes memory data = "";
                data = BytesUtil_v0.slice(bdata, bdata_idx, nums[(idx * 2) + 1]);
                _executeTx(addr[(idx * 2)], nums[(idx * 2)], data);
                bdata_idx += nums[(idx * 2) + 1];

                emit MTX_Refraction(
                    addr[(idx * 2)],
                    addr[(idx * 2) + 1],
                    nums[(idx * 2)],
                    nonce,
                    data
                );

            }
        }


    }

    function() external payable {}

}
