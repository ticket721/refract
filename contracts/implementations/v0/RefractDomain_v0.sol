pragma solidity 0.5.15;

contract RefractDomain_v0 {

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function _splitSignature(bytes memory signature) internal pure returns (Signature memory sig) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := and(mload(add(signature, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid v argument");
        return Signature({
            v: v,
            r: r,
            s: s
            });
    }

    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    function hash(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(eip712Domain.name)),
                keccak256(bytes(eip712Domain.version)),
                eip712Domain.chainId,
                eip712Domain.verifyingContract
            ));
    }

    bytes32 DOMAIN_SEPARATOR;

    struct TransactionParameters {
        address from;
        address to;
        address relayer;
        uint256 value;
        bytes data;
    }

    bytes32 constant TRANSACTIONPARAMETERS_TYPEHASH = keccak256(
        "TransactionParameters(address from,address to,address relayer,uint256 value,bytes data)"
    );

    function hash(TransactionParameters memory txp) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                TRANSACTIONPARAMETERS_TYPEHASH,
                txp.from,
                txp.to,
                txp.relayer,
                txp.value,
                keccak256(txp.data)
            ));
    }

    struct Reward {
        address currency;
        uint256 value;
    }

    bytes32 constant REWARD_TYPEHASH = keccak256(
        "Reward(address currency,uint256 value)"
    );

    function hash(Reward memory reward) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                REWARD_TYPEHASH,
                reward.currency,
                reward.value
            ));
    }

    struct GasParameters {
        uint256 gasLimit;
        uint256 gasPrice;
    }

    bytes32 constant GASPARAMETERS_TYPEHASH = keccak256(
        "GasParameters(uint256 gasLimit,uint256 gasPrice)"
    );

    function hash(GasParameters memory gp) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                GASPARAMETERS_TYPEHASH,
                gp.gasLimit,
                gp.gasPrice
            ));
    }

    struct MetaTransaction {
        TransactionParameters[] parameters;
        uint256 nonce;
    }

    bytes32 constant METATRANSACTION_TYPEHASH = keccak256(
    // solhint-disable-next-line max-line-length
        "MetaTransaction(TransactionParameters[] parameters,uint256 nonce)TransactionParameters(address from,address to,address relayer,uint256 value,bytes data)"
    );

    function hash(MetaTransaction memory mtx) internal pure returns (bytes32) {

        bytes32[] memory encodedParameters =  new bytes32[](mtx.parameters.length);

        for (uint256 idx = 0; idx < mtx.parameters.length; ++idx) {
            encodedParameters[idx] = hash(mtx.parameters[idx]);
        }

        return keccak256(abi.encode(
                METATRANSACTION_TYPEHASH,
                keccak256(abi.encodePacked(
                    encodedParameters
                )),
                mtx.nonce
            ));
    }

    function verify(MetaTransaction memory mtx, bytes memory raw_signature) internal view returns (address) {
        Signature memory signature = _splitSignature(raw_signature);
        bytes32 digest = keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                hash(mtx)
            ));
        return ecrecover(digest, signature.v, signature.r, signature.s);
    }

    // struct MetaTransactionWithReward {
    //     TransactionParameters parameters;
    //     Reward reward;
    // }

    // bytes32 constant METATRANSACTIONWITHREWARD_TYPEHASH = keccak256(
    // solhint-disable-next-line max-line-length
    //     "MetaTransactionWithReward(TransactionParameters parameters,Reward reward)Reward(address currency,uint256 value)TransactionParameters(address from,address to,address relayer,uint256 value,bytes dat// a,uint256 nonce)"
    // );

    // function hash(MetaTransactionWithReward memory mtxr) internal pure returns (bytes32) {
    //     return keccak256(abi.encode(
    //             METATRANSACTIONWITHREWARD_TYPEHASH,
    //             hash(mtxr.parameters),
    //             hash(mtxr.reward)
    //         ));
    // }

    // solhint-disable-next-line max-line-length
    // function verify(MetaTransactionWithReward memory mtxr, bytes memory raw_signature) internal view returns (address) {
    //     Signature memory signature = _splitSignature(raw_signature);
    //     bytes32 digest = keccak256(abi.encodePacked(
    //             "\x19\x01",
    //             DOMAIN_SEPARATOR,
    //             hash(mtxr)
    //         ));
    //     return ecrecover(digest, signature.v, signature.r, signature.s);
    // }

    // struct MetaTransactionWithGas {
    //     TransactionParameters parameters;
    //     GasParameters gas;
    // }

    // bytes32 constant METATRANSACTIONWITHGAS_TYPEHASH = keccak256(
    // solhint-disable-next-line max-line-length
    //     "MetaTransactionWithGas(TransactionParameters parameters,GasParameters gas)GasParameters(uint256 gasLimit,uint256 gasPrice)TransactionParameters(address from,address to,address relayer,uint256 val// ue,bytes data,uint256 nonce)"
    // );

    // function hash(MetaTransactionWithGas memory mtxg) internal pure returns (bytes32) {
    //     return keccak256(abi.encode(
    //             METATRANSACTIONWITHGAS_TYPEHASH,
    //             hash(mtxg.parameters),
    //             hash(mtxg.gas)
    //         ));
    // }

    // function verify(MetaTransactionWithGas memory mtxg, bytes memory raw_signature) internal view returns (address) {
    //     Signature memory signature = _splitSignature(raw_signature);
    //     bytes32 digest = keccak256(abi.encodePacked(
    //             "\x19\x01",
    //             DOMAIN_SEPARATOR,
    //             hash(mtxg)
    //         ));
    //     return ecrecover(digest, signature.v, signature.r, signature.s);
    // }

    // struct MetaTransactionWithGasAndReward {
    //     TransactionParameters parameters;
    //     GasParameters gas;
    //     Reward reward;
    // }

    // bytes32 constant METATRANSACTIONWITHGASANDREWARD_TYPEHASH = keccak256(
    // solhint-disable-next-line max-line-length
    //     "MetaTransactionWithGasAndReward(TransactionParameters parameters,GasParameters gas,Reward reward)GasParameters(uint256 gasLimit,uint256 gasPrice)Reward(address currency,uint256 value)Tra// nsactionParameters(address from,address to,address relayer,uint256 value,bytes data,uint256 nonce)"
    // );

    // function hash(MetaTransactionWithGasAndReward memory mtxgr) internal pure returns (bytes32) {
    //     return keccak256(abi.encode(
    //             METATRANSACTIONWITHGASANDREWARD_TYPEHASH,
    //             hash(mtxgr.parameters),
    //             hash(mtxgr.gas),
    //             hash(mtxgr.reward)
    //         ));
    // }

    // function verify(
    //     MetaTransactionWithGasAndReward memory mtxgr,
    //     bytes memory raw_signature
    // ) internal view returns (address) {
    //     Signature memory signature = _splitSignature(raw_signature);
    //     bytes32 digest = keccak256(abi.encodePacked(
    //             "\x19\x01",
    //             DOMAIN_SEPARATOR,
    //             hash(mtxgr)
    //         ));
    //     return ecrecover(digest, signature.v, signature.r, signature.s);
    // }

    bool private v0_domain_lock = false;

    modifier v0_domain_locker() {
        require(v0_domain_lock == false, "RefractDomain_v0::v0_locker | initialization already happened");
        v0_domain_lock = true;
        _;
    }

    function initialize_domain_v0(
        string memory _domain_name,
        string memory _version,
        uint256 _chainId
    ) internal v0_domain_locker {
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: _domain_name,
            version: _version,
            chainId: _chainId,
            verifyingContract: address(this)
            }));
    }


}
