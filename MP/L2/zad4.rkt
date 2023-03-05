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

(define (matrix-sq m) (matrix-mult m m))

(define matrix-id (matrix 1 0 0 1))

(define (matrix-expt-fast m k)
    (define (expt-fast k)
        (if (= k 0) matrix-id 
            [if (= (modulo k 2) 0)
                (matrix-sq (expt-fast (floor (/ k 2))))
                (matrix-mult m (expt-fast (- k 1)))
            ]
        )
    )
    (expt-fast k)
)

(define (fib-fast k)
    (matrix-b (matrix-expt-fast (matrix 1 1 1 0) k))
)
