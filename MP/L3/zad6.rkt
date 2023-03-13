#lang racket
(require rackunit)

(define empty-set (lambda (x) #f))
(define (singleton a) (lambda (x) (equal? a x)))
(define (in a s) (s a))
(define (union s t) (lambda (x) (or (s x) (t x))))
(define (intersect s t) (lambda (x) (and (s x) (t x))))

(check-true (in 3 (intersect (union (singleton 2) (singleton 3)) (singleton 3))))
(check-false (in 3 (intersect (union (singleton 2) (singleton 3)) (singleton 2))))
