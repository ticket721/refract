pragma solidity 0.5.13;

import "../../interfaces/v0/IRefractFactory_v0.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import "./RefractWallet_v0.sol";

contract RefractFactory_v0 is IRefractFactory_v0 {

    bytes4 constant public REFRACTFACTORY_V0_SIGNATURE = // 0x25961920
    bytes4(keccak256('version()')) ^
    bytes4(keccak256('predict(address,bytes)')) ^
    bytes4(keccak256('deploy(address,bytes)'));

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
        return ((interface_signature == ERC165_SIGNATURE) || (interface_signature == REFRACTFACTORY_V0_SIGNATURE));
    }

    function _getSalt(uint256 _salt, address _sender) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_salt, _sender));
    }

    function _createWallet(uint256 _salt, address _sender) internal returns (RefractWallet_v0) {
        address payable addr;
        bytes memory code = type(RefractWallet_v0).creationCode;
        bytes32 salt = _getSalt(_salt, _sender);

        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        address[] memory controllers = new address[](1);
        controllers[0] = _sender;
        RefractWallet_v0(addr).initialize_v0(controllers);

        return RefractWallet_v0(addr);
    }

    function version() external view returns (uint256 version_code) {
        return 0;
    }

    function predict(address owner, uint256 salt) external view returns (address) {
        bytes32 _salt = _getSalt(salt, owner);
        bytes32 rawAddress = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(type(RefractWallet_v0).creationCode)
            )
        );

        return address(bytes20(rawAddress << 96));
    }

    function deploy(address owner, uint256 salt) external returns (address) {
        return address(_createWallet(salt, owner));
    }

}
