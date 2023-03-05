#lang racket

(define (sorted? xs)
  (if (or (equal? xs null) (equal? (cdr xs) null)) #t
     (and (<= (first xs) (second xs)) (sorted? (rest xs)))
     )
  )