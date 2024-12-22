;; BTC-Backed Lending Smart Contract
;; Summary
;; This smart contract facilitates BTC-backed lending on the Stacks blockchain. Users can deposit BTC as collateral, request loans, and repay loans. The contract ensures that loans are adequately collateralized and handles liquidation if collateral value falls below a threshold.

;; Description
;; The BTC-Backed Lending smart contract provides a decentralized platform for BTC-backed loans. Key features include:
;; - **Collateral Management**: Users can deposit BTC as collateral and request loans based on the collateral value.
;; - **Loan Issuance**: Loans are issued with a specified interest rate and require a minimum collateral ratio.
;; - **Repayment and Liquidation**: Users can repay loans, and the contract handles liquidation if the collateral value falls below the liquidation threshold.
;; - **Governance**: The contract owner can update collateral ratios, liquidation thresholds, and price feeds.
;; - **Validation**: The contract includes various validation checks to ensure the integrity of operations, such as validating loan IDs, asset strings, and prices.
;; - **Read-Only Functions**: Users can query loan details, user loans, platform statistics, and valid assets.

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-BELOW-MINIMUM (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-INITIALIZED (err u105))
(define-constant ERR-INVALID-LIQUIDATION (err u106))
(define-constant ERR-LOAN-NOT-FOUND (err u107))
(define-constant ERR-LOAN-NOT-ACTIVE (err u108))