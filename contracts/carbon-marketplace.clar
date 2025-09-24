;; Decentralized Carbon Credit Marketplace
;; A comprehensive platform for carbon credit issuance, verification, trading, and retirement

;; =============================================================================
;; CONSTANTS & ERROR CODES
;; =============================================================================

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_INPUT (err u1002))
(define-constant ERR_CREDIT_NOT_FOUND (err u1003))
(define-constant ERR_INSUFFICIENT_CREDITS (err u1004))
(define-constant ERR_ALREADY_VERIFIED (err u1005))
(define-constant ERR_NOT_VERIFIED (err u1006))
(define-constant ERR_ORDER_NOT_FOUND (err u1007))
(define-constant ERR_INSUFFICIENT_FUNDS (err u1008))
(define-constant ERR_CREDIT_RETIRED (err u1009))
(define-constant ERR_INVALID_PRICE (err u1010))
(define-constant ERR_PROJECT_NOT_FOUND (err u1011))
(define-constant ERR_INVALID_VERIFIER (err u1012))
(define-constant ERR_VERIFICATION_PENDING (err u1013))
(define-constant ERR_ORACLE_NOT_AUTHORIZED (err u1014))
(define-constant ERR_INVALID_METHODOLOGY (err u1015))

;; Credit Quality Scores
(define-constant QUALITY_SCORE_PREMIUM u100)
(define-constant QUALITY_SCORE_HIGH u80)
(define-constant QUALITY_SCORE_STANDARD u60)
(define-constant QUALITY_SCORE_BASIC u40)

;; Trading Fee (0.25%)
(define-constant TRADING_FEE_PERCENT u25)
(define-constant FEE_DENOMINATOR u10000)

;; Verification Requirements
(define-constant MIN_VERIFIERS u3)
(define-constant VERIFICATION_THRESHOLD u67) ;; 67% consensus

;; =============================================================================
;; DATA VARIABLES
;; =============================================================================

(define-data-var next-credit-id uint u1)
(define-data-var next-project-id uint u1)
(define-data-var next-order-id uint u1)
(define-data-var next-verification-id uint u1)
(define-data-var platform-fee-vault uint u0)
(define-data-var total-credits-issued uint u0)
(define-data-var total-credits-retired uint u0)
(define-data-var total-co2-offset uint u0)

;; =============================================================================
;; DATA MAPS
;; =============================================================================

;; Carbon Projects Registry
(define-map projects uint {
    developer: principal,
    name: (string-ascii 100),
    description: (string-ascii 500),
    methodology: (string-ascii 50),
    location: (string-ascii 100),
    project-type: (string-ascii 30),
    baseline-emissions: uint,
    project-start-date: uint,
    crediting-period: uint,
    status: (string-ascii 20),
    total-credits-issued: uint,
    quality-score: uint,
    co-benefits: (string-ascii 200),
    created-at: uint
})

;; Carbon Credits Registry
(define-map carbon-credits uint {
    project-id: uint,
    owner: principal,
    credit-amount: uint, ;; in tonnes CO2e * 1000 (for decimals)
    vintage-year: uint,
    methodology: (string-ascii 50),
    verification-standard: (string-ascii 30),
    quality-score: uint,
    issuance-date: uint,
    retirement-date: (optional uint),
    retired-by: (optional principal),
    retirement-reason: (optional (string-ascii 200)),
    fractional-available: uint,
    trading-enabled: bool,
    price-per-tonne: uint, ;; in micro-STX
    metadata-hash: (string-ascii 64),
    co-benefits: (string-ascii 200)
})

;; Verification System
(define-map verifications uint {
    credit-id: uint,
    verifier: principal,
    verification-type: (string-ascii 30),
    status: (string-ascii 20),
    quality-assessment: uint,
    verification-report: (string-ascii 500),
    verification-date: uint,
    oracle-data-hash: (optional (string-ascii 64)),
    satellite-data-verified: bool,
    field-verification: bool
})

;; Authorized Verifiers
(define-map authorized-verifiers principal {
    name: (string-ascii 100),
    certification: (string-ascii 50),
    reputation-score: uint,
    total-verifications: uint,
    successful-verifications: uint,
    stake-amount: uint,
    authorized-date: uint,
    active: bool
})

;; Trading Orders
(define-map trading-orders uint {
    order-type: (string-ascii 10), ;; "buy" or "sell"
    credit-id: (optional uint),
    trader: principal,
    quantity: uint, ;; in tonnes * 1000
    price-per-tonne: uint,
    order-status: (string-ascii 20),
    created-at: uint,
    expires-at: (optional uint),
    filled-quantity: uint,
    quality-requirements: uint,
    vintage-requirements: (optional uint),
    methodology-filter: (optional (string-ascii 50))
})

;; Order Book
(define-map order-book {
    price-level: uint,
    order-type: (string-ascii 10)
} {
    total-quantity: uint,
    order-count: uint
})

;; Oracle Data Feeds
(define-map oracle-data (string-ascii 50) {
    data-provider: principal,
    data-value: uint,
    timestamp: uint,
    confidence-level: uint,
    verification-hash: (string-ascii 64)
})

;; Authorized Oracles
(define-map authorized-oracles principal {
    name: (string-ascii 50),
    data-types: (string-ascii 200),
    reputation: uint,
    active: bool
})

;; User Portfolios
(define-map user-portfolios principal {
    total-credits-owned: uint,
    total-credits-retired: uint,
    total-co2-offset: uint,
    trading-volume: uint,
    average-quality-score: uint,
    preferred-methodologies: (string-ascii 200),
    impact-certificates: uint
})

;; Retirement Certificates
(define-map retirement-certificates uint {
    credit-id: uint,
    retired-by: principal,
    retirement-amount: uint,
    retirement-purpose: (string-ascii 200),
    retirement-date: uint,
    certificate-hash: (string-ascii 64),
    beneficiary: (optional principal),
    impact-claim: (string-ascii 300)
})

;; Impact Tracking
(define-map project-impact uint {
    project-id: uint,
    total-co2-sequestered: uint,
    biodiversity-impact: uint,
    water-impact: uint,
    social-impact: uint,
    monitoring-data-hash: (string-ascii 64),
    last-updated: uint,
    verification-status: (string-ascii 20)
})

;; Governance Proposals
(define-map governance-proposals uint {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposal-type: (string-ascii 30),
    voting-start: uint,
    voting-end: uint,
    votes-for: uint,
    votes-against: uint,
    status: (string-ascii 20),
    execution-data: (optional (string-ascii 200))
})

;; Staking System
(define-map staker-info principal {
    staked-amount: uint,
    stake-start: uint,
    reward-debt: uint,
    voting-power: uint
})

;; =============================================================================
;; PROJECT MANAGEMENT FUNCTIONS
;; =============================================================================

;; Register new carbon project
(define-public (register-project 
    (name (string-ascii 100))
    (description (string-ascii 500))
    (methodology (string-ascii 50))
    (location (string-ascii 100))
    (project-type (string-ascii 30))
    (baseline-emissions uint)
    (crediting-period uint)
    (co-benefits (string-ascii 200)))
    (let ((project-id (var-get next-project-id)))
        (asserts! (> (len name) u0) ERR_INVALID_INPUT)
        (asserts! (> baseline-emissions u0) ERR_INVALID_INPUT)
        (asserts! (> crediting-period u0) ERR_INVALID_INPUT)
        
        (map-set projects project-id {
            developer: tx-sender,
            name: name,
            description: description,
            methodology: methodology,
            location: location,
            project-type: project-type,
            baseline-emissions: baseline-emissions,
            project-start-date: stacks-block-height,
            crediting-period: crediting-period,
            status: "registered",
            total-credits-issued: u0,
            quality-score: QUALITY_SCORE_BASIC,
            co-benefits: co-benefits,
            created-at: stacks-block-height
        })
        
        (var-set next-project-id (+ project-id u1))
        (ok project-id)))

;; Update project status
(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
    (let ((project (unwrap! (map-get? projects project-id) ERR_PROJECT_NOT_FOUND)))
        (asserts! (is-eq (get developer project) tx-sender) ERR_NOT_AUTHORIZED)
        
        (map-set projects project-id 
            (merge project { status: new-status }))
        (ok true)))

;; =============================================================================
;; CARBON CREDIT ISSUANCE FUNCTIONS
;; =============================================================================

;; Issue carbon credits for verified projects
(define-public (issue-carbon-credits
    (project-id uint)
    (credit-amount uint)
    (vintage-year uint)
    (verification-standard (string-ascii 30))
    (metadata-hash (string-ascii 64)))
    (let ((credit-id (var-get next-credit-id))
          (project (unwrap! (map-get? projects project-id) ERR_PROJECT_NOT_FOUND)))
        
        (asserts! (is-eq (get developer project) tx-sender) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get status project) "verified") ERR_NOT_VERIFIED)
        (asserts! (> credit-amount u0) ERR_INVALID_INPUT)
        (asserts! (>= vintage-year u2020) ERR_INVALID_INPUT)
        
        (map-set carbon-credits credit-id {
            project-id: project-id,
            owner: tx-sender,
            credit-amount: credit-amount,
            vintage-year: vintage-year,
            methodology: (get methodology project),
            verification-standard: verification-standard,
            quality-score: (get quality-score project),
            issuance-date: stacks-block-height,
            retirement-date: none,
            retired-by: none,
            retirement-reason: none,
            fractional-available: credit-amount,
            trading-enabled: true,
            price-per-tonne: u0,
            metadata-hash: metadata-hash,
            co-benefits: (get co-benefits project)
        })
        
        ;; Update project statistics
        (map-set projects project-id
            (merge project { 
                total-credits-issued: (+ (get total-credits-issued project) credit-amount)
            }))
        
        ;; Update global statistics
        (var-set next-credit-id (+ credit-id u1))
        (var-set total-credits-issued (+ (var-get total-credits-issued) credit-amount))
        
        ;; Update user portfolio
        (unwrap-panic (update-user-portfolio tx-sender credit-amount u0))
        
        (ok credit-id)))

;; =============================================================================
;; VERIFICATION SYSTEM FUNCTIONS
;; =============================================================================

;; Authorize verifier
(define-public (authorize-verifier 
    (verifier principal)
    (name (string-ascii 100))
    (certification (string-ascii 50))
    (stake-amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (> stake-amount u1000000) ERR_INVALID_INPUT) ;; Minimum 1 STX stake
        
        (try! (stx-transfer? stake-amount verifier (as-contract tx-sender)))
        
        (map-set authorized-verifiers verifier {
            name: name,
            certification: certification,
            reputation-score: u100,
            total-verifications: u0,
            successful-verifications: u0,
            stake-amount: stake-amount,
            authorized-date: stacks-block-height,
            active: true
        })
        
        (ok true)))

;; Submit verification
(define-public (submit-verification
    (project-id uint)
    (verification-type (string-ascii 30))
    (quality-assessment uint)
    (verification-report (string-ascii 500))
    (satellite-data-verified bool)
    (field-verification bool))
    (let ((verification-id (var-get next-verification-id))
          (verifier-info (unwrap! (map-get? authorized-verifiers tx-sender) ERR_INVALID_VERIFIER)))
        
        (asserts! (get active verifier-info) ERR_INVALID_VERIFIER)
        (asserts! (<= quality-assessment QUALITY_SCORE_PREMIUM) ERR_INVALID_INPUT)
        
        (map-set verifications verification-id {
            credit-id: project-id,
            verifier: tx-sender,
            verification-type: verification-type,
            status: "submitted",
            quality-assessment: quality-assessment,
            verification-report: verification-report,
            verification-date: stacks-block-height,
            oracle-data-hash: none,
            satellite-data-verified: satellite-data-verified,
            field-verification: field-verification
        })
        
        (var-set next-verification-id (+ verification-id u1))
        (ok verification-id)))

;; Process verification consensus
(define-public (process-verification-consensus (project-id uint))
    (let ((project (unwrap! (map-get? projects project-id) ERR_PROJECT_NOT_FOUND)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        
        ;; Check if enough verifications exist and calculate consensus
        (let ((consensus-result (calculate-verification-consensus project-id)))
            (if (>= consensus-result VERIFICATION_THRESHOLD)
                (begin
                    (map-set projects project-id
                        (merge project { 
                            status: "verified",
                            quality-score: (calculate-project-quality-score project-id)
                        }))
                    (ok true))
                (ok false)))))

;; =============================================================================
;; TRADING SYSTEM FUNCTIONS
;; =============================================================================

;; Create sell order
(define-public (create-sell-order
    (credit-id uint)
    (quantity uint)
    (price-per-tonne uint)
    (expires-at (optional uint)))
    (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND))
          (order-id (var-get next-order-id)))
        
        (asserts! (is-eq (get owner credit) tx-sender) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (get retirement-date credit)) ERR_CREDIT_RETIRED)
        (asserts! (get trading-enabled credit) ERR_NOT_AUTHORIZED)
        (asserts! (>= (get fractional-available credit) quantity) ERR_INSUFFICIENT_CREDITS)
        (asserts! (> price-per-tonne u0) ERR_INVALID_PRICE)
        
        (map-set trading-orders order-id {
            order-type: "sell",
            credit-id: (some credit-id),
            trader: tx-sender,
            quantity: quantity,
            price-per-tonne: price-per-tonne,
            order-status: "active",
            created-at: stacks-block-height,
            expires-at: expires-at,
            filled-quantity: u0,
            quality-requirements: u0,
            vintage-requirements: none,
            methodology-filter: none
        })
        
        ;; Lock credits for sale
        (map-set carbon-credits credit-id
            (merge credit { 
                fractional-available: (- (get fractional-available credit) quantity)
            }))
        
        (var-set next-order-id (+ order-id u1))
        (unwrap-panic (update-order-book price-per-tonne "sell" quantity))
        (ok order-id)))

;; Create buy order
(define-public (create-buy-order
    (quantity uint)
    (price-per-tonne uint)
    (quality-requirements uint)
    (vintage-requirements (optional uint))
    (methodology-filter (optional (string-ascii 50)))
    (expires-at (optional uint)))
    (let ((order-id (var-get next-order-id))
          (total-cost (* quantity price-per-tonne)))
        
        (asserts! (> quantity u0) ERR_INVALID_INPUT)
        (asserts! (> price-per-tonne u0) ERR_INVALID_PRICE)
        
        ;; Escrow payment
        (try! (stx-transfer? total-cost tx-sender (as-contract tx-sender)))
        
        (map-set trading-orders order-id {
            order-type: "buy",
            credit-id: none,
            trader: tx-sender,
            quantity: quantity,
            price-per-tonne: price-per-tonne,
            order-status: "active",
            created-at: stacks-block-height,
            expires-at: expires-at,
            filled-quantity: u0,
            quality-requirements: quality-requirements,
            vintage-requirements: vintage-requirements,
            methodology-filter: methodology-filter
        })
        
        (var-set next-order-id (+ order-id u1))
        (unwrap-panic (update-order-book price-per-tonne "buy" quantity))
        (ok order-id)))

;; Execute trade
(define-public (execute-trade (buy-order-id uint) (sell-order-id uint) (trade-quantity uint))
    (let ((buy-order (unwrap! (map-get? trading-orders buy-order-id) ERR_ORDER_NOT_FOUND))
          (sell-order (unwrap! (map-get? trading-orders sell-order-id) ERR_ORDER_NOT_FOUND))
          (credit (unwrap! (map-get? carbon-credits (unwrap! (get credit-id sell-order) ERR_CREDIT_NOT_FOUND)) ERR_CREDIT_NOT_FOUND)))
        
        (asserts! (is-eq (get order-type buy-order) "buy") ERR_INVALID_INPUT)
        (asserts! (is-eq (get order-type sell-order) "sell") ERR_INVALID_INPUT)
        (asserts! (is-eq (get order-status buy-order) "active") ERR_INVALID_INPUT)
        (asserts! (is-eq (get order-status sell-order) "active") ERR_INVALID_INPUT)
        (asserts! (<= trade-quantity (- (get quantity buy-order) (get filled-quantity buy-order))) ERR_INSUFFICIENT_CREDITS)
        (asserts! (<= trade-quantity (- (get quantity sell-order) (get filled-quantity sell-order))) ERR_INSUFFICIENT_CREDITS)
        
        ;; Verify credit meets buy order requirements
        (asserts! (>= (get quality-score credit) (get quality-requirements buy-order)) ERR_INVALID_INPUT)
        
        (let ((trade-price (get price-per-tonne sell-order))
              (total-amount (* trade-quantity trade-price))
              (trading-fee (/ (* total-amount TRADING_FEE_PERCENT) FEE_DENOMINATOR))
              (seller-amount (- total-amount trading-fee)))
            
            ;; Transfer payment to seller
            (try! (as-contract (stx-transfer? seller-amount tx-sender (get trader sell-order))))
            
            ;; Collect trading fee
            (var-set platform-fee-vault (+ (var-get platform-fee-vault) trading-fee))
            
            ;; Transfer credit ownership
            (unwrap-panic (transfer-credit-fractional 
                (unwrap! (get credit-id sell-order) ERR_CREDIT_NOT_FOUND)
                (get trader sell-order)
                (get trader buy-order)
                trade-quantity))
            
            ;; Update order statuses
            (unwrap-panic (update-order-fill buy-order-id trade-quantity))
            (unwrap-panic (update-order-fill sell-order-id trade-quantity))
            
            ;; Update user portfolios
            (unwrap-panic (update-user-portfolio (get trader buy-order) trade-quantity u0))
            (unwrap-panic (update-user-portfolio (get trader sell-order) u0 u0))
            
            (ok true))))

;; =============================================================================
;; CREDIT RETIREMENT FUNCTIONS
;; =============================================================================

;; Retire carbon credits
(define-public (retire-carbon-credits
    (credit-id uint)
    (retirement-amount uint)
    (retirement-reason (string-ascii 200))
    (beneficiary (optional principal)))
    (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND)))
        
        (asserts! (is-eq (get owner credit) tx-sender) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (get retirement-date credit)) ERR_CREDIT_RETIRED)
        (asserts! (<= retirement-amount (get credit-amount credit)) ERR_INSUFFICIENT_CREDITS)
        
        ;; Update credit with retirement information
        (map-set carbon-credits credit-id
            (merge credit {
                retirement-date: (some stacks-block-height),
                retired-by: (some tx-sender),
                retirement-reason: (some retirement-reason),
                credit-amount: (- (get credit-amount credit) retirement-amount)
            }))
        
        ;; Create retirement certificate
        (unwrap-panic (create-retirement-certificate credit-id tx-sender retirement-amount retirement-reason beneficiary))
        
        ;; Update global statistics
        (var-set total-credits-retired (+ (var-get total-credits-retired) retirement-amount))
        (var-set total-co2-offset (+ (var-get total-co2-offset) retirement-amount))
        
        ;; Update user portfolio
        (unwrap-panic (update-user-portfolio tx-sender u0 retirement-amount))
        
        (ok true)))

;; =============================================================================
;; ORACLE SYSTEM FUNCTIONS
;; =============================================================================

;; Authorize oracle
(define-public (authorize-oracle 
    (oracle principal)
    (name (string-ascii 50))
    (data-types (string-ascii 200)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        
        (map-set authorized-oracles oracle {
            name: name,
            data-types: data-types,
            reputation: u100,
            active: true
        })
        
        (ok true)))

;; Submit oracle data
(define-public (submit-oracle-data
    (data-key (string-ascii 50))
    (data-value uint)
    (confidence-level uint)
    (verification-hash (string-ascii 64)))
    (let ((oracle-info (unwrap! (map-get? authorized-oracles tx-sender) ERR_ORACLE_NOT_AUTHORIZED)))
        
        (asserts! (get active oracle-info) ERR_ORACLE_NOT_AUTHORIZED)
        (asserts! (<= confidence-level u100) ERR_INVALID_INPUT)
        
        (map-set oracle-data data-key {
            data-provider: tx-sender,
            data-value: data-value,
            timestamp: stacks-block-height,
            confidence-level: confidence-level,
            verification-hash: verification-hash
        })
        
        (ok true)))

;; =============================================================================
;; GOVERNANCE FUNCTIONS
;; =============================================================================

;; Create governance proposal
(define-public (create-proposal
    (title (string-ascii 100))
    (description (string-ascii 500))
    (proposal-type (string-ascii 30))
    (voting-duration uint))
    (let ((proposal-id (var-get next-verification-id)))
        
        (asserts! (> voting-duration u0) ERR_INVALID_INPUT)
        
        (map-set governance-proposals proposal-id {
            proposer: tx-sender,
            title: title,
            description: description,
            proposal-type: proposal-type,
            voting-start: stacks-block-height,
            voting-end: (+ stacks-block-height voting-duration),
            votes-for: u0,
            votes-against: u0,
            status: "active",
            execution-data: none
        })
        
        (var-set next-verification-id (+ proposal-id u1))
        (ok proposal-id)))

;; =============================================================================
;; HELPER FUNCTIONS
;; =============================================================================

;; Calculate verification consensus
(define-private (calculate-verification-consensus (project-id uint))
    ;; Simplified consensus calculation - in production, this would aggregate all verifications
    u75) ;; Mock return value

;; Calculate project quality score
(define-private (calculate-project-quality-score (project-id uint))
    ;; Simplified quality score calculation
    QUALITY_SCORE_STANDARD)

;; Transfer fractional credit ownership
(define-private (transfer-credit-fractional 
    (credit-id uint)
    (from principal)
    (to principal)
    (amount uint))
    ;; Simplified transfer - in production, this would handle fractional ownership properly
    (ok true))

;; Update order book
(define-private (update-order-book (price uint) (order-type (string-ascii 10)) (quantity uint))
    (let ((current-book (default-to { total-quantity: u0, order-count: u0 }
                                   (map-get? order-book { price-level: price, order-type: order-type }))))
        (map-set order-book 
            { price-level: price, order-type: order-type }
            { 
                total-quantity: (+ (get total-quantity current-book) quantity),
                order-count: (+ (get order-count current-book) u1)
            })
        (ok true)))

;; Update order fill
(define-private (update-order-fill (order-id uint) (filled-amount uint))
    (let ((order (unwrap-panic (map-get? trading-orders order-id))))
        (let ((new-filled (+ (get filled-quantity order) filled-amount)))
            (map-set trading-orders order-id
                (merge order {
                    filled-quantity: new-filled,
                    order-status: (if (>= new-filled (get quantity order)) "filled" "partial")
                }))
            (ok true))))

;; Update user portfolio
(define-private (update-user-portfolio (user principal) (credits-change uint) (retired-change uint))
    (let ((portfolio (default-to 
                         { total-credits-owned: u0, total-credits-retired: u0, total-co2-offset: u0,
                           trading-volume: u0, average-quality-score: u0, preferred-methodologies: "",
                           impact-certificates: u0 }
                         (map-get? user-portfolios user))))
        (map-set user-portfolios user
            (merge portfolio {
                total-credits-owned: (+ (get total-credits-owned portfolio) credits-change),
                total-credits-retired: (+ (get total-credits-retired portfolio) retired-change),
                total-co2-offset: (+ (get total-co2-offset portfolio) retired-change)
            }))
        (ok true)))

;; Create retirement certificate
(define-private (create-retirement-certificate
    (credit-id uint)
    (retired-by principal)
    (retirement-amount uint)
    (retirement-reason (string-ascii 200))
    (beneficiary (optional principal)))
    (let ((cert-id (var-get next-verification-id)))
        (map-set retirement-certificates cert-id {
            credit-id: credit-id,
            retired-by: retired-by,
            retirement-amount: retirement-amount,
            retirement-purpose: retirement-reason,
            retirement-date: stacks-block-height,
            certificate-hash: "", ;; Would be computed hash in production
            beneficiary: beneficiary,
            impact-claim: retirement-reason
        })
        (var-set next-verification-id (+ cert-id u1))
        (ok cert-id)))

;; =============================================================================
;; READ-ONLY FUNCTIONS
;; =============================================================================

;; Get project details
(define-read-only (get-project (project-id uint))
    (map-get? projects project-id))

;; Get carbon credit details
(define-read-only (get-carbon-credit (credit-id uint))
    (map-get? carbon-credits credit-id))

;; Get trading order
(define-read-only (get-trading-order (order-id uint))
    (map-get? trading-orders order-id))

;; Get user portfolio
(define-read-only (get-user-portfolio (user principal))
    (map-get? user-portfolios user))

;; Get platform statistics
(define-read-only (get-platform-stats)
    {
        total-credits-issued: (var-get total-credits-issued),
        total-credits-retired: (var-get total-credits-retired),
        total-co2-offset: (var-get total-co2-offset),
        platform-fees: (var-get platform-fee-vault)
    })

;; Get order book for price level
(define-read-only (get-order-book (price uint) (order-type (string-ascii 10)))
    (map-get? order-book { price-level: price, order-type: order-type }))

;; Get oracle data
(define-read-only (get-oracle-data (data-key (string-ascii 50)))
    (map-get? oracle-data data-key))

;; Get verification details
(define-read-only (get-verification (verification-id uint))
    (map-get? verifications verification-id))

;; Get retirement certificate
(define-read-only (get-retirement-certificate (cert-id uint))
    (map-get? retirement-certificates cert-id))

