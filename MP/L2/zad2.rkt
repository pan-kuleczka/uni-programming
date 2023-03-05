#lang racket

(define (fib n)
  (if (< n 2) n (+ (fib (- n 1)) (fib (- n 2))))
  )

(define (fib-iter n fn-2 fn-1)
  (if (= n 0) fn-2 (fib-iter (- n 1) fn-1 (+ fn-2 fn-1)))
  )
  