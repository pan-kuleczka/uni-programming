#lang racket
(require rackunit)

(define (sum_biggest_sq a b c)
    (- 
        (+ (* a a) (* b b) (* c c))
        (expt (min a b c) 2)
    )
)

(check-eq? (sum_biggest_sq 2 1 3) 13)
(check-eq? (sum_biggest_sq 1 -1 2) 5)
(check-eq? (sum_biggest_sq -1 -2 -3) 5)
