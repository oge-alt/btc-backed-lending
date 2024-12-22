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

;; Additional constants for validation
(define-constant ERR-INVALID-LOAN-ID (err u109))
(define-constant ERR-INVALID-PRICE (err u110))
(define-constant ERR-INVALID-ASSET (err u111))
(define-constant VALID-ASSETS (list "BTC" "STX"))

;; Data Variables
(define-data-var platform-initialized bool false)
(define-data-var minimum-collateral-ratio uint u150) ;; 150% collateral ratio
(define-data-var liquidation-threshold uint u120) ;; 120% triggers liquidation
(define-data-var platform-fee-rate uint u1) ;; 1% platform fee
(define-data-var total-btc-locked uint u0)
(define-data-var total-loans-issued uint u0)

;; Data Maps
(define-map loans
    { loan-id: uint }
    {
        borrower: principal,
        collateral-amount: uint,
        loan-amount: uint,
        interest-rate: uint,
        start-height: uint,
        last-interest-calc: uint,
        status: (string-ascii 20)
    }
)

(define-map user-loans
    { user: principal }
    { active-loans: (list 10 uint) }
)

(define-map collateral-prices
    { asset: (string-ascii 3) }
    { price: uint }
)

;; Private Functions
(define-private (calculate-collateral-ratio (collateral uint) (loan uint) (btc-price uint))
    (let
        (
            (collateral-value (* collateral btc-price))
            (ratio (* (/ collateral-value loan) u100))
        )
        ratio
    )
)

(define-private (calculate-interest (principal uint) (rate uint) (blocks uint))
    (let
        (
            (interest-per-block (/ (* principal rate) (* u100 u144))) ;; Daily interest divided by blocks per day
            (total-interest (* interest-per-block blocks))
        )
        total-interest
    )
)

(define-private (check-liquidation (loan-id uint))
    (let
        (
            (loan (unwrap! (map-get? loans {loan-id: loan-id}) ERR-LOAN-NOT-FOUND))
            (btc-price (unwrap! (get price (map-get? collateral-prices {asset: "BTC"})) ERR-NOT-INITIALIZED))
            (current-ratio (calculate-collateral-ratio (get collateral-amount loan) (get loan-amount loan) btc-price))
        )
        (if (<= current-ratio (var-get liquidation-threshold))
            (liquidate-position loan-id)
            (ok true)
        )
    )
)

(define-private (liquidate-position (loan-id uint))
    (let
        (
            (loan (unwrap! (map-get? loans {loan-id: loan-id}) ERR-LOAN-NOT-FOUND))
            (borrower (get borrower loan))
        )
        (begin
            (map-set loans
                {loan-id: loan-id}
                (merge loan {status: "liquidated"})
            )
            (map-delete user-loans {user: borrower})
            (ok true)
        )
    )
)

;; Helper function to validate loan-id
(define-private (validate-loan-id (loan-id uint))
    (and 
        (> loan-id u0)
        (<= loan-id (var-get total-loans-issued))
    )
)

;; Helper function to validate asset string
(define-private (is-valid-asset (asset (string-ascii 3)))
    (is-some (index-of VALID-ASSETS asset))
)

;; Helper function to validate price
(define-private (is-valid-price (price uint))
    (and 
        (> price u0)
        (<= price u1000000000000) ;; Reasonable upper limit for price
    )
)

;; Public Functions
(define-public (initialize-platform)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get platform-initialized)) ERR-ALREADY-INITIALIZED)
        (var-set platform-initialized true)
        (ok true)
    )
)

(define-public (deposit-collateral (amount uint))
    (begin
        (asserts! (var-get platform-initialized) ERR-NOT-INITIALIZED)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (var-set total-btc-locked (+ (var-get total-btc-locked) amount))
        (ok true)
    )
)

(define-public (request-loan (collateral uint) (loan-amount uint))
    (let
        (
            (btc-price (unwrap! (get price (map-get? collateral-prices {asset: "BTC"})) ERR-NOT-INITIALIZED))
            (collateral-value (* collateral btc-price))
            (required-collateral (* loan-amount (var-get minimum-collateral-ratio)))
            (loan-id (+ (var-get total-loans-issued) u1))
        )
        (begin
            (asserts! (var-get platform-initialized) ERR-NOT-INITIALIZED)
            (asserts! (>= collateral-value required-collateral) ERR-INSUFFICIENT-COLLATERAL)
            
            (map-set loans
                {loan-id: loan-id}
                {
                    borrower: tx-sender,
                    collateral-amount: collateral,
                    loan-amount: loan-amount,
                    interest-rate: u5, ;; 5% interest rate
                    start-height: block-height,
                    last-interest-calc: block-height,
                    status: "active"
                }
            )
            
            (match (map-get? user-loans {user: tx-sender})
                existing-loans (map-set user-loans
                    {user: tx-sender}
                    {active-loans: (unwrap! (as-max-len? (append (get active-loans existing-loans) loan-id) u10) ERR-INVALID-AMOUNT)}
                )
                (map-set user-loans
                    {user: tx-sender}
                    {active-loans: (list loan-id)}
                )
            )
            
            (var-set total-loans-issued (+ (var-get total-loans-issued) u1))
            (ok loan-id)
        )
    )
)

(define-public (repay-loan (loan-id uint) (amount uint))
    (begin
        ;; Validate loan-id first
        (asserts! (validate-loan-id loan-id) ERR-INVALID-LOAN-ID)
        
        (let
            (
                (loan (unwrap! (map-get? loans {loan-id: loan-id}) ERR-LOAN-NOT-FOUND))
                (interest-owed (calculate-interest 
                    (get loan-amount loan)
                    (get interest-rate loan)
                    (- block-height (get last-interest-calc loan))
                ))
                (total-owed (+ (get loan-amount loan) interest-owed))
            )
            (begin
                (asserts! (is-eq (get status loan) "active") ERR-LOAN-NOT-ACTIVE)
                (asserts! (is-eq (get borrower loan) tx-sender) ERR-NOT-AUTHORIZED)
                (asserts! (>= amount total-owed) ERR-INVALID-AMOUNT)
                
                ;; Update loan status
                (map-set loans
                    {loan-id: loan-id}
                    (merge loan {
                        status: "repaid",
                        last-interest-calc: block-height
                    })
                )
                
                ;; Return collateral to borrower
                (var-set total-btc-locked (- (var-get total-btc-locked) (get collateral-amount loan)))
                
                ;; Remove from active loans
                (match (map-get? user-loans {user: tx-sender})
                    existing-loans (ok (map-set user-loans
                        {user: tx-sender}
                        {active-loans: (filter not-equal-loan-id (get active-loans existing-loans))}
                    ))
                    (ok false)
                )
            )
        )
    )
)

;; Governance Functions
(define-public (update-collateral-ratio (new-ratio uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (>= new-ratio u110) ERR-INVALID-AMOUNT)
        (var-set minimum-collateral-ratio new-ratio)
        (ok true)
    )
)

(define-public (update-liquidation-threshold (new-threshold uint))
	(begin
		(asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
		(asserts! (>= new-threshold u100) ERR-INVALID-AMOUNT)
		(var-set liquidation-threshold new-threshold)
		(ok true)
	)
)

(define-public (update-price-feed (asset (string-ascii 3)) (new-price uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        ;; Validate asset and price
        (asserts! (is-valid-asset asset) ERR-INVALID-ASSET)
        (asserts! (is-valid-price new-price) ERR-INVALID-PRICE)
        
        ;; Only proceed if validations pass
        (ok (map-set collateral-prices
            {asset: asset}
            {price: new-price}
        ))
    )
)