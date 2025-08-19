;; Insurance Management Contract
;; Manages insurance policies for registered vehicles

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-POLICY-NOT-FOUND (err u201))
(define-constant ERR-INVALID-INPUT (err u202))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u203))
(define-constant ERR-POLICY-EXPIRED (err u204))
(define-constant ERR-CLAIM-NOT-FOUND (err u205))

;; Data Variables
(define-data-var next-policy-id uint u1)
(define-data-var next-claim-id uint u1)
(define-data-var base-premium uint u500000) ;; 0.5 STX

;; Data Maps
(define-map insurance-policies
  { policy-id: uint }
  {
    vehicle-id: uint,
    owner: principal,
    coverage-type: (string-ascii 20),
    premium-amount: uint,
    start-date: uint,
    end-date: uint,
    status: (string-ascii 20),
    claims-count: uint
  }
)

(define-map policy-payments
  { policy-id: uint, payment-id: uint }
  {
    amount: uint,
    payment-date: uint,
    payment-type: (string-ascii 20)
  }
)

(define-map insurance-claims
  { claim-id: uint }
  {
    policy-id: uint,
    vehicle-id: uint,
    claimant: principal,
    claim-type: (string-ascii 30),
    claim-amount: uint,
    description: (string-ascii 500),
    claim-date: uint,
    status: (string-ascii 20),
    approved-amount: uint
  }
)

(define-map vehicle-policies
  { vehicle-id: uint }
  { active-policy-id: (optional uint) }
)

;; Private Functions
(define-private (is-valid-coverage-type (coverage-type (string-ascii 20)))
  (or
    (is-eq coverage-type "basic")
    (is-eq coverage-type "comprehensive")
    (is-eq coverage-type "premium")
  )
)

(define-private (calculate-premium (coverage-type (string-ascii 20)) (vehicle-type (string-ascii 20)))
  (let ((base (var-get base-premium)))
    (if (is-eq coverage-type "basic")
      base
      (if (is-eq coverage-type "comprehensive")
        (* base u2)
        (* base u3)
      )
    )
  )
)

(define-private (is-policy-active (end-date uint))
  (> end-date block-height)
)

;; Public Functions
(define-public (create-policy
  (vehicle-id uint)
  (coverage-type (string-ascii 20))
  (vehicle-type (string-ascii 20))
)
  (let (
    (policy-id (var-get next-policy-id))
    (premium (calculate-premium coverage-type vehicle-type))
    (start-date block-height)
    (end-date (+ block-height u52560)) ;; 1 year
  )
    (asserts! (is-valid-coverage-type coverage-type) ERR-INVALID-INPUT)

    ;; Create policy
    (map-set insurance-policies
      { policy-id: policy-id }
      {
        vehicle-id: vehicle-id,
        owner: tx-sender,
        coverage-type: coverage-type,
        premium-amount: premium,
        start-date: start-date,
        end-date: end-date,
        status: "active",
        claims-count: u0
      }
    )

    ;; Link vehicle to policy
    (map-set vehicle-policies
      { vehicle-id: vehicle-id }
      { active-policy-id: (some policy-id) }
    )

    ;; Increment policy ID
    (var-set next-policy-id (+ policy-id u1))

    (ok policy-id)
  )
)

(define-public (pay-premium (policy-id uint) (amount uint))
  (let ((policy-data (unwrap! (map-get? insurance-policies { policy-id: policy-id }) ERR-POLICY-NOT-FOUND)))
    (asserts! (is-eq (get owner policy-data) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (>= amount (get premium-amount policy-data)) ERR-INSUFFICIENT-PAYMENT)

    ;; Record payment
    (map-set policy-payments
      { policy-id: policy-id, payment-id: block-height }
      {
        amount: amount,
        payment-date: block-height,
        payment-type: "premium"
      }
    )

    (ok true)
  )
)

(define-public (file-claim
  (policy-id uint)
  (claim-type (string-ascii 30))
  (claim-amount uint)
  (description (string-ascii 500))
)
  (let (
    (policy-data (unwrap! (map-get? insurance-policies { policy-id: policy-id }) ERR-POLICY-NOT-FOUND))
    (claim-id (var-get next-claim-id))
  )
    (asserts! (is-eq (get owner policy-data) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-policy-active (get end-date policy-data)) ERR-POLICY-EXPIRED)
    (asserts! (> claim-amount u0) ERR-INVALID-INPUT)

    ;; Create claim
    (map-set insurance-claims
      { claim-id: claim-id }
      {
        policy-id: policy-id,
        vehicle-id: (get vehicle-id policy-data),
        claimant: tx-sender,
        claim-type: claim-type,
        claim-amount: claim-amount,
        description: description,
        claim-date: block-height,
        status: "pending",
        approved-amount: u0
      }
    )

    ;; Update policy claims count
    (map-set insurance-policies
      { policy-id: policy-id }
      (merge policy-data { claims-count: (+ (get claims-count policy-data) u1) })
    )

    ;; Increment claim ID
    (var-set next-claim-id (+ claim-id u1))

    (ok claim-id)
  )
)

(define-public (process-claim (claim-id uint) (approved-amount uint) (new-status (string-ascii 20)))
  (let ((claim-data (unwrap! (map-get? insurance-claims { claim-id: claim-id }) ERR-CLAIM-NOT-FOUND)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set insurance-claims
      { claim-id: claim-id }
      (merge claim-data {
        approved-amount: approved-amount,
        status: new-status
      })
    )

    (ok true)
  )
)

(define-public (renew-policy (policy-id uint))
  (let ((policy-data (unwrap! (map-get? insurance-policies { policy-id: policy-id }) ERR-POLICY-NOT-FOUND)))
    (asserts! (is-eq (get owner policy-data) tx-sender) ERR-NOT-AUTHORIZED)

    (map-set insurance-policies
      { policy-id: policy-id }
      (merge policy-data {
        end-date: (+ block-height u52560),
        status: "active"
      })
    )

    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-policy (policy-id uint))
  (map-get? insurance-policies { policy-id: policy-id })
)

(define-read-only (get-vehicle-policy (vehicle-id uint))
  (map-get? vehicle-policies { vehicle-id: vehicle-id })
)

(define-read-only (get-claim (claim-id uint))
  (map-get? insurance-claims { claim-id: claim-id })
)

(define-read-only (get-policy-payment (policy-id uint) (payment-id uint))
  (map-get? policy-payments { policy-id: policy-id, payment-id: payment-id })
)

(define-read-only (calculate-premium-quote (coverage-type (string-ascii 20)) (vehicle-type (string-ascii 20)))
  (calculate-premium coverage-type vehicle-type)
)
