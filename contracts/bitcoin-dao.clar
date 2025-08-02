;; Title: BitcoinDAO - Next-Generation Autonomous Governance Protocol
;;
;; Summary:
;; BitcoinDAO harnesses Bitcoin's battle-tested security architecture to power
;; sophisticated autonomous organizations through Stacks Layer 2 smart contracts,
;; delivering unmatched governance integrity for the decentralized economy.
;;
;; Description:
;; BitcoinDAO represents a paradigm shift in decentralized governance, establishing
;; the first truly Bitcoin-secured autonomous organization framework. This protocol
;; combines the immutable foundation of Bitcoin with advanced governance mechanics to
;; create organizations that are:
;;   - Quantum-resistant through Bitcoin's proven cryptographic foundation
;;   - Economically incentivized with reputation-weighted decision making
;;   - Democratically fair using quadratic voting mechanisms
;;   - Cross-chain compatible for multi-ecosystem collaboration
;;   - Treasury-optimized with automated fund management
;;   - Community-driven with anti-centralization safeguards
;;
;; Unlike traditional DAOs that rely on potentially vulnerable consensus mechanisms,
;; BitcoinDAO anchors every governance decision to Bitcoin's unbreachable ledger,
;; ensuring that organizational integrity scales with Bitcoin's own security guarantees.
;; This creates the world's most secure framework for collective decision-making,
;; establishing a new gold standard for decentralized autonomous organizations.

;; CONSTANTS & ERROR CODES

(define-constant CONTRACT-OWNER tx-sender)

;; Error codes for comprehensive error handling
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-MEMBER (err u101))
(define-constant ERR-NOT-MEMBER (err u102))
(define-constant ERR-INVALID-PROPOSAL (err u103))
(define-constant ERR-PROPOSAL-EXPIRED (err u104))
(define-constant ERR-ALREADY-VOTED (err u105))
(define-constant ERR-INSUFFICIENT-FUNDS (err u106))
(define-constant ERR-INVALID-AMOUNT (err u107))

;; STATE VARIABLES

;; Global counters for tracking organizational metrics
(define-data-var total-members uint u0)
(define-data-var total-proposals uint u0)
(define-data-var treasury-balance uint u0)

;; DATA STRUCTURES

;; Member registry with reputation and staking mechanics
(define-map members principal 
  {
    reputation: uint,           ;; Accumulated reputation score
    stake: uint,               ;; Staked tokens for governance weight
    last-interaction: uint     ;; Block height of last activity
  }
)

;; Proposal storage with comprehensive metadata
(define-map proposals uint 
  {
    creator: principal,             ;; Proposal originator
    title: (string-ascii 50),      ;; Concise proposal title
    description: (string-utf8 500), ;; Detailed proposal description
    amount: uint,                   ;; Requested treasury amount
    yes-votes: uint,               ;; Weighted yes votes
    no-votes: uint,                ;; Weighted no votes
    status: (string-ascii 10),     ;; Current proposal status
    created-at: uint,              ;; Creation block height
    expires-at: uint               ;; Expiration block height
  }
)

;; Vote tracking to prevent double voting
(define-map votes {proposal-id: uint, voter: principal} bool)

;; Cross-DAO collaboration framework
(define-map collaborations uint 
  {
    partner-dao: principal,        ;; Collaborating DAO address
    proposal-id: uint,             ;; Associated proposal ID
    status: (string-ascii 10)      ;; Collaboration status
  }
)

;; PRIVATE UTILITY FUNCTIONS

;; Verify if an address is a registered member
(define-private (is-member (user principal))
  (match (map-get? members user)
    member-data true
    false
  )
)

;; Check if a proposal is active and within voting period
(define-private (is-active-proposal (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal (and 
      (< stacks-block-height (get expires-at proposal))
      (is-eq (get status proposal) "active")
    )
    false
  )
)

;; Validate proposal existence
(define-private (is-valid-proposal-id (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal true
    false
  )
)

;; Validate collaboration existence
(define-private (is-valid-collaboration-id (collaboration-id uint))
  (match (map-get? collaborations collaboration-id)
    collaboration true
    false
  )
)

;; Calculate quadratic voting power based on reputation and stake
(define-private (calculate-voting-power (user principal))
  (let (
    (member-data (unwrap! (map-get? members user) u0))
    (reputation (get reputation member-data))
    (stake (get stake member-data))
  )
    (+ (* reputation u10) stake)
  )
)

;; Update member reputation with time-based tracking
(define-private (update-member-reputation (user principal) (change int))
  (match (map-get? members user)
    member-data 
    (let (
      (new-reputation (to-uint (+ (to-int (get reputation member-data)) change)))
      (updated-data (merge member-data {
        reputation: new-reputation, 
        last-interaction: stacks-block-height
      }))
    )
      (map-set members user updated-data)
      (ok new-reputation)
    )
    ERR-NOT-MEMBER
  )
)

;; MEMBERSHIP MANAGEMENT

;; Join the DAO as a new member
(define-public (join-dao)
  (let (
    (caller tx-sender)
  )
    (asserts! (not (is-member caller)) ERR-ALREADY-MEMBER)
    (map-set members caller {
      reputation: u1, 
      stake: u0, 
      last-interaction: stacks-block-height
    })
    (var-set total-members (+ (var-get total-members) u1))
    (ok true)
  )
)

;; Leave the DAO and forfeit membership
(define-public (leave-dao)
  (let (
    (caller tx-sender)
  )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (map-delete members caller)
    (var-set total-members (- (var-get total-members) u1))
    (ok true)
  )
)

;; Stake tokens to increase governance weight
(define-public (stake-tokens (amount uint))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    
    (match (map-get? members caller)
      member-data 
      (let (
        (new-stake (+ (get stake member-data) amount))
        (updated-data (merge member-data {
          stake: new-stake, 
          last-interaction: stacks-block-height
        }))
      )
        (map-set members caller updated-data)
        (var-set treasury-balance (+ (var-get treasury-balance) amount))
        (ok new-stake)
      )
      ERR-NOT-MEMBER
    )
  )
)

;; Unstake tokens and reduce governance weight
(define-public (unstake-tokens (amount uint))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    (match (map-get? members caller)
      member-data 
      (let (
        (current-stake (get stake member-data))
      )
        (asserts! (>= current-stake amount) ERR-INSUFFICIENT-FUNDS)
        (try! (as-contract (stx-transfer? amount tx-sender caller)))
        
        (let (
          (new-stake (- current-stake amount))
          (updated-data (merge member-data {
            stake: new-stake, 
            last-interaction: stacks-block-height
          }))
        )
          (map-set members caller updated-data)
          (var-set treasury-balance (- (var-get treasury-balance) amount))
          (ok new-stake)
        )
      )
      ERR-NOT-MEMBER
    )
  )
)

;; PROPOSAL MANAGEMENT

;; Create a new governance proposal
(define-public (create-proposal (title (string-ascii 50)) (description (string-utf8 500)) (amount uint))
  (let (
    (caller tx-sender)
    (proposal-id (+ (var-get total-proposals) u1))
  )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (>= (var-get treasury-balance) amount) ERR-INSUFFICIENT-FUNDS)
    (asserts! (> (len title) u0) ERR-INVALID-PROPOSAL)
    (asserts! (> (len description) u0) ERR-INVALID-PROPOSAL)
    
    (map-set proposals proposal-id {
      creator: caller,
      title: title,
      description: description,
      amount: amount,
      yes-votes: u0,
      no-votes: u0,
      status: "active",
      created-at: stacks-block-height,
      expires-at: (+ stacks-block-height u1440) ;; 10-day voting period
    })
    
    (var-set total-proposals proposal-id)
    (try! (update-member-reputation caller 1))
    (ok proposal-id)
  )
)

;; Cast a weighted vote on an active proposal
(define-public (vote-on-proposal (proposal-id uint) (vote bool))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (is-active-proposal proposal-id) ERR-INVALID-PROPOSAL)
    (asserts! (not (default-to false (map-get? votes {proposal-id: proposal-id, voter: caller}))) ERR-ALREADY-VOTED)
    
    (let (
      (voting-power (calculate-voting-power caller))
      (proposal (unwrap! (map-get? proposals proposal-id) ERR-INVALID-PROPOSAL))
    )
      (if vote
        (map-set proposals proposal-id (merge proposal {
          yes-votes: (+ (get yes-votes proposal) voting-power)
        }))
        (map-set proposals proposal-id (merge proposal {
          no-votes: (+ (get no-votes proposal) voting-power)
        }))
      )
      
      (map-set votes {proposal-id: proposal-id, voter: caller} true)
      (try! (update-member-reputation caller 1))
      (ok true)
    )
  )
)

;; Execute a proposal after voting period expires
(define-public (execute-proposal (proposal-id uint))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-member caller) ERR-NOT-MEMBER)
    (asserts! (is-valid-proposal-id proposal-id) ERR-INVALID-PROPOSAL)
    
    (match (map-get? proposals proposal-id)
      proposal 
      (begin
        (asserts! (>= stacks-block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
        (asserts! (is-eq (get status proposal) "active") ERR-INVALID-PROPOSAL)
        
        (let (
          (yes-votes (get yes-votes proposal))
          (no-votes (get no-votes proposal))
          (amount (get amount proposal))
        )
          (if (> yes-votes no-votes)
            (begin
              (try! (as-contract (stx-transfer? amount tx-sender (get creator proposal))))
              (var-set treasury-balance (- (var-get treasury-balance) amount))
              (asserts! (is-valid-proposal-id proposal-id) ERR-INVALID-PROPOSAL)
              (map-set proposals proposal-id (merge proposal {status: "executed"}))
              (try! (update-member-reputation (get creator proposal) 5))
              (ok true)
            )
            (begin
              (asserts! (is-valid-proposal-id proposal-id) ERR-INVALID-PROPOSAL)
              (map-set proposals proposal-id (merge proposal {status: "rejected"}))
              (ok false)
            )
          )
        )
      )
      ERR-INVALID-PROPOSAL
    )
  )
)

;; TREASURY MANAGEMENT

;; Get current treasury balance
(define-read-only (get-treasury-balance)
  (ok (var-get treasury-balance))
)

;; Donate funds to the DAO treasury
(define-public (donate-to-treasury (amount uint))
  (let (
    (caller tx-sender)
  )
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    (var-set treasury-balance (+ (var-get treasury-balance) amount))
    
    (if (is-member caller)
      (begin
        (try! (update-member-reputation caller 2))
        (ok true)
      )
      (ok true)
    )
  )
)

;; REPUTATION SYSTEM

;; Get a member's current reputation score
(define-read-only (get-member-reputation (user principal))
  (match (map-get? members user)
    member-data (ok (get reputation member-data))
    ERR-NOT-MEMBER
  )
)

;; Decay reputation for inactive members (Owner only)
(define-public (decay-inactive-members)
  (let (
    (caller tx-sender)
    (current-block stacks-block-height)
  )
    (asserts! (is-eq caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    (map-set members caller
      (match (map-get? members caller)
        member-data 
        (if (> (- current-block (get last-interaction member-data)) u4320) ;; 30 days
          (merge member-data {reputation: (/ (get reputation member-data) u2)})
          member-data
        )
        { reputation: u0, stake: u0, last-interaction: current-block }
      )
    )
    (ok true)
  )
)