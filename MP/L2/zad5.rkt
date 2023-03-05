#lang racket

(define (elem? x xs)
  (if (equal? xs null) #f
     (or (equal? x (car xs)) (elem? x (cdr xs))))
  )