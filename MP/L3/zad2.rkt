#lang racket
(require rackunit)

(define (product xs)
    (foldl * 1 xs)
)

(check-eq? (product '(1 2 3)) 6)
(check-eq? (product '()) 1)
