#lang racket

(define-struct matrix (a b c d) #:transparent)

(define (matrix-mult m1 m2)
    (matrix 
        [+ (* (matrix-a m1) (matrix-a m2)) (* (matrix-b m1) (matrix-c m2))]
        [+ (* (matrix-a m1) (matrix-b m2)) (* (matrix-b m1) (matrix-d m2))]
        [+ (* (matrix-c m1) (matrix-a m2)) (* (matrix-d m1) (matrix-c m2))]
        [+ (* (matrix-c m1) (matrix-b m2)) (* (matrix-d m1) (matrix-d m2))]
    )
)

(define matrix-id (matrix 1 0 0 1))

(define (matrix-expt m k)
    (define (expt-iter current-matrix k)
        (if (= k 0) current-matrix (expt-iter (matrix-mult current-matrix m) (- k 1)))
    )
    (expt-iter matrix-id k)
)

(define (fib-matrix k)
    (matrix-b (matrix-expt (matrix 1 1 1 0) k))
)
