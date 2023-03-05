#lang racket

(define (select xs)
  (define (minimum xs)
    (if (equal? xs null) +inf.0
       (let ([c (minimum (cdr xs))] [x (car xs)])
         (if (< x c) x c)
         )
       )
    )
  (define (remove-element xs x)
    (if (= (car xs) x) (rest xs)
       (cons (car xs) (remove-element (rest xs) x))
       )
    )
  (define smallest (minimum xs))
  (cons smallest (remove-element xs smallest))
  )

(define (select-sort xs)
  (if (equal? xs null) null
     (let ([selected (select xs)])
        (cons (first selected) (select-sort (rest selected)))
       )
     )
  )