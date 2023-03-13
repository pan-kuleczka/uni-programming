#lang racket

(define (my-compose f g)
    (lambda (x) (f (g x)))
)

(define (square x) (* x x))
(define (inc x) (+ x 1))

(( my-compose square inc ) 5)
(( my-compose inc square ) 5)
