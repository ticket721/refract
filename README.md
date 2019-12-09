# refract

📡 🛰 Refract wallet system, implementation and interfaces for smart wallet and smart wallet factories

## Status

| Service | Status |
| :---: | :---: |
| Coveralls | [![Coverage Status](https://coveralls.io/repos/github/ticket721/refract/badge.svg?branch=develop)](https://coveralls.io/github/ticket721/refract?branch=develop) |

## Abstract

The Refract Wallet is a `smart wallet` interface built with both relayers and dapp users in mind. The `factory` is an important part of the wallet as it allows relayers to also deploy `smart wallets` on their end. The goal is to provide two interfaces that can be used by relayers to properly understand the `smart wallets` and how to deploy them too !

## Relayer Vision

Relayers are entities that hold `ether` and are able to spend it in order to relay `meta-transactions`. The income model may vary, from completely `open relays` to `restricted relays`, the RefractWallet handles both use cases.

- **Open Relays**: An `open relay` would be a relay with a public endpoint, requiring no authentication. This does not mean that they would be free relays, it means that their revenue model is included in the `RefractWallet`. By allowing rewards to be linked with `meta-transactions`, Open Relays can select and broadcast the transactions that are rewarding more funds, that are using a specific selection of currencies etc...

- **Restricted Relays**: A `restricted relay` that exposes private endpoints. The revenue model will most likely be off-chain. The meta-transactions do not need a `reward` field in this case, as cost would be paid in parallel, to gain access to the relay.

## Dapp Vision

- **Beginner**: Someone that do not want to dig too deep into the `smart wallets`, and do not require an advanced usage of the wallets. Will most likely use a `restricted relay`, and use the Factory provided by the relay.

- **Meta-Tx Only**: Someone that handles the deployment of its `smart wallets`, but needs help to relay `meta transactions`. As long as the interface for the `smart wallet` is respected, he can use both a `restricted relay` or and an `open relay`.

- **Full Customizer**: Someone that has specific implementation details required in its `smart wallet`, and also wants to delegate the creation of the wallets. In this case, the `factory` interface makes sense, making it possible for relays to create the `smart wallets` directly from its custom `factory`.

## Interfaces Features

### RefractFactory

- **create2 deployment**: ability to predict generated address by including salt and initial owner in the `create2` process. Lowers cost per user.

### RefractWallet

- **relay meta transactions**: accept signatures to relay `meta-transactions`. SIgnature can contain multiple authorizations, making **`multi-signature meta-transactions`** possible.
- **recover controllers**: utility to check if a given address is or isn't a controller of the `smart wallet`.
- **accept gas requirements**: `meta-transactions` can contain gas requirements for the relayer. The `smart wallet` should check the current `gasLimit` and `gasPrice` and revert if requirements are not met.
- **emit reward**: `meta-transactions` can contain a reward currency and amount.
- **eip712 signatures**: all `meta-transactions` should be `eip712` compliant.

## Versions

Each version is defined by its interfaces, implementations, and additional mocks used for testing.

### `v0`

- [x] create2 address prediction
- [x] create2 deployment from factory
- [x] meta transaction
- [x] meta transaction with reward
- [x] meta transaction with gas
- [x] meta transaction with reward + gas
- [x] EIP712 signatures
- [x] send meta transactions towards wallets
- [x] send meta transactions towards contracts
- [ ] proxy wallets
- [ ] proxy factory

| Interfaces | Implementation | Mocks |
| :---:      | :---:          | :---: |
| [`IRefractFactory_v0`](./contracts/interfaces/v0/IRefractFactory_v0.sol) |  [`RefractFactory_v0`](./contracts/implementations/v0/RefractFactory_v0.sol) | [`ERC20Mock_v0`](./contracts/mocks/v0/ERC20Mock_v0.sol)|
| [`IRefractWallet_v0`](./contracts/interfaces/v0/IRefractWallet_v0.sol) |  [`RefractWallet_v0`](./contracts/implementations/v0/RefractWallet_v0.sol) | |

