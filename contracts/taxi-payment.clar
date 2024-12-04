;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-driver (err u101))
(define-constant err-already-registered (err u102))
(define-constant err-insufficient-payment (err u103))
(define-constant err-ride-not-found (err u104))

;; Define data variables
(define-map drivers principal bool)
(define-map rides
    uint
    {
        driver: principal,
        passenger: principal,
        fare: uint,
        completed: bool,
        paid: bool
    }
)
(define-data-var next-ride-id uint u0)

;; Register a driver (only contract owner can do this)
(define-public (register-driver (driver principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-none (map-get? drivers driver)) err-already-registered)
        (ok (map-set drivers driver true))
    )
)

;; Start a new ride
(define-public (start-ride (driver principal) (passenger principal) (fare uint))
    (let
        (
            (ride-id (var-get next-ride-id))
        )
        (asserts! (is-some (map-get? drivers driver)) err-invalid-driver)
        (map-set rides ride-id {
            driver: driver,
            passenger: passenger,
            fare: fare,
            completed: false,
            paid: false
        })
        (var-set next-ride-id (+ ride-id u1))
        (ok ride-id)
    )
)

;; Complete a ride
(define-public (complete-ride (ride-id uint))
    (let
        (
            (ride (unwrap! (map-get? rides ride-id) err-ride-not-found))
        )
        (asserts! (is-eq tx-sender (get driver ride)) err-invalid-driver)
        (ok (map-set rides ride-id (merge ride { completed: true })))
    )
)

;; Pay for a ride
(define-public (pay-ride (ride-id uint))
    (let
        (
            (ride (unwrap! (map-get? rides ride-id) err-ride-not-found))
        )
        (asserts! (is-eq tx-sender (get passenger ride)) err-invalid-driver)
        (asserts! (get completed ride) err-ride-not-found)
        (try! (stx-transfer? (get fare ride) tx-sender (get driver ride)))
        (ok (map-set rides ride-id (merge ride { paid: true })))
    )
)

;; Read-only functions
(define-read-only (get-ride (ride-id uint))
    (ok (map-get? rides ride-id))
)

(define-read-only (is-driver (address principal))
    (ok (is-some (map-get? drivers address)))
)
