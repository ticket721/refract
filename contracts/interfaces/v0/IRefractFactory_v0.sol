pragma solidity 0.5.15;

interface IRefractFactory_v0 {

    //
    // @notice Returns code of currently used interface
    //
    function version() external view returns (uint256 version_code);

    //
    // @notice Utility to predict creation address of deploy call. Useful to know in advance what is going
    //         to be the created RefractWallet address, before any transaction is triggered by the owner.
    //
    // @param owner Initial owner of the RefractWallet
    //
    // @param salt Bytes extra argument or salt for the RefractWallet creation
    //
    function predict(address owner, uint256 salt) external view returns (address contract_address);

    //
    // @notice Creates a new RefractWallet for a specific owner
    //
    // @param owner Initial owner of the RefractWallet
    //
    // @param salt Bytes extra argument or salt for the RefractWallet creation
    //
    function deploy(address owner, uint256 salt) external returns (address contract_address);

    //
    // @notice Method to execute a simple meta transaction (mtx)
    //
    // @param owner Initial owner of the RefractWallet
    //
    // @param salt Bytes extra argument or salt for the RefractWallet creation
    //
    // @param addr Array containing address arguments for the meta transaction
    //
    //             ```
    //             | to      | > Transaction target address
    //             | relayer | > Meta Transaction relayer address
    //             ```
    //
    // @notice to is not required as it is implicitely set to the address of the contract.
    // @notice relayer can be set to address(0) to remove any relayer verification.
    //
    // @param nums Array containing uint256 arguments for the meta transaction
    //
    //             ```
    //             | nonce   | > Nonce of the meta transaction
    //             | value   | > Amount of eth to use in the transaction
    //             ```
    //
    // @param bdata Contains the signature of a controller, respecting the ERC712 standard, signing an mtx
    //                  data structure type, followed by transaction data.
    //
    // @dev this method should throw if account is already deployed
    //
    function mtxAndDeploy(
        address owner,
        uint256 salt,
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external;

    //
    // @notice Method to execute a meta transaction with gas requirements
    //
    // @param owner Initial owner of the RefractWallet
    //
    // @param salt Bytes extra argument or salt for the RefractWallet creation
    //
    // @param addr Array containing address arguments for the meta transaction
    //
    //             ```
    //             | to      | > Transaction target address
    //             | relayer | > Meta Transaction relayer address
    //             ```
    //
    // @notice to is not required as it is implicitely set to the address of the contract.
    // @notice relayer can be set to address(0) to remove any relayer verification.
    //
    // @param nums Array containing uint256 arguments for the meta transaction
    //
    //             ```
    //             | nonce    | > Nonce of the meta transaction
    //             | value    | > Amount of eth to use in the transaction
    //             | gasLimit | > Minimum amount of gas to use for the meta transaction
    //             | gasPrice | > Minimum gas price to use for the meta transaction
    //             ```
    //
    // @param bdata Contains the signature of a controller, respecting the ERC712 standard, signing an mtx
    //                  data structure type, followed by transaction data.
    //
    // @dev this method should throw if account is already deployed
    //
    function mtxgAndDeploy(
        address owner,
        uint256 salt,
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external;

    //
    // @notice Method to execute a meta transaction with reward
    //
    // @param owner Initial owner of the RefractWallet
    //
    // @param salt Bytes extra argument or salt for the RefractWallet creation
    //
    // @param addr Array containing address arguments for the meta transaction
    //
    //             ```
    //             | to          | > Transaction target address
    //             | relayer     | > Meta Transaction relayer address
    //             | rewardToken | > Address of the currency to use as a reward
    //             ```
    //
    // @notice to is not required as it is implicitely set to the address of the contract.
    // @notice relayer can be set to address(0) to remove any relayer verification.
    // @notice rewardToken can be set to address(0) to give a reward in $ETH
    //
    // @param nums Array containing uint256 arguments for the meta transaction
    //
    //             ```
    //             | nonce       | > Nonce of the meta transaction
    //             | value       | > Amount of eth to use in the transaction
    //             | rewardValue | > Amount of token to reward the relayer
    //             ```
    //
    // @param bdata Contains the signature of a controller, respecting the ERC712 standard, signing an mtx
    //                  data structure type, followed by transaction data.
    //
    // @dev this method should throw if account is already deployed
    //
    function mtxrAndDeploy(
        address owner,
        uint256 salt,
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external;

    //
    // @notice Method to execute a meta transaction with reward & gas requirements
    //
    // @param owner Initial owner of the RefractWallet
    //
    // @param salt Bytes extra argument or salt for the RefractWallet creation
    //
    // @param addr Array containing address arguments for the meta transaction
    //
    //             ```
    //             | to          | > Transaction target address
    //             | relayer     | > Meta Transaction relayer address
    //             | rewardToken | > Address of the currency to use as a reward
    //             ```
    //
    // @notice to is not required as it is implicitely set to the address of the contract.
    // @notice relayer can be set to address(0) to remove any relayer verification.
    // @notice rewardToken can be set to address(0) to give a reward in $ETH
    //
    // @param nums Array containing uint256 arguments for the meta transaction
    //
    //             ```
    //             | nonce       | > Nonce of the meta transaction
    //             | value       | > Amount of eth to use in the transaction
    //             | gasLimit    | > Minimum amount of gas to use for the meta transaction
    //             | gasPrice    | > Minimum gas price to use for the meta transaction
    //             | rewardValue | > Amount of token to reward the relayer
    //             ```
    //
    // @param bdata Contains the signature of a controller, respecting the ERC712 standard, signing an mtx
    //                  data structure type, followed by transaction data.
    //
    // @dev this method should throw if account is already deployed
    //
    function mtxgrAndDeploy(
        address owner,
        uint256 salt,
        address[] calldata addr,
        uint256[] calldata nums,
        bytes calldata bdata
    ) external;

}
