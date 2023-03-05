#lang racket

(define (maximum xs)
  (if (equal? xs null) -inf.0
     (let ([c (maximum (cdr xs))] [x (car xs)])
       (if (> x c) x c)
       )
     )
  )