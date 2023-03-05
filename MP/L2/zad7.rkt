#lang racket

(define (suffixes xs)
  (if (equal? xs null) (list (list))
     (cons xs (suffixes (cdr xs)))
     )
  )