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

}
