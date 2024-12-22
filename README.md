# BTC-Backed Lending Smart Contract

A secure and decentralized platform for BTC-backed loans on the Stacks blockchain. This smart contract enables users to use their Bitcoin as collateral to obtain loans, with built-in safety mechanisms for liquidation and collateral management.

## Features

- **BTC Collateral Management**: Securely deposit BTC as loan collateral
- **Automated Loan Processing**: Request and receive loans based on collateral value
- **Dynamic Interest Calculation**: Real-time interest computation based on loan duration
- **Liquidation Protection**: Automated monitoring of collateral ratios with configurable thresholds
- **Governance Controls**: Contract owner can adjust key parameters like collateral ratios and price feeds
- **Transparent Operations**: Public functions to view loan details and platform statistics

## Technical Specifications

- **Minimum Collateral Ratio**: 150%
- **Liquidation Threshold**: 120%
- **Platform Fee**: 1%
- **Supported Assets**: BTC, STX

## Getting Started

### Prerequisites

- Stacks wallet
- BTC for collateral
- Basic understanding of blockchain operations

### Using the Contract

1. **Depositing Collateral**

```clarity
(contract-call? .btc-lending deposit-collateral amount)
```

2. **Requesting a Loan**

```clarity
(contract-call? .btc-lending request-loan collateral loan-amount)
```

3. **Repaying a Loan**

```clarity
(contract-call? .btc-lending repay-loan loan-id amount)
```

## Contract Functions

### Public Functions

- `initialize-platform`: Initialize the lending platform
- `deposit-collateral`: Deposit BTC as collateral
- `request-loan`: Request a loan against deposited collateral
- `repay-loan`: Repay an active loan
- `update-collateral-ratio`: Update the minimum collateral ratio (owner only)
- `update-liquidation-threshold`: Update the liquidation threshold (owner only)
- `update-price-feed`: Update asset price feeds (owner only)

### Read-Only Functions

- `get-loan-details`: Get details of a specific loan
- `get-user-loans`: Get all loans associated with a user
- `get-platform-stats`: Get platform statistics
- `get-valid-assets`: Get list of supported assets

## Security Features

- Comprehensive error handling
- Input validation
- Access control mechanisms
- Secure collateral management
- Automated liquidation protection

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Security

For security concerns, please review our [SECURITY.md](SECURITY.md) file.

## License

This project is licensed under the MIT License - see [LICENSE.md](LICENSE.md) for details.

## Contact

For questions and support, please open an issue in the repository.
